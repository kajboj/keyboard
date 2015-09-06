# Arduino Make file. Refer to https://github.com/sudar/Arduino-Makefile

BOARD_TAG    = leonardo
MONITOR_PORT = /dev/ttyACM0
ARDUINO_DIR  = /home/kajboj/code/Arduino/build/linux/work
ARDUINO_VERSION = 165
include Arduino-Makefile/Arduino.mk
