# frozen_string_literal: true

class Wildlife
  # TODO: utility go elsewhere!
  def self.table(heading, *data)
    data.map { |row| Hash[heading.zip(row)] }
  end

  ANIMALS = table(
    %i[name colour home_needs roaming_needs spawn_chance],
    [:bear, '#960', { forage: 1 }, { fish:1, forage: 4 }, 0.2],
    [:buffalo, '#630', { grazing: 1 }, { grazing: 4 }, 0.2],
<<<<<<< HEAD
    [:crab, '#f66', { sand: 1 }, { grazing: 2 }, 0.2],
    [:deer, '#c93', { cover: 1 }, { grazing: 3 }, 0.2],
    [:dragon, '#f00', { cliffs: 1 }, { sand: 4 }, 0.2],
    [:eagle, '#b8d', { cliffs: 1 }, { forage: 4 }, 0.2],
    [:elk, '#ff0', { cover: 1 }, { cover: 6, forage: 4 }, 0.2],
    [:ent, '#0a0', { mana: 1 }, { forage: 4 }, 1.0],
    [:giant, '#000', { cliffs: 1 }, { cliffs: 4 }, 0.2],
    [:goat, '#f96', { grazing: 1 }, { cliffs: 4 }, 0.2],
    [:griffin, '#909', { cliffs: 1 }, { cover: 8 }, 0.2],
    [:kangaroo, '#00f', { grazing: 1 }, { fish: 4 }, 0.2],
    [:koala, '#ccc', { forage: 1 }, { fish: 4 }, 0.2],
    [:kraken, '#636', { fish: 1}, { fish: 6}, 0.2],
    [:mummy, '#b90', { sand: 1 }, { cliffs: 4 }, 0.2],
    [:naiads, '#0dd', { fish: 1 }, { mana: 6 }, 0.2],
    [:tiger, '#f90', { cover: 1 }, { grazing: 4 }, 0.2],
    [:unicorn, '#fff', { grazing: 1 }, { mana: 6 }, 0.2]
=======
    [:Crab, '#f66', { sand: 1 }, { grazing: 2 }, 0.2],
    [:Deer, '#c93', { cover: 1 }, { grazing: 3 }, 0.2],
    [:Dragon, '#f00', { cliffs: 1 }, { sand: 4 }, 0.2],
    [:Eagle, '#b8d', { cliffs: 1 }, { forage: 4 }, 0.2],
    [:Elk, '#ff0', { cover: 1 }, { cover: 6, forage: 4 }, 0.2],
    [:Ent, '#0a0', { mana: 1 }, { forage: 4 }, 1.0],
    [:Giant, '#000', { cliffs: 1 }, { cliffs: 4 }, 0.2],
    [:Goat, '#f96', { grazing: 1 }, { cliffs: 4 }, 0.2],
    [:Griffin, '#909', { cliffs: 1 }, { cover: 8 }, 0.2],
    [:Kangaroo, '#00f', { grazing: 1 }, { fish: 4 }, 0.2],
    [:Koala, '#ccc', { forage: 1 }, { fish: 4 }, 0.2],
    [:kraken, '#636', { fish: 1}, { fish: 6}, 0.2],
    [:Mummy, '#b90', { sand: 1 }, { cliffs: 4 }, 0.2],
    [:Naiads, '#0dd', { fish: 1 }, { mana: 6 }, 0.2],
    [:Tiger, '#f90', { cover: 1 }, { grazing: 4 }, 0.2],
    [:Unicorn, '#fff', { grazing: 1 }, { mana: 6 }, 0.2]
>>>>>>> efed2df7a2d054c9462ac45019300e0055261e34
  )

  def initialize
    @animals = {}
  end

  attr_reader :animals

  def do_update(coord, home_stats, roaming_stats)
    a = coord.to_axial
    animal = @animals[a]
    if animal
      @animals.delete a unless can_survive? animal, home_stats, roaming_stats
    else
      animal = ANIMALS.select { |a| can_survive? a, home_stats, roaming_stats }.sample
      return unless animal

      @animals[a] = realize(animal, coord) if rand < animal[:spawn_chance]
    end
  end

  def can_survive?(animal, home_stats, roaming_stats)
    needs_met?(animal[:home_needs], home_stats) &&
    needs_met?(animal[:roaming_needs], roaming_stats)
  end

  def realize(animal, coord)
    placement = {
      colour: animal[:colour].hexcolor,
      position: coord.to_point
    }

    animal.merge(placement)
  end

  def draw(outputs)
    @animals.each_value do |animal|
      centre = animal[:position]
      r, g, b, a = animal[:colour]
      outputs.sprites << {
        x: centre.x - 1, y: centre.y - 1, w: 3, h: 3,
        r: r, g: g, b: b, a: a, path: 'resources/animal.png'
      }
    end
  end

  def needs_met?(needs, stats)
    needs.all? do |need, amount|
      stats[need] >= amount
    end
  end
end
