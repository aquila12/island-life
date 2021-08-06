# frozen_string_literal: true

require 'lib/cube_coord.rb'
require 'lib/island_map.rb'

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @args = args
    @board = IslandMap.new(4)
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
        if @actions.length < NUM_ACTIONS && @board.key?(c.to_axial)
          @actions << {
            rectangle: rect_around(c.to_point, 3, 0, 192, 0),
            coord: c
          }
        end

        @status = c.to_s
      end

      if inp.mouse.button_right
        @actions.each do |a|
          c = a[:coord]
          @board[c.to_axial][:tile] = :grass
        end
        @actions.clear
      end
    end
  end

  def draw
    @board.draw(@args.outputs)

    @actions.each do |item|
      @args.outputs.borders << item[:rectangle]
    end

    @args.outputs.labels << [8, 720 - 8, @status] if @status
  end

  private

  def rect_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end
end
