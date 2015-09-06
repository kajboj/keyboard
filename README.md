Build arduino
```
cd Arduino/build
ant
```

Build arduino sketch
```
make
```

Upload sketch to the device
```
make upload
```

Generate human readable layout
```
ruby script/chord_generator.rb
```

List unused chords
```
ruby script/chord_generator.rb c
```

Generate layout for arduino
```
ruby script/chord_generator.rb a
```
