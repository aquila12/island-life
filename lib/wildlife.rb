# frozen_string_literal: true

# TODO: utility go elsewhere!
def table(heading, *data)
  data.map { Hash[heading.zip(data)] }
end

ANIMALS = table(
  %i[name, colour, home_needs, roaming_needs, spawn_chance],
  [:bear, '#960', { forage: 1 }, { fish:1, forage: 4 }, 1.0],
  [:buffalo, '#630', { grazing: 1 }, { grazing: 6 }, 1.0],
  [:Crab, '#f66', { sand: 1 }, { grazing: 2 }, 1.0],
  [:Deer, '#c93', { cover: 1 }, { grazing: 3 }, 1.0],
  [:Dragon, '#f00', { cliffs: 1 }, { sand: 4 }, 1.0],
  [:Eagle, '#b8d', { cliffs: 1 }, { forage: 4 }, 1.0],
  [:Elk, '#630', { cover: 1 }, { cover: 6, forage: 4 }, 1.0],
  [:Ent, '#0a0', { mana: 1 }, { forage: 4 }, 1.0],
  [:Giant, '#000', { cliffs: 1 }, { cliffs: 4 }, 1.0],
  [:Goat, '#f96', { grazing: 1 }, { cliffs: 4 }, 1.0],
  [:Griffin, '#909', { cliffs: 1 }, { cover: 8 }, 1.0],
  [:Kangaroo, '#00f', { grazing: 1 }, { fish: 4 }, 1.0],
  [:Koala, '#ccc', { forage: 1 }, { fish: 4 }, 1.0],
  [:Mummy, '#b90', { sand: 1 }, { cliffs: 4 }, 1.0],
  [:Naiads, '#0dd', { fish: 1 }, { mana: 6 }, 1.0],
  [:Tiger, '#f90', { cover: 1 }, { grazing: 4 }, 1.0],
  [:Unicorn, '#fff', { grazing: 1 }, { mana: 6 }, 1.0]
)
