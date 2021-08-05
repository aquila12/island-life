# frozen_string_literal: true

# Class to deal with rendering a hex tile map
class HexTileMapView
  def initialize(map)
    @htm = map
    @x_off = @y_off = 0
    @x_scl = @y_scl = 1
  end

  attr_accessor :x_off, :y_off, :x_scl, :y_scl

  def xy_to_pq(point, snap: :centre)
    p = (point.x - @x_off).to_f / @x_scl
    q = (point.y - @y_off).to_f / @y_scl

    @htm.snap_pq(p, q, type: snap)
  end

  def each_tile(&block)
    coords = { x: @x_off }
    @htm.tiles.each do |stripe|
      coords[:y] = @y_off + (stripe[:offset] * @y_scl)
      stripe[:tiles].each do |tile|
        yield tile, coords
        coords[:y] += @y_scl
      end
      coords[:x] += @x_scl
    end
  end
end
