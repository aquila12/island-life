# frozen_string_literal: true

require 'lib/game.rb'

def tick(args)
  $game = @game = Game.new(args) if args.tick_count.zero?
  f = args.tick_count % 256
  @game.tick
end
