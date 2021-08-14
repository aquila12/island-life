# frozen_string_literal: true

module TileTypes

  class BaseTile < Tile
    def behaviour
      if @stats[:water]>0
        Lake
      elsif @stats[:flames]>0
        Waste
      elsif @stats[:vibes]>0
        Mountain
      end
    end
  end

  class Waste < BaseTile
    provides sand: 1
    appearance '#fc9'

    def behaviour
      super ||
      if @stats[:vegetation] > 2 || @stats[:rainfall] > 0
        Grass
      end
    end
  end

  class Grass < BaseTile
    provides vegetation: 1, grazing: 1
    appearance '#2f2'

    def behaviour
      super ||
      if @stats[:mana] > 5
        Glade
      elsif @stats[:vegetation] > 5 && @stats[:rainfall] > 0 || @stats[:vegetation] > 8
        Forest
      elsif  @stats[:vegetation] < 2
        Waste
      end
    end
  end

  class Forest < BaseTile
    provides vegetation: 2, trees: 1, cover: 1, forage: 1
    appearance '#2a2'

    def behaviour
      super ||
      if @stats[:vegetation] > 11 && @stats[:rainfall] > 0 || @stats[:vegetation] > 17
        OldForest
      elsif @stats[:vegetation] < 6
        Grass
      elsif @stats[:vegetation] < 2
        Waste
      end
    end
  end

  class OldForest < BaseTile
    provides vegetation: 4, trees: 2, cover: 2, mana: 1, forage: 0
    appearance '#252'

    def behaviour
      super ||
      if @stats[:vegetation] < 12
        Forest
      elsif @stats[:vegetation] < 6
        Grass
      elsif @stats[:vegetation] < 2
        Waste
      end
    end
  end

  class Mountain < BaseTile
    provides cliffs: 1
    appearance '#c'

    def behaviour
      Waste if @stats[:water] > 0
    end
  end

  class Lake < BaseTile
    provides fish: 1, coast: 1, land: -1
    appearance '#69c'

    def behaviour
      Waste if @stats[:vibes] > 0
    end

  end

  class Glade < BaseTile
    provides vegetation: 1, grazing: 1
    appearance '#af2'

    def behaviour
      super ||
      if @stats[:mana] < 6
        Grass
      end
    end
  end
end
