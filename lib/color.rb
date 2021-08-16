# Copyright 2021 Nick Moriarty
#
# This file is provided under the terms of the Eclipse Public License, the full
# text of which can be found in EPL-2.0.txt in the licenses directory of this
# repository.

# Encapsulation of colour conversion from hex string, and formatting it
class Color
  class << self
    def hex(string)
      return hex(string[1..-1]) if string.start_with? '#'

      case string.length
      when 1, 3, 4 then new(*string.chars.map { |c| c.hex * 0x11 })
      when 2, 6, 8 then new(*[string].pack('H*').unpack('C*'))
      else new
      end
    end

    alias [] hex

    def gray(v)
      new(v, v, v)
    end
  end

  def initialize(r = 0, g = r, b = r, a = 255)
    @r, @g, @b, @a = r, g, b, a
  end

  attr_accessor :r, :g, :b, :a

  def rgb
    [@r, @g, @b]
  end

  def rgba
    [@r, @g, @b, @a]
  end

  def argb
    [@a, @r, @g, @b]
  end

  def to_h
    { r: @r, g: @g, b: @b, a: @a }
  end

  def to_s
    '#%02x%02x%02x%02x' % rgba
  end
end

# Self-test
raise 'Fail: Color.hex' unless Color.hex('#3').rgba == [51, 51, 51, 255]
raise 'Fail: Color.gray' unless Color.gray(20).rgba == [20, 20, 20, 255]
raise 'Fail: Color[] (1 char)' unless Color['#3'].rgba == [51, 51, 51, 255]
raise 'Fail: Color[] (2 char)' unless Color['#7f'].rgba == [127, 127, 127, 255]
raise 'Fail: Color[] (3 char)' unless Color['#3c0'].rgba == [51, 204, 0, 255]
raise 'Fail: Color[] (4 char)' unless Color['#fc0a'].rgba == [255, 204, 0, 170]
raise 'Fail: Color[] (6 char)' unless Color['#ffc007'].rgba == [255, 192, 7, 255]
raise 'Fail: Color[] (8 char)' unless Color['#ffc00780'].rgba == [255, 192, 7, 128]
raise 'Fail: Color#rgb' unless Color['#3c0'].rgb == [51, 204, 0]
raise 'Fail: Color#argb' unless Color['#3c0'].argb == [255, 51, 204, 0]
raise 'Fail: Color#to_h' unless Color['#3c0'].to_h == { a: 255, r: 51, g: 204, b: 0 }
raise 'Fail: Color#to_s' unless Color['#ffc00780'].rgba == [255, 192, 7, 128]
