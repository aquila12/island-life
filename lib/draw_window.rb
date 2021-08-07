# frozen_string_literal: true

# Basic window / scaling functions using a render target
class DrawWindow
  def initialize(args, width, height, scale, target: :draw_window)
    @args = args
    @target = target
    set_transform_parameters(width, height, scale)
  end

  def set_transform_parameters(width, height, scale)
    @scale = scale
    w, h = width * scale, height * scale
    @xoff, @yoff = (1280 - w) / 2, (720 - h) / 2

    @screen_rect = { x: 0, y: 0, w: 1280, h: 720 }
    @window_sprite = {
      x: @xoff, y: @yoff, w: w, h: h,
      source_x: 0, source_y: 0,
      source_w: width, source_h: height,
      path: @target
    }
  end

  def reverse_transform(point)
    [
      (point.x - @xoff).to_f / @scale,
      (point.y - @yoff).to_f / @scale
    ]
  end

  def transform(point)
    [
      point.x * @scale + @xoff,
      point.y * @scale + @yoff
    ]
  end

  def outputs
    @args.render_target(@target)
  end

  def mouse_position
    reverse_transform @args.inputs.mouse.position
  end

  def draw
    @args.outputs.solids << @screen_rect
    @args.outputs.sprites << @window_sprite
  end
end
