require './script/mappings'

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
  puts

  mac = diff_ascii_maps(ASCII_MAP_UK, ASCII_MAP_UK_MAC)

  puts "void macLayoutSetup() {"
  mappings.sort_by(&:to_i).each.with_index do |mapping, index|
    keystroke = mac[mapping.key]
    if keystroke
      puts "  chordMap[#{index}] = { 0b000000#{mapping.chord.binary}, #{keystroke[0].to_s.rjust(3)}, #{keystroke[1].to_s.ljust(5)}, #{keystroke[2].to_s.rjust(3)} }; /* #{mapping.key} */"
    end
  end
  puts '};'
end

def diff_ascii_maps(map1, map2)
  result = {}
  map1.each do |key, codes1|
    codes2 = map2[key]
    if codes1 != codes2
      result[key] = codes2
    end
  end
  result
end

mappings = Mappings.new.generate

if ARGV[0] == 'c'
  display_chords(free_chords)
elsif ARGV[0] == 'a'
  display_arduino(mappings)
else
  display_mappings(mappings)
end
