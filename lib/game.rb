# frozen_string_literal: true

require 'lib/hex_tile_map.rb'

# Class to encapsulate the whole game state
class Game
  COLOURS = {
    blue: [64, 64, 192],
    yellow: [255, 192, 0]
  }

  TILE_H = 30
  TILE_W = (0.866 * TILE_H).round

  def initialize(args)
    @args = args
    @map = HexTileMap.new(15, 15, shape: :long_odds, default: COLOURS[:blue])
  end

  def tick
    inputs
    draw
  end

  def inputs
    inp = @args.inputs
    if inp.mouse.click
      c = inp.mouse.click
      p = c.point.x.to_f / TILE_W
      q = c.point.y.to_f / TILE_H
      @map.set_tile(p, q, COLOURS[:yellow])
    end
  end

  def draw
    @map.each_tile(0, 0, TILE_W, TILE_H) do |tile, coords|
      x = coords[:p]
      y = coords[:q]
      @args.outputs.solids << [x, y, TILE_W, TILE_H, *tile]
      @args.outputs.borders << [x, y, TILE_W + 1, TILE_H + 1, 160]
    end
  end
end
