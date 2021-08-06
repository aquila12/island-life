# frozen_string_literal: true

require 'lib/cube_coord.rb'
require 'lib/island_map.rb'
require 'lib/profiler.rb'

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @outputs = args.outputs
    @inputs = args.inputs
    @board = IslandMap.new(4)
    @actions = []

    @profiler = {
      island_update: Profiler.new("Island Update", 5)
    }
  end

  def tick
    do_input
    do_output
  end

  def do_input
    i = @inputs
    if i.mouse.click
      case
      when i.mouse.button_left then place_action(i.mouse.position)
      when i.mouse.button_right then commit_action
      when i.mouse.button_middle
        @profiler[:island_update].profile { update_board }
        @status = @profiler[:island_update].report
      end
    end
  end

  def do_output
    o = @outputs
    @board.draw o

    @actions.each { |item| o.borders << item[:rectangle] }
    o.labels << [8, 720 - 8, @status] if @status
  end

  private

  def rect_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    if @actions.length < NUM_ACTIONS && @board.key?(c.to_axial)
      @actions << {
        rectangle: rect_around(c.to_point, 3, 0, 192, 0),
        coord: c
      }
    end

    @status = c.to_s
  end

  def commit_action
    @actions.each do |a|
      c = a[:coord]
      @board[c.to_axial][:tile] = :grass
    end
    @actions.clear
  end

  def update_board
    @board.each do |_k, tc|
      score = @board.each_adjacent(tc[:coordinate]).count { |ta| ta[:tile] == :grass }

      tc[:new_tile] = :grass if score > 1
    end

    @board.each do |_k, t|
      if t.key? :new_tile
        t[:tile] = t[:new_tile]
        t.delete :new_tile
      end
    end
  end
end
