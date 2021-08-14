# frozen_string_literal: true

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3

  def initialize(args)
    @args = args
    CubeCoord.size = 6
    CubeCoord.default_origin = [32, 32]
    @window = DrawWindow.new(args, 64, 64, 11)
    @board = IslandMap.new
    @wildlife = Wildlife.new
    @current_operation = initialize_board
    @actions = {}

    @fiber_profiler = Profiler.new('Fiber', 10)
  end

  def tick
    if @current_operation&.alive?
      @fiber_profiler.profile { @current_operation.time_slice(5000) }
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
    @wildlife.draw o

    o.sprites << @actions.values.sort { |a| -a.y }
    @window.draw
    # @args.outputs.labels << [8, 720 - 8, @status, 192, 0, 0] if @status
  end

  private

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)

    if @actions.key?(axial)
      @actions.delete(axial)
    elsif @actions.length < NUM_ACTIONS
      @actions[axial] = RainCloud.new(c)
    end
  end

  def commit_action
    @actions.each_key do |c|
      @board[c].stats[:rainfall] += 1
    end

    @actions.clear
  end

  def initialize_board
    BackgroundTask.new do |task|
      centre = CubeCoord[0, 0, 0]
      @board.fill_tiles(centre, 5, TileTypes::Waste)
      task.yield
      @board.erode(centre, 5, 0.5)
      task.yield
    end
  end

  def update_board
    BackgroundTask.new do |task|
      @board.each_value do |tile|
        set_tile_stats(tile)
        task.yield
        @wildlife.do_update(tile.coord, tile.class.products, tile.stats)
        task.yield
        tile.update
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
