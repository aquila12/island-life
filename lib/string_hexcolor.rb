# Copyright 2021 Nick Moriarty
#
# This file is provided under the terms of the Eclipse Public License, the full
# text of which can be found in EPL-2.0.txt in the licenses directory of this
# repository.

# Monkey patch on String to do extract hex colour as an array [r, g, b, a]
class String
  def hexcolor
    return self[1..-1].hexcolor if start_with? '#'

    case length
    when 1 then c = Array.new(3, hex * 0x11)
    when 2 then c = Array.new(3, hex)
    when 3, 4 then c = chars.map { |c| c.hex * 0x11 }
    when 6, 8
      c = []
      buf = dup
      until buf.empty?
        c << buf.slice!(0,2).hex
      end
    else
      return [0, 0, 0, 255]
    end
    c.length < 4 ? c << 255 : c
  end
end
