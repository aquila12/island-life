# frozen_string_literal: true

# Class to encapsulate the whole game state
class IslandMap < Hash
  def fill_tiles(centre, radius, tile_class)
    (0..radius).each do |r|
      centre.ring(r) do |coord|
        self[coord.to_axial] = tile_class.new(coord)
      end
    end
  end

  def erode(centre, radius, chance)
    centre.ring(radius) do |coord|
      delete coord.to_axial if rand < chance
    end
  end

  def draw(outputs)
    outputs.sprites << values
  end

  def each_adjacent(centre, &block)
    Enumerator.new do |yielder|
      centre.round.ring(1) do |coord|
        k = coord.to_axial
        yielder << self[k] if key? k
      end
    end.each(&block)
  end
end
