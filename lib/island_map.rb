# frozen_string_literal: true

# Class to encapsulate the whole game state
class IslandMap < Hash
  TILE = {
    waste: { fill: [160, 160, 160], line: [120, 120, 120] },
    grass: { fill: [0, 160, 0], line: [0, 120, 0] }
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
      outputs.solids << rect_around(item[:point], CubeCoord::SIZE / 2 - 1, *tile[:fill])
      outputs.borders << rect_around(item[:point], CubeCoord::SIZE / 2, *tile[:line])
    end
  end

  def each_adjacent(centre, &block)
    Enumerator.new do |yielder|
      centre.round.ring(1) do |coord|
        k = coord.to_axial
        yielder << self[k] if self.key? k
      end
    end.each(&block)
  end

  private

  def rect_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end
end
