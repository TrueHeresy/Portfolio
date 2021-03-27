import java.util.Map;
import processing.sound.*;

Sound s = new Sound(this);
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);
SinOsc sin4 = new SinOsc(this);

/*
 * Define the root frequencies around A440Hz
 * Also available as an array
 */

float c4 = 261.63;
float cs4 = 277.18;
float d4 = 293.66;
float ds4 = 311.13;
float e4 = 329.63;
float f4 = 349.23;
float fs4 = 369.99;
float g4 = 392.00;
float gs4 = 415.30;
float a4 = 440.00;
float as4 = 446.16;
float b4 = 493.88;
float c5 = 523.25;
float cs5 = 554.37;
float d5 = 587.33;
float ds5 = 622.25;
float e5 = 659.26;
float f5 = 698.46;
float fs5 = 739.99;
float g5 = 783.99;
float gs5 = 830.61;
float a5 = 880.00;
float as5 = 932.33;
float b5 = 987.77;

float[] rootNotes = {c4, cs4, d4, ds4, e4, f4, fs4, g4, gs4, a4, as4, b4,
                     c5, cs5, d5, ds5, e5, f5, fs5, g5, gs5, a5, as5, b5};

/*
 * Define various intervals between notes
 */
float SEMITONE = pow(2, (1/12.0));
float TONE = pow(2, (2/12.0));
float MINORTHIRD = pow(2, (3/12.0));
float MAJORTHIRD = pow(2, (4/12.0));
float PERFECTFOURTH = pow(2, (5/12.0));
float DIMINISHEDFIFTH = pow(2, (6/12.0));
float PERFECTFIFTH = pow(2, (7/12.0));
float MINORSIXTH, AUGMENTEDFIFTH = pow(2, (8/12.0));
float MAJORSIXTH = pow(2, (9/12.0));
float MINORSEVENTH = pow(2, (10/12.0));
float MAJORSEVENTH = pow(2, (11/12.0));
float OCTAVE = 2;

/*
 * Set up required bits and bobs
 */
float rootNote = a4;
float note1, note2, note3, note4, note5, note6, note7, note8 = rootNote;
float[] currentScaleNotes = {note1, note2, note3, note4, note5, note6, note7, note8};
String currentTriadType = "Minor";
String currentScale = "Aeolian";
String currentKey = "A";
String[] modes = {"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"};

/*
 * Set up the intervals
 */
 HashMap<String, float[]> modeList = new HashMap<String, float[]>();

void setup() {
  size(500, 500);
  background(255);
  modeList.put("Aeolian", new float[] {TONE, SEMITONE, TONE, TONE, SEMITONE, TONE});
}

void draw() {
}

// Current method for switching chord type and note is just keyboard presses
void keyPressed() {
  // Up, down, left, right for major, minor, aurgmented, diminished
  if (key==CODED) {
    switch(keyCode) {
      case UP:
        stopChord();
        currentTriadType = "Major";
        playTriad(rootNote, currentTriadType);
        break;
      case DOWN:
        stopChord();
        currentTriadType = "Minor";
        playTriad(rootNote, currentTriadType);
        break;
      case LEFT:
        stopChord();
        currentTriadType = "Augmented";
        playTriad(rootNote, currentTriadType);
        break;
      case RIGHT:
        stopChord();
        currentTriadType = "Diminished";
        playTriad(rootNote, currentTriadType);
        break;
      default:
        stopChord();
        break;  
    }
  }
  else {
    // Quite simply corresponds to a note, or 'm' for a mode
    switch(key) {
      case 'a':
        stopChord();
        rootNote = a4;
        currentKey = "A";
        playTriad(rootNote, currentTriadType);
        break;
      case 'A':
        stopChord();
        rootNote = as4;
        currentKey = "As";
        playTriad(rootNote, currentTriadType);
        break;
      case 'b':
        stopChord();
        rootNote = b4;
        currentKey = "B";
        playTriad(rootNote, currentTriadType);
        break;
      case 'c':
        stopChord();
        rootNote = c4;
        currentKey = "C";
        playTriad(rootNote, currentTriadType);
        break;
      case 'C':
        stopChord();
        rootNote = cs4;
        currentKey = "Cs";
        playTriad(rootNote, currentTriadType);
        break;
      case 'd':
        stopChord();
        rootNote = d4;
        currentKey = "D";
        playTriad(rootNote, currentTriadType);
        break;
      case 'D':
        stopChord();
        rootNote = ds4;
        currentKey = "Ds";
        playTriad(rootNote, currentTriadType);
        break;
      case 'e':
        stopChord();
        rootNote = e4;
        currentKey = "E";
        playTriad(rootNote, currentTriadType);
        break;
      case 'f':
        stopChord();
        rootNote = f4;
        currentKey = "F";
        playTriad(rootNote, currentTriadType);
        break;
      case 'F':
        stopChord();
        rootNote = fs4;
        currentKey = "Fs";
        playTriad(rootNote, currentTriadType);
        break;
      case 'g':
        stopChord();
        rootNote = g4;
        currentKey = "G";
        playTriad(rootNote, currentTriadType);
        break;
      case 'G':
        stopChord();
        rootNote = gs4;
        currentKey = "Gs";
        playTriad(rootNote, currentTriadType);
        break;
      case 's':
        stopChord();
        playScale(rootNote);
        break;
      case 'S':
        stopChord();
        playScales(rootNote);
      default:
        stopChord();
        break;
    }
  }
}



// Called to play a chord, requires a root note and a chord type
void playTriad(float rootNote, String triadType) {
  
  switch(triadType) {
    case "Major":
      note1 = rootNote;
      note2 = note1 * MAJORTHIRD;
      note3 = note1 * PERFECTFIFTH;
      print("Chord is " + rootNote + " " + currentTriadType + ". ");
      break;
    case "Minor":
      note1 = rootNote;
      note2 = note1 * MINORTHIRD;
      note3 = note1 * PERFECTFIFTH;
      print("Chord is " + rootNote + " " + currentTriadType + ". ");
      break;
    case "Augmented":
      note1 = rootNote;
      note2 = note1 * MAJORTHIRD;
      note3 = note1 * AUGMENTEDFIFTH;
      print("Chord is " + rootNote + " " + currentTriadType + ". ");
      break;
    case "Diminished":
      note1 = rootNote;
      note2 = note1 * MINORTHIRD;
      note3 = note1 * DIMINISHEDFIFTH;
      print("Chord is " + rootNote + " " + currentTriadType + ". ");
      break;
    default:
      stopChord();
      break;    
  }
  // Play the calculated notes from the switch statment
  sin1.play(note1, 0.5);
  delay(250);
  sin2.play(note2, 0.5);
  delay(250);
  sin3.play(note3, 0.5);
}

// Stops the chord that's playing
void stopChord() {
  sin1.stop();
  sin2.stop();
  sin3.stop();
}

// Plays the current mode through once
void playScale(float rootNote) {
  //Set the scale and then play it
  setScale(rootNote);

  sin1.play(currentScaleNotes[0], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[1], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[2], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[3], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[4], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[5], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[6], 0.5);
  delay(250);
  sin1.play(currentScaleNotes[7], 0.5);
  delay(250);
  sin1.stop();
}

// Plays the current mode through once
void playScales(float rootNote) {
  //Set the scale and then play it
  for (int i = 0; i < rootNotes.length; ++i) {
    playScale(rootNotes[i]);
    delay(500);
  }
}

void setScale(float rootNote) {
 switch (currentScale){
    case "Ionian": // Equivalent to major scale
      currentScaleNotes[0] = rootNote;
      currentScaleNotes[1] = currentScaleNotes[0] * TONE;
      currentScaleNotes[2] = currentScaleNotes[1] * TONE;
      currentScaleNotes[3] = currentScaleNotes[2] * SEMITONE;
      currentScaleNotes[4] = currentScaleNotes[3] * TONE;
      currentScaleNotes[5] = currentScaleNotes[4] * TONE;
      currentScaleNotes[6] = currentScaleNotes[5] * TONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Dorian":
      currentScaleNotes[0] = rootNote * TONE;
      currentScaleNotes[1] = currentScaleNotes[0] * TONE;
      currentScaleNotes[2] = currentScaleNotes[1] * SEMITONE;
      currentScaleNotes[3] = currentScaleNotes[2] * TONE;
      currentScaleNotes[4] = currentScaleNotes[3] * TONE;
      currentScaleNotes[5] = currentScaleNotes[4] * TONE;
      currentScaleNotes[6] = currentScaleNotes[5] * SEMITONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Phrygian":
      currentScaleNotes[0] = rootNote * TONE;
      currentScaleNotes[1] = currentScaleNotes[0] * SEMITONE;
      currentScaleNotes[2] = currentScaleNotes[1] * TONE;
      currentScaleNotes[3] = currentScaleNotes[2] * TONE;
      currentScaleNotes[4] = currentScaleNotes[3] * TONE;
      currentScaleNotes[5] = currentScaleNotes[4] * SEMITONE;
      currentScaleNotes[6] = currentScaleNotes[5] * TONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Lydian":
      currentScaleNotes[0] = rootNote;
      currentScaleNotes[1] = currentScaleNotes[0] * TONE;
      currentScaleNotes[2] = currentScaleNotes[1] * TONE;
      currentScaleNotes[3] = currentScaleNotes[2] * TONE;
      currentScaleNotes[4] = currentScaleNotes[3] * SEMITONE;
      currentScaleNotes[5] = currentScaleNotes[4] * TONE;
      currentScaleNotes[6] = currentScaleNotes[5] * TONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Mixolydian":
      currentScaleNotes[0] = rootNote;
      currentScaleNotes[1] = currentScaleNotes[0] * TONE;
      currentScaleNotes[2] = currentScaleNotes[1] * TONE;
      currentScaleNotes[3] = currentScaleNotes[2] * SEMITONE;
      currentScaleNotes[4] = currentScaleNotes[3] * TONE;
      currentScaleNotes[5] = currentScaleNotes[4] * TONE;
      currentScaleNotes[6] = currentScaleNotes[5] * SEMITONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Aeolian": // Equivalent to minor scale
      currentScaleNotes[0] = rootNote;
      currentScaleNotes[1] = currentScaleNotes[0] * TONE;
      currentScaleNotes[2] = currentScaleNotes[1] * SEMITONE;
      currentScaleNotes[3] = currentScaleNotes[2] * TONE;
      currentScaleNotes[4] = currentScaleNotes[3] * TONE;
      currentScaleNotes[5] = currentScaleNotes[4] * SEMITONE;
      currentScaleNotes[6] = currentScaleNotes[5] * TONE;
      currentScaleNotes[7] = rootNote * 2;
    case "Locrian":
      currentScaleNotes[0] = rootNote;
      currentScaleNotes[1] = currentScaleNotes[0] * SEMITONE;
      currentScaleNotes[2] = currentScaleNotes[1] * TONE;
      currentScaleNotes[3] = currentScaleNotes[2] * TONE;
      currentScaleNotes[4] = currentScaleNotes[3] * SEMITONE;
      currentScaleNotes[5] = currentScaleNotes[4] * TONE;
      currentScaleNotes[6] = currentScaleNotes[5] * TONE;
      currentScaleNotes[7] = rootNote * 2;
    }
}