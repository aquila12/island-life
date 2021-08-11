# frozen_string_literal: true

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @args = args
    CubeCoord.size = 6
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
      when i.mouse.button_right
        commit_action
        @current_operation = update_board
      end
    end
  end

  def do_output
    o = @window.outputs
    @board.draw o

    draw_actions
    @window.draw
    @args.outputs.labels << [8, 720 - 8, @status, 192, 0, 0] if @status
  end

  def draw_actions
    o = @window.outputs
    @actions.sort { |e| -e[:position].y }.each_with_index do |item, index|
      o.sprites << rain_above(item[:position], (index + @args.tick_count) / 3)
      o.sprites << rain_cloud_above(item[:position])
    end
  end

  # TODO: Move the animation code somewhere else
  def rain_cloud_above(position)
    {
      x: position.x - 3, y: position.y + 2, w: 7, h: 4,
      source_w: 7, source_h: 4,
      source_x: 0, source_y: 13,
      path: 'resources/raincloud.png'
    }
  end

  def rain_above(position, frame)
    {
      x: position.x - 3, y: position.y-1, w: 7, h: 3,
      source_w: 7, source_h: 3,
      source_x: 0, source_y: frame.to_i % 11,
      path: 'resources/raincloud.png'
    }
  end
  # TODO: CUT HERE =======

  private

  # TODO: Remove
  def rect_around(pt, radius, *args)
    d = radius * 2 + 1
    [pt.x - radius, pt.y - radius, d, d, *args]
  end

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    if @actions.length < NUM_ACTIONS && @board.key?(c.to_axial)
      @actions << {
        position: c.to_point,
        coord: c
      }
    end

    @status = c.to_s
  end

  def commit_action
    @actions.each do |a|
      c = a[:coord].to_axial
      tc = @board[c]
      @board[c][:action_stats] = RulesStats::ACTION_STATS[:rain]
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

  def tile_stats(tile)
    stats = Hash.new(0)
    stats.merge! tile[:action_stats] if tile.key?(:action_stats)

    @board.each_adjacent(tile[:coordinate]) do |ta|
      t = ta[:tile]
      stats[:land] += 1
      RulesStats::TILE_STATS[t].each { |stat, value| stats[stat] += value }
    end
    stats[:coast] = 6 - stats[:land]

    stats
  end

  def update_board_fiber
    @board.each do |_k, tile|
      new_tile = RulesStats.check_update tile, tile_stats(tile)
      tile[:new_tile] = new_tile if new_tile

      Fiber.yield if time_up?
    end

    @board.each do |_k, t|
      if t.key? :new_tile
        t[:tile] = t[:new_tile]
        t.delete :new_tile
        t.delete :action_stats
      end

      Fiber.yield if time_up?
    end
  end
end
