class MiniFont
  def initialize(font, layout, glyph_w, glyph_h)
    @font = font
    @glyph_w = glyph_w
    @glyph_h = glyph_h
    init_layout(layout)
  end

  def init_layout(string)
    @glyphs = {}
    tile_y = 0
    string.each_line do |line|
      tile_x = 0
      line.each_char do |char|
        @glyphs[char] = [tile_x, tile_y]
        tile_x += @glyph_w
      end
      tile_y += @glyph_h
    end
  end

  def str2sprites(x, y, string)
    sprites = []

    cy = y
    string.each_line do |l|
      cx = x
      l.each_char do |c|
        char = @glyphs[c]
        next unless char

        sprites << glyph_sprite(char, cx, cy)
        cx += @glyph_w
      end
      cy += @glyph_h
    end

    sprites
  end

  def glyph_sprite(char, x, y)
    {
      x: x, y: y, w: @glyph_w, h: @glyph_h,
      tile_x: char.x, tile_y: char.y, tile_w: @glyph_w, tile_h: @glyph_h,
      path: @font
    }
  end
end
