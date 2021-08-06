# frozen_string_literal: true

# Class to encapsulate the whole game state
class CubeCoord
  SIZE = 40.0 # Flat to flat
  ROOT_3 = 3 ** 0.5

  ROOT_3_SIZE = SIZE * ROOT_3

  DEFAULT_ORIGIN = [640, 360]

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  attr_reader :x, :y, :z

  def to_axial
    [@y, @z]
  end

  def self.from_axial(p, q)
    new(-(p + q), p, q)
  end

  def self.from_point(pt, origin = DEFAULT_ORIGIN)
    x, y = [pt.x - origin.x, pt.y - origin.y]
    y_r3s = y / ROOT_3_SIZE
    x_s = x / SIZE
    from_axial(x_s + y_r3s, -2 * y_r3s)
  end

  def to_s
    "[#{@x}, #{@y}, #{@z}]"
  end

  def to_point(origin = DEFAULT_ORIGIN)
    p, q = to_axial
    q_2 = q / 2.0
    [origin.x + SIZE * (p + q_2),  origin.y - ROOT_3_SIZE * q_2]
  end

  def round!
    ix, iy, iz = [@x.round, @y.round, @z.round]
    dx, dy, dz = [(ix - @x).abs, (iy - @y).abs, (iz - @z).abs]
    m = [dx, dy, dz].max
    case m
    when dx then ix = -(iy + iz)
    when dy then iy = -(ix + iz)
    when dz then iz = -(iy + ix)
    end
    @x, @y, @z = [ix, iy, iz]
  end

  def round
    dup.tap { |c| c.round! }
  end

  def distance_from(other)
    ((other.x - @x).abs + (other.y - @y).abs + (other.z - @z).abs) / 2
  end
end

  # def initialize(args)
  #   @args = args
  #   @saved = []
  # end
  #
  # def tick
  #   inputs
  #   draw
  # end
  #
  # def inputs
  #   inp = @args.inputs
  #   m = inp.mouse
  #   @coord = Coord.from_point(m.position)
  #   @status = @coord.round.to_s
  #   if m.click
  #     @saved.clear if m.button_right
  #
  #     if m.button_left
  #       @saved << @coord.round.to_point
  #     end
  #   end
  # end
  #
  # def draw
  #   if @coord
  #     @args.outputs.borders << rect_around(@coord.to_point, 2, 160, 0, 0)
  #     @args.outputs.borders << rect_around(@coord.round.to_point, 2, 0, 160, 0)
  #   end
  #
  #   @saved.each do |pt|
  #     @args.outputs.borders << rect_around(pt, Coord::SIZE / 2, 0, 0, 160)
  #   end
  #
  #   @args.outputs.labels << [8, 720 - 8, @status] if @status
  # end
  #
  # def rect_around(pt, radius, *args)
  #   d = radius * 2 + 1
  #   [pt.x - radius, pt.y - radius, d, d, *args]
  # end
