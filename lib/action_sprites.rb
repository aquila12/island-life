# frozen_string_literal: true

class RainCloud
  def initialize(coord)
    @coord = coord
    @x, @y = coord.to_point
    @rain_y = 4.0
    @path = 'resources/raincloud.png'
  end

  attr_reader :x, :y
  attr_reader :coord

  def animate
    @rain_y -= 0.333
    @rain_y += 11 if @rain_y < 4
  end

  def draw_override(canvas)
    animate

    draw_fragment canvas, @x - 3, @y + 1, 7, 4, 0, 0
    draw_fragment canvas, @x - 3, @y - 2, 7, 3, 0, @rain_y.to_i
  end

  def draw_fragment(canvas, x, y, w, h, tx, ty)
    canvas.draw_sprite_3(
      x, y, w, h, @path,
      nil, nil, nil, nil, nil, # Angle A R G B
      tx, ty, w, h, # Tile coords (top-down)
      nil, nil, nil, nil, # Flip H V, Anchor X Y
      nil, nil, nil, nil # Source coords (bottom-up)
    )
  end
end

class RainCloud2 < RainCloud
  def initialize(coord)
    super(coord)
    @path = 'resources/stormcloud.png'
  end

  def animate
    @rain_y -= 1.0
    @rain_y += 11 if @rain_y < 4
  end
end

class Earthquake
  attr_sprite

  def initialize(coord)
    pos = coord.to_point
    @x, @y = pos.x - 3, pos.y - 4
    @w = @h = 7
    @path = 'resources/quake.png'
  end
end

class Fire
  def initialize(coord)
    @coord = coord
    @x, @y = coord.to_point
    @tile_x = 0
    @wait = 0
    @path = 'resources/fire.png'
  end

  attr_reader :x, :y
  attr_reader :coord

  def animate
    @wait -= 1
    return if @wait > 0
    @wait = 3

    @tile_x += 7
    @tile_x = 0 unless @tile_x < 49
  end

  def draw_override(canvas)
    animate

    draw_fragment canvas, @x - 3, @y - 2, 7, 7, @tile_x, 0
  end

  def draw_fragment(canvas, x, y, w, h, tx, ty)
    canvas.draw_sprite_3(
      x, y, w, h, @path,
      nil, nil, nil, nil, nil, # Angle A R G B
      tx, ty, w, h, # Tile coords (top-down)
      nil, nil, nil, nil, # Flip H V, Anchor X Y
      nil, nil, nil, nil # Source coords (bottom-up)
    )
  end
end
