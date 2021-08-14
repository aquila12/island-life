# frozen_string_literal: true

class Wildlife
  # TODO: utility go elsewhere!
  def self.table(heading, *data)
    data.map { |row| Hash[heading.zip(row)] }
  end

  ANIMALS = table(
    %i[name colour home_needs roaming_needs spawn_chance],
    [:buffalo, '#630', { grazing: 1 }, { grazing: 4 }, 1.0]
  )

  def initialize
    @animals = {}
  end

  attr_reader :animals

  def try_spawn(coord, home_stats, roaming_stats)
    return if @animals.has_key? coord.to_axial

    valid_spawns = ANIMALS.select do |rule|
      needs_met?(rule[:home_needs], home_stats) &&
      needs_met?(rule[:roaming_needs], roaming_stats)
    end

    return if valid_spawns.empty?

    animal = valid_spawns.sample
    spawn(coord, animal) if rand < animal[:spawn_chance]
  end

  def spawn(coord, animal)
    @animals[coord.to_axial] = {
      name: animal[:name],
      colour: animal[:colour].hexcolor,
      position: coord.to_point
    }
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
