# frozen_string_literal: true

module TileTypes
  ACTION_provides = {
    rain: { rainfall: 1 }
  }

  class Waste < Tile
    appearance '#fc9'

    def behaviour
      replace_with Grass if vegetation > 1 || rainfall > 0
    end
  end

  class Grass < Tile
    provides vegetation: 1
    appearance '#2f2'

    def behaviour
      if vegetation > 5 || rainfall > 0
        replace_with Forest
      elsif vegetation < 2
        replace_with Waste
      end
    end
  end

  class Forest < Tile
    provides vegetation: 2
    appearance '#2a2'

    def behaviour
      if vegetation > 11 || vegetation > 0
        replace_with OldForest
      elsif vegetation < 6
        replace_with Grass
      elsif vegetation < 2
        replace_with Waste
      end
    end
  end

  class OldForest < Tile
    provides vegetation: 4
    appearance '#252'

    def behaviour
      if vegetation < 12
        replace_with Forest
      elsif vegetation < 6
        replace_with Grass
      elsif vegetation < 2
        replace_with Waste
      end
    end
  end
end
