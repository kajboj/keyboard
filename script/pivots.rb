require './script/mappings'

mappings = Mappings.new.generate

class Word
  attr_reader :pivots, :word

  def initialize(s, mappings)
    @word = s
    @mappings = mappings
    @pivots = find_pivots(s)
  end

  def to_s
    @word.ljust(20) + @pivots.join(', ')
  end

  private

  def find(char)
    @mappings.find do |mapping|
      mapping.key == char
    end
  end

  def indexes1(binary)
    r = []
    binary.split('').each.with_index do |b, i|
      r << i if b == '1'
    end
    r
  end

  def find_pivots(word)
    mapping = word.split('').map do |char|
      find(char)
    end

    ps = []
    prev = mapping.first
    p = prev.key

    mapping[1..-1].each do |mapping|
      prev1s  = indexes1(prev.chord.binary)
      mapping1s = indexes1(mapping.chord.binary)
      if (mapping1s.size >= prev1s.size) && (mapping1s - prev1s).size < mapping1s.size
        p += mapping.key
      else
        ps << p if p.size > 1
        p = mapping.key
      end

      prev = mapping
    end

    ps << p if p.size > 1

    ps
  end
end

words = File.read(ARGV[0] || 'script/words').split("\n")

words = words.map do |s|
  Word.new(s, mappings)
end

puts words
