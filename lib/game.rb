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
    @actions = {}

    @fiber_profiler = Profiler.new('Fiber', 10)
  end

  def tick
    if @current_operation&.alive?
      @fiber_profiler.profile { @current_operation.time_slice(5000) }
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
    o.background_color = '#036'.hexcolor
    @board.draw o

    draw_actions
    @window.draw
    @args.outputs.labels << [8, 720 - 8, @status, 192, 0, 0] if @status
  end

  def draw_actions
    o = @window.outputs
    @actions.values { |e| -e[:position].y }.each_with_index do |item, index|
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

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)

    if @actions.key?(axial)
      @actions.delete(axial)
    elsif @actions.length < NUM_ACTIONS
      @actions[axial] = {
        position: c.to_point,
        coord: c
      }
    end

    @status = c.to_s
  end

  def commit_action
    @actions.each do |c, a|
      @board[c].stats[:rainfall] += 1
    end

    @actions.clear
  end

  def update_board
    @current_operation = BackgroundTask.new do |task|
      @board.each do |_k, tile|
        set_tile_stats(tile)
        tile.update

        task.yield
      end

      @board.transform_values! do |tile|
        task.yield

        tile.new_tile
      end
    end
  end

  def set_tile_stats(tile)
    @board.each_adjacent(tile.coord) do |ta|
      tile.stats[:land] += 1
      ta.class.products.each { |stat, value| tile.stats[stat] += value }
    end
    tile.stats[:coast] = 6 - tile.stats[:land]
  end
end
