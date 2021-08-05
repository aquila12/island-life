# frozen_string_literal: true

# Class to represent hex tile map storage
class HexTileMap
  SHAPES = {
    long_odds: { sizes: [-1, 0], offsets: [0.5, 0.0] },
    long_evens: { sizes: [0, -1], offsets: [0.0, 0.5] },
    odds_first: { sizes: [0, 0], offsets: [0.5, 0.0] },
    evens_first: { sizes: [0, 0], offsets: [0.0, 0.5] },
  }.freeze

  # Even strip adjust: how many tiles in even rows compared to odd
  # (Staggered vs symmetrical)
  def initialize(num_stripes, stripe_length, shape: :long_odds, default: nil)
    @default = default
    sizes, offsets = SHAPES[shape].values_at(:sizes, :offsets)
    @tiles = Array.new(num_stripes) do |i|
      n = i & 1
      {
        tiles: Array.new(stripe_length + sizes[n], @default),
        offset: offsets[n]
      }
    end
  end

  attr_reader :tiles

  def snap_pq(p, q, type: :centre)
    stripe = fetch_stripe p.floor

    case type
    when :centre
      q = q.to_f - stripe[:offset]
      [0.5 + p.floor, 0.5 + q.floor + stripe[:offset]]
    when :corner
      [p.round, (2*q).round / 2]
    end
  end

  def tile_at(p, q)
    stripe = fetch_stripe p.floor
    bounded_fetch stripe[:tiles], (q.to_f - stripe[:offset]).floor, @default
  end

  def set_tile(p, q, tile)
    stripe = fetch_stripe p.to_f.floor
    bounded(stripe[:tiles], (q.to_f - stripe[:offset]).floor) do |a, i|
      a[i] = tile
    end
  end

  private

  def bounded(array, index, default = nil)
    return default if index.negative?
    return default unless index < array.size

    yield array, index
  end

  def bounded_fetch(array, index, default)
    bounded(array, index, default) { |a, i| a[i] }
  end

  def fetch_stripe(index)
    bounded_fetch @tiles, index, { tiles: [], offset: 0 }
  end

  # def each_stripe(&block)
  #   @tiles.each(&block)
  # end
end
