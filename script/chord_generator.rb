# encoding: UTF-8

require 'set'
require './script/ascii_map'

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

class Chord
  attr_reader :keys
  def initialize(keys)
    @keys = keys
  end

  def to_s
    render(LEFT) + " " + render(RIGHT)
  end

  def binary
    render(LEFT, '1', '0') + render(RIGHT, '1', '0')
  end

  def to_i
    binary.to_i
  end

  def ==(other)
    @keys.sort == other.keys.sort
  end

  def comfort
    features = [
      possible?,
      !(include_left?(:pinky) && include_right?(:pinky)),
      one? && !include?(:pinky),
      two? && !include?(:pinky),
      one? && include?(:pinky),
      two? && include?(:pinky),
      !one_hand?,
      include?(:index),
      include?(:middle),
      include?(:thumb),
      include?(:ring),
      include?(:pinky)
    ]

    rank = 10**features.size
    features.inject(0) do |a, feature|
      a += b_to_i(feature) * rank
      rank = rank/10
      a
    end
  end

  private

  def possible?
    !(
      (
        include_left?(:pinky) &&
        include_left?(:middle) &&
        !include_left?(:ring)
      ) || (
        include_right?(:pinky) &&
        include_right?(:middle) &&
        !include_right?(:ring)
      )
    )
  end

  def any?(keys)
    (@keys - keys).size < @keys.size
  end

  def all?(keys)
    (@keys - keys).empty?
  end

  def one_hand?
    all?(LEFT) || all?(RIGHT)
  end

  def one?
    @keys.size == 1
  end

  def two?
    @keys.size == 2
  end

  def three?
    @keys.size == 3
  end

  def include_left?(finger)
    @keys.include?(left(finger))
  end

  def include_right?(finger)
    @keys.include?(right(finger))
  end

  def include?(finger)
    include_left?(finger) || include_right?(finger)
  end

  def b_to_i(bool)
    bool ? 1 : 0
  end

  def render(hand, positive = "O", negative = ".")
    hand.map do |finger|
      @keys.include?(finger) ? positive : negative
    end.join
  end
end

class Mapping
  attr_reader :key, :chord

  def initialize(key, chord)
    @key   = key
    @chord = chord
  end

  def to_s
    @key.ljust(12, ' ') + @chord.to_s
  end

  def to_i
    @chord.to_i
  end
end

def parse(fingers)
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

# KEY_LEFT_CTRL
# KEY_LEFT_SHIFT
# KEY_LEFT_ALT
# KEY_LEFT_GUI

fixed = {
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
  '{'           => parse('..OO. O....'),
  '|'           => parse('..OO. ..O..'),
  '}'           => parse('....O .OO..'),
  '~'           => parse('.O.O. O....'),
  '£'           => parse('....O .O..O'),
  '¬'           => parse('O.... OO...'),
}

#'KEY_F1' =>
#'KEY_F2' =>
#'KEY_F3' =>
#'KEY_F4' =>
#'KEY_F5' =>
#'KEY_F6' =>
#'KEY_F7' =>
#'KEY_F8' =>
#'KEY_F9' =>
#'KEY_F10' =>
#'KEY_F11' =>
#'KEY_F12' =>

free = [
  'e', 't', 'a', 'o', 'i', 'n', 's', 'r', 'h', 'l', 'd', 'c', 'u', 'm', 'f',
  'g', 'p', 'y', 'w', 'b', ',', '.', 'v', 'k', '-', '"', '\'', 'x', ';', '0',
  'j', '1', 'q', '=', '2', ':', 'z', '/', '*', '!', '?', '$', '3', '5', '4',
  '9', '8', '6', '7', '\\', '+', '|', '&', '%', '@', '#', '^', '`', '~', '£',
  'INSERT', 'DELETE', '¬'
] - fixed.keys

chords = (1..3).to_enum.map do |key_count|
  (0..9).to_a.combination(key_count).map do |chord|
    Chord.new(chord)
  end
end.flatten.sort_by(&:comfort).reverse

free_chords = subtract(chords, fixed.values)

mappings = fixed.map do |key, chord|
  Mapping.new(key, chord)
end

mappings += free.zip(free_chords[0..free.size-1]).map do |key, chord|
  Mapping.new(key, chord)
end

def display_mappings(mappings)
  mappings.sort_by(&:key).each.with_index do |mapping, i|
    puts "#{i.to_s.rjust(3, ' ')}  #{mapping}"
  end
end

def display_chords(chords)
  chords.each.with_index do |chord, i|
    puts "#{i.to_s.rjust(3, ' ')}  #{chord} #{chord.comfort.to_s.rjust(16, ' ')}"
  end
end

def display_arduino(mappings)
  size = mappings.size
  puts "static const int chordMapSize = #{size};"
  puts "Keystroke chordMap[chordMapSize] = {"

  mappings.sort_by(&:to_i).each do |mapping|
    keystroke = ASCII_MAP_UK[mapping.key]
    puts "  { 0b000000#{mapping.chord.binary}, #{keystroke[0].to_s.rjust(3)}, #{keystroke[1].to_s.ljust(5)}, #{keystroke[2].to_s.rjust(3)} }, /* #{mapping.key} */"
  end

  puts '};'
end

def macros(mappings)
  {
    parse('..OOO O....') => to_chords("bundle exec ".split(''), mappings),
    parse('..OOO .O...') => to_chords("git status".split('') << 'RETURN', mappings),
    parse('..OOO ..O..') => to_chords("git commit -m ''".split('') << 'LEFT_ARROW', mappings),
    parse('..OOO ...O.') => to_chords("git log --decorate --graph --oneline".split('') << 'RETURN', mappings),
  }
end

def display_macro(chord, mappings)
  puts "    // #{mappings.map(&:key).join}"
  puts "    case 0b000000#{chord.binary}:"
  mappings.each do |mapping|
    puts "      pressChord(0b000000#{mapping.chord.binary});";
    puts "      releaseChord(0b000000#{mapping.chord.binary});";
  end
  puts "      break;"
end

def to_chords(keys, mappings)
  keys.map do |key|
    to_chord(key, mappings)
  end
end

def to_chord(key, mappings)
  mappings.find do |mapping|
    mapping.key == key
  end
end

if ARGV[0] == 'c'
  display_chords(free_chords)
elsif ARGV[0] == 'a'
  display_arduino(mappings)
elsif ARGV[0] == 's'
  puts "void handleMacros(int chord) {"
  puts "  switch (chord) {"
  macros(mappings).each do |trigger_chord, chords|
    display_macro(trigger_chord, chords)
  end
  puts "  }"
  puts "}"
else
  display_mappings(mappings)
end
