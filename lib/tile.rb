# frozen_string_literal: true

# Class to encapsulate all kinds of tile behaviour
class Tile
  attr_sprite

  class << self
    def products
      @stats ||= Hash.new(0)
    end

    def provides(**new_products)
      products.merge! new_products
    end

    def appearance(tint)
      @tint = Color[tint]
    end

    attr_reader :tint
  end

  def initialize(coord)
    @coord = coord
    @stats = Hash.new(0)
    init_sprite
  end

  attr_reader :coord
  attr_accessor :stats

  def init_sprite
    pos = @coord.to_point
    @x, @y = pos.x - 3, pos.y - 4
    @w, @h = 7, 8
    @r, @g, @b, @a = self.class.tint.rgba
    @source_x, @source_y = 0, 0
    @source_w, @source_h = @w, @h
    @path = 'resources/tile.png'
  end

  def new_tile
    @new_class&.new(@coord) || self
  end

  def name
    self.class.name.split('::').last
  end

  def update
    @new_class = behaviour
    @stats.clear
  end
end
