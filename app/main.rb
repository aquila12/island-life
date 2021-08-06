# frozen_string_literal: true

require 'lib/cube_coord.rb'

def tick(args)
  $game = @game = CubeCoord.new(args) if args.tick_count.zero?
  f = args.tick_count % 256
  @game.tick
end
