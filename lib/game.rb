# frozen_string_literal: true

require 'lib/cube_coord.rb'
require 'lib/island_map.rb'
require 'lib/profiler.rb'
require 'lib/draw_window.rb'

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @args = args
    CubeCoord.size = 8
    CubeCoord.default_origin = [32, 32]
    @window = DrawWindow.new(args, 64, 64, 11)
    @board = IslandMap.new(4)
    @actions = []

    @fiber_profiler = Profiler.new('Fiber', 10)
  end

  def tick
    if @current_operation&.alive?
      @fiber_profiler.profile do
        set_deadline(5000)
        @current_operation.resume
      end
      @status = @fiber_profiler.report
    else
      do_input
    end

    do_output
  end

  def do_input
    i = @args.inputs
    if i.mouse.click
      case
      when i.mouse.button_left then place_action(@window.mouse_position)
      when i.mouse.button_right then commit_action
      when i.mouse.button_middle
        @current_operation = update_board
      end
    end
  end

  def do_output
    o = @window.outputs
    @board.draw o

    @actions.each { |item| o.borders << item[:rectangle] }
    @window.draw
    @args.outputs.labels << [8, 720 - 8, @status, 192, 0, 0] if @status
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

  def set_deadline(usec)
    t0 = Time.now.usec
    t1 = t0 + usec
    if t1 >= 1000000
      @deadline_range = (t1 - 1000000)..t0
      @deadline_cover = false
    else
      @deadline_range = t0..t1
      @deadline_cover = true
    end
  end

  def time_up?
    t = Time.now.usec
    @deadline_range.cover?(t) != @deadline_cover
  end

  def update_board
    @current_operation = Fiber.new { update_board_fiber }
  end

  def update_board_fiber
    @board.each do |_k, tc|
      score = @board.each_adjacent(tc[:coordinate]).count { |ta| ta[:tile] == :grass }

      tc[:new_tile] = :grass if score > 1

      Fiber.yield if time_up?
    end

    @board.each do |_k, t|
      if t.key? :new_tile
        t[:tile] = t[:new_tile]
        t.delete :new_tile
      end

      Fiber.yield if time_up?
    end
  end
end
