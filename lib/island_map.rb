# frozen_string_literal: true

# Class to encapsulate the whole game state
class IslandMap < Hash
  TILE = {
    waste: { tint: '#fc9'.hexcolor, fill: [160, 160, 160], line: [120, 120, 120] },
    grass: { tint: '#2f2'.hexcolor, fill: [0, 160, 0], line: [0, 120, 0] },
    forest: { tint: '#2a2'.hexcolor },
    old_forest: { tint: '#252'.hexcolor }
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
