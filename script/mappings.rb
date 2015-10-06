# encoding: UTF-8

FINGERS = {
  left: {
    pinky:  0,
    ring:   1,
    middle: 2,
    index:  3,
    thumb:  4
  },
  right: {
    thumb:  5,
    index:  6,
    middle: 7,
    ring:   8,
    pinky:  9
  }
}

LEFT  = FINGERS[:left].values
RIGHT = FINGERS[:right].values

def left(finger)
  FINGERS[:left][finger]
end

def right(finger)
  FINGERS[:right][finger]
end

require 'set'
require './script/ascii_map'
require './script/chord'
require './script/mapping'

class Mappings
  def self.parse(fingers)
    fs = fingers.gsub(' ', '').split('').map.with_index do |f, index|
      f == 'O' ? index : nil
    end.compact
    Chord.new(fs)
  end

  def subtract(a1, a2)
    result = []
    a1.each do |e|
      if !a2.find {|x| x == e}
        result << e
      end
    end
    result
  end

  FIXED = {
    ' '           => parse('....O .....'),
    '!'           => parse('OO... .....'),
    '"'           => parse('.O..O .....'),
    '#'           => parse('...OO ...O.'),
    '$'           => parse('...O. ..OO.'),
    '%'           => parse('....O .O.O.'),
    '&'           => parse('..OO. .O...'),
    '('           => parse('O.... ..O..'),
    ')'           => parse('..O.. ....O'),
    '*'           => parse('..... ...OO'),
    '+'           => parse('..O.. .OO..'),
    ','           => parse('.O.O. .....'),
    '-'           => parse('..... O..O.'),
    '.'           => parse('..... O.O..'),
    '/'           => parse('O...O .....'),
    '0'           => parse('O.... .O...'),
    '1'           => parse('O.... O....'),
    '2'           => parse('..... .O..O'),
    '3'           => parse('..O.. .O.O.'),
    '4'           => parse('.OO.. .O...'),
    '5'           => parse('.O.O. ..O..'),
    '6'           => parse('O.... .OO..'),
    '7'           => parse('O..O. ..O..'),
    '8'           => parse('..OO. ....O'),
    '9'           => parse('..O.. .O..O'),
    ':'           => parse('O..O. .....'),
    ';'           => parse('...O. ....O'),
    '<'           => parse('..O.. OO...'),
    '='           => parse('O.... ...O.'),
    '>'           => parse('...OO ..O..'),
    '?'           => parse('...O. O.O..'),
    '@'           => parse('...O. O..O.'),
    'BACKSPACE'   => parse('..... .O...'),
    'DELETE'      => parse('...OO ....O'),
    'DOWN_ARROW'  => parse('..O.. .O...'),
    'END'         => parse('..O.O ...O.'),
    'ESC'         => parse('....O O....'),
    'HOME'        => parse('..OOO .....'),
    'INSERT'      => parse('...O. O...O'),
    'LEFT_ARROW'  => parse('..OO. .....'),
    'PAGE_DOWN'   => parse('..O.O .O...'),
    'PAGE_UP'     => parse('..O.O ..O..'),
    'RETURN'      => parse('...O. .O...'),
    'RIGHT_ARROW' => parse('..O.. ...O.'),
    'TAB'         => parse('..O.O .....'),
    'UP_ARROW'    => parse('..O.. ..O..'),
    '['           => parse('.O... .OO..'),
    '\''          => parse('..... ....O'),
    '\\'          => parse('...O. .OO..'),
    ']'           => parse('..OO. ...O.'),
    '^'           => parse('.O... OO...'),
    '_'           => parse('....O .O...'),
    '`'           => parse('.O..O .O...'),
    'a'           => parse('..O.. .....'),
    'b'           => parse('..... .O.O.'),
    'c'           => parse('..O.. O....'),
    'd'           => parse('....O ..O..'),
    'e'           => parse('...O. .....'),
    'f'           => parse('.O... O....'),
    'g'           => parse('.O... ...O.'),
    'h'           => parse('...O. ...O.'),
    'i'           => parse('..... ...O.'),
    'j'           => parse('....O ....O'),
    'k'           => parse('.OO.. .....'),
    'l'           => parse('.O... .O...'),
    'm'           => parse('....O ...O.'),
    'n'           => parse('.O... .....'),
    'o'           => parse('..... O....'),
    'p'           => parse('..... .OO..'),
    'q'           => parse('.O... ....O'),
    'r'           => parse('...O. O....'),
    's'           => parse('...O. ..O..'),
    't'           => parse('..... ..O..'),
    'u'           => parse('.O... ..O..'),
    'v'           => parse('..... ..OO.'),
    'w'           => parse('...OO .....'),
    'x'           => parse('O.... .....'),
    'y'           => parse('..... OO...'),
    'z'           => parse('..... O...O'),
    '{'           => parse('....O .OO..'),
    '|'           => parse('..OO. ..O..'),
    '}'           => parse('..OO. O....'),
    '~'           => parse('.O.O. O....'),
    '£'           => parse('....O .O..O'),
    '¬'           => parse('O.... OO...'),
  }

  FREE = [
    'e', 't', 'a', 'o', 'i', 'n', 's', 'r', 'h', 'l', 'd', 'c', 'u', 'm', 'f',
    'g', 'p', 'y', 'w', 'b', ',', '.', 'v', 'k', '-', '"', '\'', 'x', ';', '0',
    'j', '1', 'q', '=', '2', ':', 'z', '/', '*', '!', '?', '$', '3', '5', '4',
    '9', '8', '6', '7', '\\', '+', '|', '&', '%', '@', '#', '^', '`', '~', '£',
    'INSERT', 'DELETE', '¬'
  ] - FIXED.keys


  def generate
    chords = (1..3).to_enum.map do |key_count|
      (0..9).to_a.combination(key_count).map do |chord|
        Chord.new(chord)
      end
    end.flatten.sort_by(&:comfort).reverse

    free_chords = subtract(chords, FIXED.values)

    mappings = FIXED.map do |key, chord|
      Mapping.new(key, chord)
    end

    mappings += FREE.zip(free_chords[0..FREE.size-1]).map do |key, chord|
      Mapping.new(key, chord)
    end

    mappings
  end
end
