# frozen_string_literal: true

module TileTypes
  class Waste < Tile
    appearance '#fc9'

    def behaviour
      replace_with Grass if @stats[:vegetation] > 1 || @stats[:rainfall] > 0
    end
  end

  class Grass < Tile
    provides vegetation: 1
    appearance '#2f2'

    def behaviour
      if @stats[:vegetation] > 5 && @stats[:rainfall] > 0 || @stats[:vegetation] > 7
        replace_with Forest
      elsif  @stats[:vegetation] < 2
        replace_with Waste
      end
    end
  end

  class Forest < Tile
    provides vegetation: 2
    appearance '#2a2'

    def behaviour
      if @stats[:vegetation] > 11 && @stats[:rainfall] > 0 || @stats[:vegetation] > 15
        replace_with OldForest
      elsif @stats[:vegetation] < 6
        replace_with Grass
      elsif @stats[:vegetation] < 2
        replace_with Waste
      end
    end
  end

  class OldForest < Tile
    provides vegetation: 4
    appearance '#252'

    def behaviour
      if @stats[:vegetation] < 12
        replace_with Forest
      elsif @stats[:vegetation] < 6
        replace_with Grass
      elsif @stats[:vegetation] < 2
        replace_with Waste
      end
    end
  end
end
