# frozen_string_literal: true

module TileTypes
  class Waste < Tile
    provides sand: 1
    appearance '#fc9'

    def behaviour
      replace_with Grass if @stats[:vegetation] > 2 || @stats[:rainfall] > 0
    end
  end

  class Grass < Tile
    provides vegetation: 1, grazing: 1
    appearance '#2f2'

    def behaviour
      if @stats[:mana] > 5
        replace_with Glade
      elsif @stats[:vegetation] > 5 && @stats[:rainfall] > 0 || @stats[:vegetation] > 8
        replace_with Forest
      elsif  @stats[:vegetation] < 2
        replace_with Waste
      end
    end
  end

  class Forest < Tile
    provides vegetation: 2, trees: 1, cover: 1, forage: 1
    appearance '#2a2'

    def behaviour
      if @stats[:vegetation] > 11 && @stats[:rainfall] > 0 || @stats[:vegetation] > 17
        replace_with OldForest
      elsif @stats[:vegetation] < 6
        replace_with Grass
      elsif @stats[:vegetation] < 2
        replace_with Waste
      end
    end
  end

  class OldForest < Tile
    provides vegetation: 4, trees: 2, cover: 2, mana: 1, forage: 0
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

  class Mountain < Tile
    provides cliffs: 1
    appearance '#c'

    def behaviour
    end
  end

  class Lake < Tile
    provides fish: 1, coast: 1, land: -1
    appearance '#69c'

    def behaviour
    end
  end

  class Glade < Tile
    provides vegetation: 1, grazing: 1
    appearance '#af2'

    def behaviour
      if @stats[:mana] < 6
        replace_with Grass
      end
    end
  end
end
