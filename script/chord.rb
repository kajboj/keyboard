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
