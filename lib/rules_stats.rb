# frozen_string_literal: true

module RulesStats
  ACTION_STATS = {
    rain: { rainfall: 1 }
  }

  TILE_STATS = {
    waste: {},
    grass: {vegetation: 1},
    forest: {vegetation: 2},
    old_forest: {vegetation: 4}
  }

  def check_update(tile, stats)
    case tile[:tile]
    when :waste
      :grass if stats[:vegetation] > 1 || stats[:rainfall] > 0
    when :grass
      if stats[:vegetation] > 5 || stats[:rainfall] > 0
        :forest
      elsif stats[:vegetation] < 2
        :waste
      end
    when :forest
      if stats[:vegetation] > 11 || stats[:rainfall] > 0
        :old_forest
      elsif stats[:vegetation] < 6
        :grass
      elsif stats[:vegetation] < 2
        :waste
      end
    when :old_forest
      if stats[:vegetation] < 12
        :forest
      elsif stats[:vegetation] < 6
        :grass
      elsif stats[:vegetation] < 2
        :waste
      end
    end
  end

  module_function :check_update
end
