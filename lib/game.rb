# frozen_string_literal: true

require 'lib/cube_coord.rb'

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @args = args
    init_board(4)
    @actions = []
  end

  def tick
    inputs
    draw
  end

  def inputs
    inp = @args.inputs
    if inp.mouse.click
      if inp.mouse.button_left
        c = CubeCoord.from_point(inp.mouse.position).round!
        if @actions.length < NUM_ACTIONS && @board_map.key?(c.to_axial)
          @actions << {
            rectangle: rect_around(c.to_point, 3, 0, 192, 0),
            coord: c
          }
        end
      end

      if inp.mouse.button_right
        @actions.each do |a|
          c = a[:coord]
          @board_map[c.to_axial] = {
            solid: rect_around(c.to_point, CubeCoord::SIZE / 2 - 1, 0, 160, 0),
            outline: rect_around(c.to_point, CubeCoord::SIZE / 2, 0, 120, 0),
            tile: :grass
          }
        end
        @actions.clear
      end
    end
  end

  def draw
    @board_map.values.each do |item|
      @args.outputs.solids << item[:solid]
      @args.outputs.borders << item[:outline]
    end

    @actions.each do |item|
      @args.outputs.borders << item[:rectangle]
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
