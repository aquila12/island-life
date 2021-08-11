# frozen_string_literal: true

# Class to encapsulate all kinds of tile behaviour
class Tile
  attr_sprite

  class << self
    def inherited(subclass)
      subclass.instance_eval do
        @stats = Hash.new(0)
      end
    end

    def provides(**args)
      @stats.merge! args
    end

    def appearance(tint)
      @tint = tint.hexcolor
    end

    def behaviour(&block)
      @behaviour = block
    end

    attr_reader :stats, :tint
  end

  def initialize(coord)
    @coord = coord
    @stats = Hash.new(0)
    @action_stats = Hash.new(0)
    init_sprite
  end

  attr_reader :coord
  attr_accessor :stats, :action_stats

  def init_sprite
    pos = @coord.to_point
    @x, @y = pos.x - 3, pos.y - 4
    @w, @h = 7, 8
    @r, @g, @b, @a = self.class.tint
    @source_x, @source_y = 0, 0
    @source_w, @source_h = @w, @h
    @path = 'resources/tile.png'
  end

  def replace_with(tile_class)
    @new_class = tile_class
  end

  def new_tile
    @new_class&.new(@coord) || self
  end

  def update
    behaviour
  end
end
