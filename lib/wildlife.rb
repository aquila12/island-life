# frozen_string_literal: true

class Wildlife
  # TODO: utility go elsewhere!
  def self.table(heading, *data)
    h = [:id] + heading
    data.map.with_index do |row, id|
      Hash[h.zip([id] + row)]
    end
  end

  SPAWN_MULT = 1
  ANIMALS = table(
    %i[name colour home_needs roaming_needs spawn_chance],
    [:bear, '#960', { forage: 1 }, { fish:1, forage: 4 }, 0.2],
    [:buffalo, '#630', { grazing: 1 }, { grazing: 4 }, 0.02],
    [:crab, '#f66', { sand: 1 }, { coast: 2, grazing: 2 }, 0.02],
    [:deer, '#c93', { cover: 1 }, { cover: 3, grazing: 2 }, 0.2],
    [:dragon, '#f00', { cliffs: 1 }, { sand: 4 }, 0.2],
    [:eagle, '#b8d', { cliffs: 1 }, { forage: 4 }, 0.2],
    [:elk, '#ff0', { cover: 1 }, { cover: 6, forage: 4 }, 0.2],
    [:ent, '#0a0', { mana: 1 }, { forage: 3 }, 1.0],
    [:giant, '#000', { cliffs: 1 }, { cliffs: 4 }, 0.2],
    [:goat, '#f96', { grazing: 1 }, { cliffs: 4 }, 0.2],
    [:griffin, '#909', { cliffs: 1 }, { mana: 4 }, 0.2],
    [:kangaroo, '#00f', { grazing: 1 }, { coast: 4 }, 0.2],
    [:koala, '#ccc', { forage: 1 }, { coast: 4 }, 0.2],
    [:kraken, '#636', { fish: 1}, { fish: 6}, 0.2],
    [:mummy, '#b90', { sand: 1 }, { cliffs: 4 }, 0.2],
    [:naiads, '#0dd', { fish: 1 }, { mana: 6 }, 0.2],
    [:tiger, '#f90', { cover: 1 }, { grazing: 3 }, 0.2],
    [:unicorn, '#fff', { grazing: 1 }, { mana: 6 }, 0.2]
  )

  def initialize
    @animals = {}
    init_registry
  end

  def animal_at(axial)
    return '' unless @animals.key? axial
    @animals[axial][:name].to_s
  end

  def init_registry
    @registry = {}
    ANIMALS.each_with_index do |a, i|
      row, col = i.divmod(5)
      @registry[a[:name]] = {
        seen: false,
        solid: [1 + 2 * col, 62 - 2 * row, 1, 1, *a[:colour].hexcolor]
      }
    end
  end

  def do_update(coord, home_stats, roaming_stats)
    a = coord.to_axial
    animal = @animals[a]
    if animal
      @animals.delete a unless can_survive? animal, home_stats, roaming_stats
    else
      animal = ANIMALS.select { |a| can_survive? a, home_stats, roaming_stats }.sample
      return unless animal

      @animals[a] = realize(animal, coord) if rand < animal[:spawn_chance] * SPAWN_MULT
    end
  end

  def can_survive?(animal, home_stats, roaming_stats)
    needs_met?(animal[:home_needs], home_stats) &&
    needs_met?(animal[:roaming_needs], roaming_stats)
  end

  def realize(animal, coord)
    y, x = animal[:id].divmod(5)
    placement = {
      tile: [7 * x, 5 * y],
      colour: animal[:colour].hexcolor,
      position: coord.to_point,
    }

    @registry[animal[:name]][:seen] = true
    animal.merge(placement)
  end

  def draw(outputs)
    draw_registry(outputs)
    draw_animals(outputs)
  end

  def draw_registry(outputs)
    @registry.each_value do |entry|
      outputs.solids << entry[:solid] if entry[:seen]
    end
  end

  def draw_animals(outputs)
    @animals.each_value do |animal|
      centre = animal[:position]
      tile = animal[:tile]
      outputs.sprites << {
        x: centre.x - 3, y: centre.y - 2, w: 7, h: 5,
        tile_x: tile.x, tile_y: tile.y, tile_w: 7, tile_h: 5,
        path: 'resources/animals.png'
      }
    end
  end

  def needs_met?(needs, stats)
    needs.all? do |need, amount|
      stats[need] >= amount
    end
  end
end
