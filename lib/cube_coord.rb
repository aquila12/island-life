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

  def self.[](*coords)
    new(*coords)
  end

  attr_reader :x, :y, :z

  def to_axial
    [@y, @z]
  end

  def self.from_axial(p, q)
    new(-(p + q), p, q)
  end

  def to_point(origin = DEFAULT_ORIGIN)
    p, q = to_axial
    q_2 = q / 2.0
    [origin.x + SIZE * (p + q_2),  origin.y - ROOT_3_SIZE * q_2]
  end

  def self.from_point(pt, origin = DEFAULT_ORIGIN)
    x, y = pt.x - origin.x, pt.y - origin.y
    y_r3s = y / ROOT_3_SIZE
    x_s = x / SIZE
    from_axial(x_s + y_r3s, -2 * y_r3s)
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
