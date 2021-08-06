# frozen_string_literal: true

require 'lib/cube_coord.rb'

# Class to encapsulate the whole game state
class Game
  def initialize(args)
    @args = args
    init_board(4)
  end

  def tick
    inputs
    draw
  end

  def inputs
    inp = @args.inputs
  end

  def draw
    @board_map.values.each do |item|
      @args.outputs.solids << item[:solid]
      @args.outputs.borders << item[:outline]
    end
  end

  private

  def rect_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end

  def init_board(radius)
    @board_map = {}
    origin = CubeCoord.new(0, 0, 0)
    (-4..4).each do |p|
      (-4..4).each do |q|
        c = CubeCoord.from_axial(p, q)
        next if c.distance_from(origin) > radius

        @board_map[c.to_axial] = {
          solid: rect_around(c.to_point, CubeCoord::SIZE / 2 - 1, 160, 160, 160),
          outline: rect_around(c.to_point, CubeCoord::SIZE / 2, 120, 120, 120),
          tile: :waste
        }
      end
    end
  end
end
