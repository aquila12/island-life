# frozen_string_literal: true

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3
  ACTIONS = {
  rain: { sprite_class: RainCloud, provides: { rainfall: 1 } },
  flood: { sprite_class: RainCloud2, provides: {water: 1}}
  # fire: { sprite_class:Flames,provides: {flames:1}},
  # earthquake:{sprite_class:Tremors,provides:{vibes:1}}
}

  def initialize(args)
    @args = args
    CubeCoord.size = 6
    CubeCoord.default_origin = [32, 32]
    @window = DrawWindow.new(args, 64, 64, 11)
    @board = IslandMap.new
    @wildlife = Wildlife.new
    @current_operation = initialize_board
    @actions = {}
    @font = MiniFont.new('resources/font.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 4, 6)

    @fiber_profiler = Profiler.new('Fiber', 10)
    @font_profiler = Profiler.new('FontPrep', 10)
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
      when i.mouse.button_right then undo_action(@window.mouse_position)
      end
    end

    if i.keyboard.key_up&.a
      commit_action
      @current_operation = update_board
    end

    @status_text = prepare_status_lines(@window.mouse_position)
  end

  def do_output
    o = @window.outputs
    o.background_color = '#036'.hexcolor
    @board.draw o
    @wildlife.draw o

    o.sprites << @status_text

    o.sprites << @actions.values.sort { |a| -a.y }
    @window.draw
    # @args.outputs.labels << [8, 720 - 8, @status, 192, 0, 0] if @status
    # @args.outputs.labels << [8, 720 - 8, @font_profiler.report, 192, 0, 0]
  end

  private

  def prepare_status_lines(point)
    @font_profiler.profile do
      c = CubeCoord.from_point(point).round!
      axial = c.to_axial
      return [] unless @board.key?(axial)

      text = [
        @wildlife.animal_at(axial).upcase,
        @board[axial].name.upcase
      ].join("\n")

      @font.str2sprites(1, 6, text)
    end
  end

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)

    @actions[axial] = RainCloud2.new(c) if @actions.length < NUM_ACTIONS
    @args.outputs.sounds << 'resources/drip.wav'
  end

  def undo_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)
    @actions.delete(axial)
    @args.outputs.sounds << 'resources/undrip.wav'
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
      @board.erode(centre, 4, 0.2)
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
