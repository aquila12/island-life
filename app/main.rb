# frozen_string_literal: true

require 'lib/requires.rb'

def tick(args)
  $game = @game = Game.new(args) if args.tick_count.zero?
  @game.tick
end
