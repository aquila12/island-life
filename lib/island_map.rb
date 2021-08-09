# frozen_string_literal: true

# Class to encapsulate the whole game state
class IslandMap < Hash
  def self.colour(hexcolour)
    hc = hexcolour.dup
    hc.slice!(0) if hc.start_with? '#'

    case hc.length
    when 1, 3, 4
      channels = hc.chars.map { |c| c.hex * 0x11 }
    when 2, 6, 8
      channels = []
      until hc.empty? do
        channels << hc.slice!(0,2).hex
      end
    else return [0, 0, 0, 255]
    end

    a = 255
    case channels.length
    when 1 then r = g = b = channels.first
    when 3 then r, g, b = channels
    when 4 then r, g, b, a = channels
    end
    [r, g, b, a]
  end

  TILE = {
    waste: { tint: colour('#9'), fill: [160, 160, 160], line: [120, 120, 120] },
    grass: { tint: colour('#090'), fill: [0, 160, 0], line: [0, 120, 0] }
  }

  def initialize(radius)
    super
    fill_tiles(CubeCoord[0, 0, 0], radius, :waste)
  end

  def fill_tiles(centre, radius, tile)
    (0..radius).each do |r|
      centre.ring(r) do |coord|
        self[coord.to_axial] = {
          coordinate: coord,
          point: coord.to_point,
          tile: tile
        }
      end
    end
  end

  def draw(outputs)
    values.each do |item|
      tile = TILE[item[:tile]]
      outputs.sprites << tile_sprite(item[:point], tile[:tint])
      # outputs.solids << square_around(item[:point], CubeCoord.size / 2 - 1, *tile[:fill])
      # outputs.borders << square_around(item[:point], CubeCoord.size / 2, *tile[:line])
    end
  end

  def each_adjacent(centre, &block)
    Enumerator.new do |yielder|
      centre.round.ring(1) do |coord|
        k = coord.to_axial
        yielder << self[k] if key? k
      end
    end.each(&block)
  end

  private

  def tile_sprite(centre, colour)
    {
      x: centre.x - 3,
      y: centre.y - 4,
      w: 7,
      h: 8,
      r: colour[0],
      g: colour[1],
      b: colour[2],
      a: colour[3],
      path: 'resources/tile.png'
    }
  end

  def rect_around(pt, width, height, *args)
    [pt.x - width / 2, pt.y - height / 2, width, height, *args]
  end

  def square_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end
end
