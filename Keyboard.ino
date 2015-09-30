typedef struct {
  short chord;
  char code;
  bool shift;
  char fnCode;
} Keystroke;

#include "chord_map"
#include "pin_map_v2"

static const unsigned long MAC_LAYOUT_SWITCH_PIN = LEFT_THUMB_PIN;

static const unsigned long DEBOUNCE_DELAY = 10;
static const unsigned long CHORDING_DELAY = 50;

static const unsigned long STICKY_DELAY = 200;
static const unsigned long LOCK_DELAY = 500;

typedef int KeyEvent;
static const KeyEvent NOTHING_HAPPENED = 0;
static const KeyEvent JUST_PRESSED     = 1;
static const KeyEvent JUST_RELEASED    = 2;

static const int PRESSED  = HIGH;
static const int RELEASED = LOW;

typedef int ModifierState;
static const ModifierState OFF                    = 0;
static const ModifierState AWAITING_STICKY        = 1;
static const ModifierState STUCK_AWAITING_LOCK    = 2;
static const ModifierState HELD_AWAITING_LOCK     = 3;
static const ModifierState RELEASED_AWAITING_LOCK = 4;
static const ModifierState STUCK                  = 5;
static const ModifierState LOCKED                 = 6;
static const ModifierState HELD                   = 7;

typedef struct {
  void (*press)(char);
  void (*release)(char);
} ModifierHandler;

void pressNormalModifier(char code) {
  Keyboard.press(code);
};

void releaseNormalModifier(char code) {
  Keyboard.release(code);
};

ModifierHandler normalModifierHandler = {
  &pressNormalModifier,
  &releaseNormalModifier
};

boolean functionKeyPressed;

void pressFunctionKey(char code) {
  functionKeyPressed = true;
};

void releaseFunctionKey(char code) {
  functionKeyPressed = false;
};

ModifierHandler functionKeyHandler = {
  &pressFunctionKey,
  &releaseFunctionKey
};

typedef struct {
  int pin;
  char code;
  int mask;
  ModifierHandler *modifierHandler;
  unsigned long lastDebounceTime;
  int previousState;
  int state;
  KeyEvent event;
  ModifierState modifierState;
  unsigned long lastPressTime;
} Key;

Key allKeys[] = {
  { KEY_LEFT_CTRL_PIN,  (char) KEY_LEFT_CTRL,  0, &normalModifierHandler },
  { KEY_LEFT_SHIFT_PIN, (char) KEY_LEFT_SHIFT, 0, &normalModifierHandler },
  { KEY_LEFT_ALT_PIN,   (char) KEY_LEFT_ALT,   0, &normalModifierHandler },
  { KEY_LEFT_GUI_PIN,   (char) KEY_LEFT_GUI,   0, &normalModifierHandler },
  { KEY_FUNCTION_PIN,   0,                     0, &functionKeyHandler },
  { LEFT_PINKY_PIN,   0, 0b0000001000000000, 0 },
  { LEFT_RING_PIN,    0, 0b0000000100000000, 0 },
  { LEFT_MIDDLE_PIN,  0, 0b0000000010000000, 0 },
  { LEFT_INDEX_PIN,   0, 0b0000000001000000, 0 },
  { LEFT_THUMB_PIN,   0, 0b0000000000100000, 0 },
  { RIGHT_PINKY_PIN,  0, 0b0000000000010000, 0 },
  { RIGHT_RING_PIN,   0, 0b0000000000001000, 0 },
  { RIGHT_MIDDLE_PIN, 0, 0b0000000000000100, 0 },
  { RIGHT_INDEX_PIN,  0, 0b0000000000000010, 0 },
  { RIGHT_THUMB_PIN,  0, 0b0000000000000001, 0 },
};
static const int allKeyCount = sizeof(allKeys)/sizeof(Key);

static const Key functionKey = allKeys[4];

Key *modifiers[] = {
  &allKeys[0],
  &allKeys[1],
  &allKeys[2],
  &allKeys[3],
  &allKeys[4],
};
static const int modifierCount = sizeof(modifiers)/sizeof(Key*);

Key *keys[] = {
  &allKeys[ 5],
  &allKeys[ 6],
  &allKeys[ 7],
  &allKeys[ 8],
  &allKeys[ 9],
  &allKeys[10],
  &allKeys[11],
  &allKeys[12],
  &allKeys[13],
  &allKeys[14],
};
static const int keyCount = sizeof(keys)/sizeof(Key*);

static const int NO_KEY_PRESSED = 0;

unsigned long lastChordChangeTime;
int previousChord;
int chord;
boolean waitingForChord;
boolean chordTriggered;

void updateEvents() {
  for(int i=0; i<allKeyCount; i++) {
    Key *key = &allKeys[i];
    key->event = NOTHING_HAPPENED;

    int reading = digitalRead(key->pin);

    if (reading != key->previousState) {
      key->lastDebounceTime = millis();
    }

    if ((millis() - key->lastDebounceTime) > DEBOUNCE_DELAY) {
      if (reading != key->state) {
        if ((reading == HIGH) && (key->state == LOW)) {
          key->event = JUST_PRESSED;
        }

        if ((reading == LOW) && (key->state == HIGH)) {
          key->event = JUST_RELEASED;
        }

        key->state = reading;
      }
    }

    key->previousState = reading;
  }
}

void setup() {
  for(int i=0; i<allKeyCount; i++) {
    allKeys[i].lastDebounceTime = 0;
    allKeys[i].previousState = LOW;
    allKeys[i].state = LOW;
    allKeys[i].event = NOTHING_HAPPENED;
    allKeys[i].modifierState = OFF;
    allKeys[i].lastPressTime = 0;
    pinMode(allKeys[i].pin, INPUT);
  }

  lastChordChangeTime = 0;
  previousChord = 0;
  chord = 0;
  waitingForChord = false;
  chordTriggered = false;
  functionKeyPressed = false;

  if (digitalRead(MAC_LAYOUT_SWITCH_PIN) == HIGH) {
    macLayoutSetup();
  }

  Keyboard.begin();
}

void handleModifiers() {
  for(int i=0; i<modifierCount; i++) {
    Key *key = modifiers[i];

    if (millis() - key->lastPressTime > STICKY_DELAY) {
      if (key->modifierState == AWAITING_STICKY) {
        key->modifierState = HELD_AWAITING_LOCK;
      }
    };

    if (millis() - key->lastPressTime > LOCK_DELAY) {
      switch(key->modifierState) {
        case STUCK_AWAITING_LOCK:
          key->modifierState = STUCK;
          break;
        case HELD_AWAITING_LOCK:
          key->modifierState = HELD;
          break;
        case RELEASED_AWAITING_LOCK:
          key->modifierState = OFF;
          break;
      }
    };

    switch(key->event) {
      case JUST_RELEASED:
        switch(key->modifierState) {
          case AWAITING_STICKY:
            chordTriggered = false;
            key->modifierState = STUCK_AWAITING_LOCK;
            break;
          case HELD_AWAITING_LOCK:
            (*key->modifierHandler).release(key->code);
            key->modifierState = RELEASED_AWAITING_LOCK;
            break;
          case HELD:
            (*key->modifierHandler).release(key->code);
            key->modifierState = OFF;
            break;
        };
        break;
      case JUST_PRESSED:
        switch(key->modifierState) {
          case OFF:
            (*key->modifierHandler).press(key->code);
            key->lastPressTime = millis();
            key->modifierState = AWAITING_STICKY;
            break;
          case STUCK_AWAITING_LOCK:
            key->modifierState = LOCKED;
            break;
          case LOCKED:
            (*key->modifierHandler).release(key->code);
            key->modifierState = OFF;
            break;
          case STUCK:
            (*key->modifierHandler).release(key->code);
            key->modifierState = OFF;
            break;
          case RELEASED_AWAITING_LOCK:
            (*key->modifierHandler).press(key->code);
            key->modifierState = LOCKED;
            break;
        };
        break;
    };

    if (chordTriggered) {
      switch(key->modifierState) {
        case STUCK_AWAITING_LOCK:
          (*key->modifierHandler).release(key->code);
          key->modifierState = OFF;
          break;
        case STUCK:
          (*key->modifierHandler).release(key->code);
          key->modifierState = OFF;
          break;
      }
    }
  }
}

void handleKeys() {
  for(int i=0; i<keyCount; i++) {
    Key *key = keys[i];
    switch(key->event) {
      case JUST_PRESSED:
        chord = chord | key->mask;
        break;
      case JUST_RELEASED:
        chord = chord ^ key->mask;
        break;
    }
  }
}

int countOnes(int n) {
  int i = n;
  int count = 0;

  while (i > 0) {
    if (i % 2 == 1) {
      count += 1;
    }
    i /= 2;
  }
  return count;
}

Keystroke* lookupChord(int chord) {
  int imin = 0;
  int imax = chordMapSize;

  while (imin <= imax) {
    int imid = imin + ((imax - imin) / 2);

    if(chordMap[imid].chord == chord)
      return &chordMap[imid];
    else if (chordMap[imid].chord < chord)
      imin = imid + 1;
    else
      imax = imid - 1;
  }
  return &chordMap[0];
}

void pressChord(int chord) {
  Keystroke* k = lookupChord(chord);
  if (functionKeyPressed) {
    Keyboard.press1(k->fnCode, false);
  } else {
    Keyboard.press1(k->code, k->shift);
  }
  chordTriggered = true;
  waitingForChord = false;
}

void releaseChord(int chord) {
  Keystroke* k = lookupChord(chord);
  Keyboard.release1(k->code, k->shift);
  if (k->fnCode != k->code) {
    Keyboard.release1(k->fnCode, false);
  }
}

void processChord() {
  if (chord != previousChord) {
    if (previousChord != NO_KEY_PRESSED) {
      releaseChord(previousChord);
    }

    lastChordChangeTime = millis();

    if (countOnes(chord) > countOnes(previousChord)) {
      waitingForChord = true;
    } else {
      if (waitingForChord) {
        pressChord(previousChord);
        releaseChord(previousChord);
      }
    }

    previousChord = chord;
  } else {
    if (waitingForChord) {
      if (millis() - lastChordChangeTime > CHORDING_DELAY) {
        pressChord(chord);
      }
    }
  }
}

void loop() {
  updateEvents();

  handleKeys();
  processChord();

  handleModifiers();
}
