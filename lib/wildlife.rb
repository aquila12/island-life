# frozen_string_literal: true

# TODO: utility go elsewhere!
def table(heading, *data)
  data.map { Hash[heading.zip(data)] }
end

ANIMALS = table(
  %i[name, colour, home_needs, roaming_needs, spawn_chance],
  [:bear, '#630', { forage: 1 }, { fish:1, forage: 4 }, 1.0],
  [:buffalo, '#630', { grazing: 1 }, { grazing: 6 }, 1.0],
  [:Crab, '#630', { sand: 1 }, { grazing: 2 }, 1.0],
  [:Deer, '#630', { cover: 1 }, { grazing: 3 }, 1.0],
  [:Dragon, '#630', { cliffs: 1 }, { sand: 4 }, 1.0],
  [:Eagle, '#630', { cliffs: 1 }, { forage: 4 }, 1.0],
  [:Elk, '#630', { cover: 1 }, { cover: 6, forage: 4 }, 1.0],
  [:Ent, '#630', { mana: 1 }, { forage: 4 }, 1.0],
  [:Giant, '#630', { cliffs: 1 }, { cliffs: 4 }, 1.0],
  [:Goat, '#630', { grazing: 1 }, { cliffs: 4 }, 1.0],
  [:Griffin, '#630', { cliffs: 1 }, { cover: 8 }, 1.0],
  [:Kangaroo, '#630', { grazing: 1 }, { fish: 4 }, 1.0],
  [:Koala, '#630', { forage: 1 }, { fish: 4 }, 1.0],
  [:Mummy, '#630', { sand: 1 }, { cliffs: 4 }, 1.0],
  [:Naiads, '#630', { fish: 1 }, { mana: 6 }, 1.0],
  [:Tiger, '#630', { cover: 1 }, { grazing: 4 }, 1.0],
  [:Unicorn, '#630', { grazing: 1 }, { mana: 6 }, 1.0]
)
