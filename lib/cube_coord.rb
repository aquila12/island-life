# frozen_string_literal: true

# Class to handle hexes in cube coordinates
class CubeCoord
  ROOT_3 = 3**0.5

  class << self
    def size=(size)
      @size = size.to_f
      @root3_size = @size * ROOT_3
    end

    attr_accessor :default_origin
    attr_reader :size

    def [](*coords)
      new(*coords)
    end

    def from_axial(p, q)
      new(-(p + q), p, q)
    end

    def from_point(pt, origin = @default_origin)
      x, y = pt.x - origin.x, pt.y - origin.y
      y_r3s = y / @root3_size
      x_s = x / @size
      from_axial(x_s + y_r3s, -2 * y_r3s)
    end

    def axial_to_point(ax, origin)
      q = ax.y / 2.0
      [origin.x + @size * (ax.x + q), origin.y - @root3_size * q]
    end
  end

  self.size = 40.0 # Flat to flat
  @default_origin = [640, 360]

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  attr_reader :x, :y, :z

  def to_axial
    [@y, @z]
  end

  def to_point(origin = self.class.default_origin)
    self.class.axial_to_point(to_axial, origin)
  end

  def to_s
    "[#{@x}, #{@y}, #{@z}]"
  end

  def distance_from(other)
    ((other.x - @x).abs + (other.y - @y).abs + (other.z - @z).abs) / 2
  end

  def round!
    ix, iy, iz = @x.round, @y.round, @z.round
    dx, dy, dz = (ix - @x).abs, (iy - @y).abs, (iz - @z).abs
    m = [dx, dy, dz].max
    case m
    when dx then ix = -(iy + iz)
    when dy then iy = -(ix + iz)
    when dz then iz = -(iy + ix)
    end
    @x, @y, @z = ix, iy, iz
    self
  end

  def round
    dup.round!
  end

  def add(other)
    @x += other.x
    @y += other.y
    @z += other.z
    self
  end

  def take(other)
    @x -= other.x
    @y -= other.y
    @z -= other.z
    self
  end

  def scale(scale)
    @x *= scale
    @y *= scale
    @z *= scale
    self
  end

  def plus(other)
    dup.add other
  end

  def minus(other)
    dup.take other
  end

  def times(scale)
    dup.scale scale
  end

  ADJACENCY = [
    new(1, -1, 0),
    new(0, -1, 1),
    new(-1, 0, 1),
    new(-1, 1, 0),
    new(0, 1, -1),
    new(1, 0, -1)
  ]

  def ring(radius)
    yield self if radius.zero?

    coord = self.plus ADJACENCY[4].times(radius)
    ADJACENCY.each do |v|
      radius.times do
        coord.add v
        yield coord.dup
      end
    end
  end
end
