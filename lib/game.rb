# frozen_string_literal: true

require 'lib/hex_tile_map.rb'
require 'lib/hex_tile_map_view.rb'

# Class to encapsulate the whole game state
class Game
  COLOURS = {
    blue: [64, 64, 192],
    yellow: [255, 192, 0]
  }

  TILE_H = 30
  TILE_W = (0.866 * TILE_H).round

  def initialize(args)
    @args = args
    @map = HexTileMap.new(15, 15, shape: :long_odds, default: COLOURS[:blue])
    @map_view = HexTileMapView.new(@map)
    @map_view.x_scl = TILE_W
    @map_view.y_scl = TILE_H
  end

  def tick
    inputs
    draw
  end

  def inputs
    inp = @args.inputs
    m = inp.mouse
    if m.click
      if m.button_left
        p, q = @map_view.xy_to_pq(m.click.point)
        @rect = [p * TILE_W - 2, q * TILE_H - 2, 5, 5, 192, 0, 0]
        @map.set_tile(p, q, COLOURS[:yellow])
      elsif m.button_right
        p, q = @map_view.xy_to_pq(m.click.point, snap: :corner)
        @rect = [p * TILE_W - 2, q * TILE_H - 2, 5, 5, 0, 192, 0]
        [[p - 0.25, q - 0.25], [p + 0.25, q - 0.25], [p + 0.25, q + 0.25], [p - 0.25, q + 0.25]]
        .each { |p, q| @map.set_tile(p, q, COLOURS[:blue]) }
      end
    end
  end

  def draw
    @map_view.each_tile do |tile, coords|
      @args.outputs.solids << [coords[:x], coords[:y], TILE_W, TILE_H, *tile]
      @args.outputs.borders << [coords[:x], coords[:y], TILE_W + 1, TILE_H + 1, 160, 160, 160]
    end
    @rect && @args.outputs.borders << @rect
  end
end
