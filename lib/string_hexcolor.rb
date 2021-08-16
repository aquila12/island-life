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
    when 1, 3, 4 then _hexcolor_rgba(*chars.map { |c| c.hex * 0x11 })
    when 2, 6, 8 then _hexcolor_rgba(*[self].pack('H*').unpack('C*'))
    else _hexcolor_rgba
    end
  end

  def _hexcolor_rgba(r = 0, g = r, b = r, a = 255)
    [r, g, b, a]
  end
end
