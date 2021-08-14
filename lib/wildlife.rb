# frozen_string_literal: true

# TODO: utility go elsewhere!
def table(heading, *data)
  data.map { Hash[heading.zip(data)] }
end

ANIMALS = table(
  %i[name colour home_needs roaming_needs spawn_chance],
  [:bear, '#960', { forage: 1 }, { fish:1, forage: 4 }, 1.0],
  [:buffalo, '#630', { grazing: 1 }, { grazing: 6 }, 1.0],
  [:crab, '#f66', { sand: 1 }, { grazing: 2 }, 1.0],
  [:deer, '#c93', { cover: 1 }, { grazing: 3 }, 1.0],
  [:dragon, '#f00', { cliffs: 1 }, { sand: 4 }, 1.0],
  [:eagle, '#b8d', { cliffs: 1 }, { forage: 4 }, 1.0],
  [:elk, '#630', { cover: 1 }, { cover: 6, forage: 4 }, 1.0],
  [:ent, '#0a0', { mana: 1 }, { forage: 4 }, 1.0],
  [:giant, '#000', { cliffs: 1 }, { cliffs: 4 }, 1.0],
  [:goat, '#f96', { grazing: 1 }, { cliffs: 4 }, 1.0],
  [:griffin, '#909', { cliffs: 1 }, { cover: 8 }, 1.0],
  [:kangaroo, '#00f', { grazing: 1 }, { fish: 4 }, 1.0],
  [:koala, '#ccc', { forage: 1 }, { fish: 4 }, 1.0],
  [:kraken, '#636', { fish: 1}, { fish: 6}, 1.0]
  [:mummy, '#b90', { sand: 1 }, { cliffs: 4 }, 1.0],
  [:naiads, '#0dd', { fish: 1 }, { mana: 6 }, 1.0],
  [:tiger, '#f90', { cover: 1 }, { grazing: 4 }, 1.0],
  [:unicorn, '#fff', { grazing: 1 }, { mana: 6 }, 1.0]
)
