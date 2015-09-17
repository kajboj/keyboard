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
