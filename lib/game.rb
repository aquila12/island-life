# frozen_string_literal: true

# Class to encapsulate the whole game state
class Game
  NUM_ACTIONS = 3
  ACTIONS = [
    { sprite_class: RainCloud, provides: { rainfall: 1 } },
    { sprite_class: RainCloud2, provides: { water: 1} },
    { sprite_class: Fire, provides: { flames: 1 } },
    { sprite_class: Earthquake, provides: { vibes: 1 } }
  ]

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

    @current_action = 0
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
      when i.mouse.button_left
        pos = @window.mouse_position
        if (pos.y < 16 && pos.x >= 56)
          pos.y < 8 ? commit_action : change_tool
        else
          place_action(pos)
        end
      when i.mouse.button_right
        undo_action(@window.mouse_position)
      end
    end

    @status_text = prepare_status_lines(@window.mouse_position)
  end

  def do_output
    o = @window.outputs
    o.background_color = '#036'.hexcolor
    @board.draw o
    @wildlife.draw o

    o.sprites << @status_text
    o.sprites << [56, 0, 8, 16, 'resources/toolbar.png']

    o.sprites << @actions.values.map { |a| a[:sprite] }.sort { |a| a.y }
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

  def change_tool
    @current_action += 1
    @current_action = 0 unless @current_action < ACTIONS.length
  end

  def place_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)

    if @actions.length < NUM_ACTIONS || @actions.key?(axial)
      action = ACTIONS[@current_action]
      @actions[axial] = {
        sprite: action[:sprite_class].new(c),
        stats: action[:provides]
      }
      @args.outputs.sounds << 'resources/drip.wav'
    end
  end

  def undo_action(point)
    c = CubeCoord.from_point(point).round!
    axial = c.to_axial
    return unless @board.key?(axial)

    if @actions.delete(axial)
      @args.outputs.sounds << 'resources/undrip.wav'
    end
  end

  def commit_action
    @actions.each do |c, action|
      action[:stats].each { |stat, value| @board[c].stats[stat] += value }
    end

    @actions.clear
    @current_operation = update_board
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
