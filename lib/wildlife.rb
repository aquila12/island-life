# frozen_string_literal: true

# TODO: utility go elsewhere!
def table(heading, *data)
  data.map { Hash[heading.zip(data)] }
end

ANIMALS = table(
  %i[name, colour, home_needs, roaming_needs, spawn_chance],
  [:buffalo, '#630', { grazing: 1 }, { grazing: 4 }, 1.0]
)
