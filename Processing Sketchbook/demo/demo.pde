import java.util.*;
import processing.sound.*;

// The oscillators and 'sound' that play the notes/chords
Sound s = new Sound(this);
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);
SinOsc sin4 = new SinOsc(this);
SinOsc sin5 = new SinOsc(this);

// Note maps
HashMap<String, Float> noteMap = new HashMap<String, Float>();
LinkedHashMap<Float, String> frequencyToNoteMap = new LinkedHashMap<Float, String>();


float c4 = 261.63;  float cs4 = 277.18; float d4 = 293.66;  float ds4 = 311.13;
float e4 = 329.63;  float f4 = 349.23;  float fs4 = 369.99; float g4 = 392.00;
float gs4 = 415.30; float a4 = 440.00;  float as4 = 446.16; float b4 = 493.88;

float c5 = 523.25;  float cs5 = 554.37; float d5 = 587.33;  float ds5 = 622.25;
float e5 = 659.26;  float f5 = 698.46;  float fs5 = 739.99; float g5 = 783.99;
float gs5 = 830.61; float a5 = 880.00;  float as5 = 932.33; float b5 = 987.77;

// int C4 = 0; int CS4 = 1; int D4 = 2; int DS4 = 3; int E4 = 4; int F4 = 5; 
// int FS4 = 6; int G4 = 7; int GS4 = 8; int A4 = 9; int AS4 = 10; int B4 = 11;

float[] definedNotes = {c4, cs4, d4, ds4, e4, f4, fs4, g4, gs4, a4, as4, b4, c5, cs5, d5, ds5, e5, f5, fs5, g5, gs5, a5, as5, b5};

float[] possibleRootNotes = new float[13];
float[] octaveFromC = new float[13];
float[] octaveFromCs = new float[13];
float[] octaveFromD = new float[13];
float[] octaveFromDs = new float[13];
float[] octaveFromE = new float[13];
float[] octaveFromF = new float[13];
float[] octaveFromFs = new float[13];
float[] octaveFromG = new float[13];
float[] octaveFromGs = new float[13];
float[] octaveFromA = new float[13];
float[] octaveFromAs = new float[13];
float[] octaveFromB = new float[13];

// Define various intervals between notes, could be used more later?
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

// Establish a default root note & key
float currentRootNote = definedNotes[2];
boolean currentKeyIsMajor = false;

// Floats (then arrays of floats) for storing the notes in chords and scales
float generatorNote1, generatorNote2, generatorNote3, generatorNote4, generatorNote5;
float tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave = currentRootNote;
float[] currentKeyNotes = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave};
float[] currentModeNotes = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave};
float[] currentPentatonicNotes = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, octave};

// Strings and arrays for modes and major/minor
String currentChordType = "Minor";
String currentMode = "Aeolian";
String[] modes = {"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"};

// Variables for buttons
int scaleButtonX, scaleButtonY, generateButtonX, generateButtonY, modeButtonX, modeButtonY, keyButtonX, keyButtonY, stopButtonX, stopButtonY;
int squareButtonSize = 100;
int rectButtonSize = 300;
color scaleButtonColor, generateButtonColor, modeButtonColor, keyButtonColor, stopButtonColor, baseColor,
      scaleButtonHighlight, generateButtonHighlight, modeButtonHighlight, keyButtonHighlight, stopButtonHighlight,
      currentColor;
boolean scaleButtonOver, generateButtonOver, modeButtonOver, stopButtonOver, keyButtonOver = false;

// User variables
boolean userStopped = false;
String userMessage = "Ready to generate";

void setup() {
  // Size of the canvas
  size(500, 700);

  // Defining colours
  scaleButtonColor = modeButtonColor = color(0);
  keyButtonColor = color(15, 175, 205);
  generateButtonColor = color(20, 215, 50);
  stopButtonColor = color(215, 20, 20);

  scaleButtonHighlight = generateButtonHighlight = modeButtonHighlight = keyButtonHighlight = stopButtonHighlight = color(50);
  keyButtonHighlight = color(10, 80, 95);
  generateButtonHighlight = color(15, 115, 20);
  stopButtonHighlight = color(180, 40, 25);

  currentColor = baseColor = color(255);

  // Positioning buttons
  keyButtonX = 100;
  keyButtonY = 100;

  scaleButtonX = 100;
  scaleButtonY = 300;
  generateButtonX = 300;
  generateButtonY = 300;

  modeButtonX = 100;
  modeButtonY = 500;
  stopButtonX = 300;
  stopButtonY = 500;

  // Note map
  noteMap.put("C4", 261.63);
  noteMap.put("CS4", 277.18);
  noteMap.put("D4", 293.66);
  noteMap.put("DS4", 311.13);
  noteMap.put("E4", 329.63);
  noteMap.put("F4", 349.23);
  noteMap.put("FS4", 369.99);
  noteMap.put("G4", 392.00);
  noteMap.put("GS4", 415.30);
  noteMap.put("A4", 440.00);
  noteMap.put("AS4", 446.16);
  noteMap.put("B4", 493.88);
  noteMap.put("C5", 523.25);
  noteMap.put("CS5", 554.37);
  noteMap.put("D5", 587.33);
  noteMap.put("DS5", 622.25);
  noteMap.put("E5", 659.26);
  noteMap.put("F5", 698.46);
  noteMap.put("FS5", 739.99);
  noteMap.put("G5", 783.99);
  noteMap.put("GS5", 830.61);
  noteMap.put("A5", 880.00);
  noteMap.put("AS5", 932.33);
  noteMap.put("B5", 987.77);

  // Part of the elaborate naming map
  frequencyToNoteMap.put(261.63, "C");
  frequencyToNoteMap.put(277.18, "C#");
  frequencyToNoteMap.put(293.66, "D");
  frequencyToNoteMap.put(311.13, "D#");
  frequencyToNoteMap.put(329.63, "E");
  frequencyToNoteMap.put(349.23, "F");
  frequencyToNoteMap.put(369.99, "F#");
  frequencyToNoteMap.put(392.00, "G");
  frequencyToNoteMap.put(415.30, "G#");
  frequencyToNoteMap.put(440.00, "A");
  frequencyToNoteMap.put(446.16, "A#");
  frequencyToNoteMap.put(493.88, "B");
  frequencyToNoteMap.put(523.25, "C");
  frequencyToNoteMap.put(554.37, "C#");
  frequencyToNoteMap.put(587.33, "D");
  frequencyToNoteMap.put(622.25, "D#");
  frequencyToNoteMap.put(659.26, "E");
  frequencyToNoteMap.put(698.46, "F");
  frequencyToNoteMap.put(739.99, "F#");
  frequencyToNoteMap.put(783.99, "G");
  frequencyToNoteMap.put(830.61, "G#");
  frequencyToNoteMap.put(880.00, "A");
  frequencyToNoteMap.put(932.33, "A#");
  frequencyToNoteMap.put(987.77, "B");

  for (int i = 0; i < possibleRootNotes.length; ++i) {
    possibleRootNotes[i] = definedNotes[i];
  }

 for (int i = 0; i < 12; ++i) {
  octaveFromC[i] = definedNotes[i];
  octaveFromCs[i] = definedNotes[i+1];
  octaveFromD[i]  = definedNotes[i+2];
  octaveFromDs[i] = definedNotes[i+3];
  octaveFromE[i]  = definedNotes[i+4];
  octaveFromF[i]  = definedNotes[i+5];
  octaveFromFs[i] = definedNotes[i+6];
  octaveFromG[i]  = definedNotes[i+7];
  octaveFromGs[i] = definedNotes[i+8];
  octaveFromA[i]  = definedNotes[i+9];
  octaveFromAs[i] = definedNotes[i+10];
  octaveFromB[i]  = definedNotes[i+11];
 }
}

void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(currentColor);

  textAlign(CENTER);
  fill(50);
  text("The current key is " + frequencyToNoteMap.get(currentRootNote) + (currentKeyIsMajor ? " Major" : " Minor") +
       "\nPlaying these notes: " + (generatorNote1 != 0.0f ? frequencyToNoteMap.get(generatorNote1) : " - ") + ", " + 
       (generatorNote2 != 0.0f ? frequencyToNoteMap.get(generatorNote2) : " - ") + ", " +  
       (generatorNote3 != 0.0f ? frequencyToNoteMap.get(generatorNote3) : " - ") + ", " +  
       (generatorNote4 != 0.0f ? frequencyToNoteMap.get(generatorNote4) : " - ") + ", " + 
       (generatorNote5 != 0.0f ? frequencyToNoteMap.get(generatorNote5) : " - ") +
       "\n" + userMessage, width/2, 250);

  // Draw and track the random notes button
  if (keyButtonOver) {
    fill(keyButtonHighlight);
  } else {
    fill(keyButtonColor);
  }
  stroke(255);
  rect(keyButtonX, keyButtonY, rectButtonSize, rectButtonSize/3, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text("RANDOMISE KEY", keyButtonX+(rectButtonSize/2), keyButtonY+(squareButtonSize/2));

  // Draw and track the scales button
  if (scaleButtonOver) {
    fill(scaleButtonHighlight);
  } else {
    fill(scaleButtonColor);
  }
  stroke(255);
  rect(scaleButtonX, scaleButtonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text("CURRENT SCALE", scaleButtonX+(squareButtonSize/2), scaleButtonY+(squareButtonSize/2));

  // Draw and track the generate button
  if (generateButtonOver) {
    fill(generateButtonHighlight);
  } else {
    fill(generateButtonColor);
  }
  stroke(255);
  rect(generateButtonX, generateButtonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text("GENERATE!", generateButtonX+(squareButtonSize/2), generateButtonY+(squareButtonSize/2));

  // Draw and track the mode button
  if (modeButtonOver) {
    fill(modeButtonHighlight);
  } else {
    fill(modeButtonColor);
  }
  stroke(255);
  rect(modeButtonX, modeButtonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text("PLAY MODES", modeButtonX+(squareButtonSize/2), modeButtonY+(squareButtonSize/2));

  // Draw and track the stop button
  if (stopButtonOver) {
    fill(stopButtonHighlight);
  } else {
    fill(stopButtonColor);
  }
  stroke(255);
  rect(stopButtonX, stopButtonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text("STOP", stopButtonX+(squareButtonSize/2), stopButtonY+(squareButtonSize/2));
}



// Handle higlighting and selections from mouse movements
void update(int x, int y) {
  if (overKeyButton(keyButtonX, keyButtonY, rectButtonSize, squareButtonSize)) {
    keyButtonOver = true;
    scaleButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overScaleButton(scaleButtonX, scaleButtonY, squareButtonSize, squareButtonSize)) {
    scaleButtonOver = true;
    keyButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overgenerateButton(generateButtonX, generateButtonY, squareButtonSize, squareButtonSize)) {
    generateButtonOver = true;
    keyButtonOver = scaleButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overModeButton(modeButtonX, modeButtonY, squareButtonSize, squareButtonSize)) {
    modeButtonOver = true;
    keyButtonOver = scaleButtonOver = generateButtonOver = stopButtonOver = false;
  } else if (overStopButton(stopButtonX, stopButtonY, squareButtonSize, squareButtonSize)) {
    stopButtonOver = true;
    keyButtonOver = scaleButtonOver = generateButtonOver = modeButtonOver = false;
  } else {
    keyButtonOver = scaleButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  }
}

// Dealing with the mouse
boolean overKeyButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overScaleButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overgenerateButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overModeButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overStopButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}



// Handle clicking the mouse on various functions
void mousePressed() {
  // Button to do scales stuff
  if (scaleButtonOver) {
    userStopped = false;
    stopPlaying();
    setScale();
    playCurrentKey();
  }
  // Button to do chords stuff
  if (generateButtonOver) {
    setScale();
    stopPlaying();
    thread("startGenerating");
  }
  // Button to play related modes
  if (modeButtonOver) {
    stopPlaying();
    for (int i = 0; i < modes.length; ++i) {
      currentMode = modes[i];
      setCurrentMode(currentRootNote);
      print(currentMode + ": ");
      playCurrentMode();
    }
  }
  // Button to randomise key
  if (keyButtonOver) {
    changeKey();
  }
  // Stops everything after the current pattern finishes
  if (stopButtonOver) {
    userMessage = "Stopping generator";
    userStopped = true;
    stopPlaying();
  }
}

/*
 *    *************
 *    *************
 *    *************
 *    PLAYING STUFF
 *    *************
 *    *************
 *    *************
 */

// Called to start generating, based on possible notes from the current key
// This runs as a seperate thread so the rest of the program can be interacted with
void startGenerating() {
  while (!userStopped){
    userMessage = "Generating...";
    Random randy = new Random(); 
    int randomIndex = randy.nextInt(currentKeyNotes.length); 
    generatorNote1 = currentKeyNotes[randomIndex];
    randomIndex = randy.nextInt(currentKeyNotes.length); 
    generatorNote2 = currentKeyNotes[randomIndex];
    randomIndex = randy.nextInt(currentKeyNotes.length); 
    generatorNote3 = currentKeyNotes[randomIndex];
    randomIndex = randy.nextInt(currentKeyNotes.length); 
    generatorNote4 = currentKeyNotes[randomIndex];
    randomIndex = randy.nextInt(currentKeyNotes.length);
    generatorNote5 = currentKeyNotes[randomIndex];

  
    // Play at least one note from the curent key, 50/50 chance for more notes, each for
    // a random amount of time, and at random amplitude, checking after note whether to stop.
    sin1.play(generatorNote1, 0.5);
    delay(randy.nextInt(5000) + 1);

    if(userStopped) stopPlaying();
    else {
      if(randy.nextBoolean()) {
        sin2.play(generatorNote2, randy.nextFloat());
      } else { sin2.stop(); }

      delay(randy.nextInt(5000) + 1);

      if(userStopped) stopPlaying();
      else { 
        if(randy.nextBoolean()) {
          sin3.play(generatorNote3, randy.nextFloat());
        } else { sin3.stop(); }

        delay(randy.nextInt(5000) + 1);

        if(userStopped) stopPlaying();
        else { 
          if(randy.nextBoolean()) {
            sin4.play(generatorNote4, randy.nextFloat());
          } else { sin4.stop(); }

          delay(randy.nextInt(5000) + 1);

          if(userStopped) stopPlaying();
          else {
            if(randy.nextBoolean()) {
              sin5.play(generatorNote5, randy.nextFloat());
            } else { sin5.stop(); }

            delay(randy.nextInt(5000) + 1);

          }
        }
      }
    }
  }
  stopPlaying();
  userStopped = false;
  userMessage = "Stopped the generator";
}

// Plays the current key scale through once
void playCurrentKey() {  
  sin1.play(currentKeyNotes[0], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[1], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[2], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[3], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[4], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[5], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[6], 0.5);
  delay(250);
  sin1.play(currentKeyNotes[7], 0.5);
  delay(250);
  sin1.stop();
}

void playCurrentMode() {
  sin1.play(currentModeNotes[0], 0.5);
  delay(250);
  sin1.play(currentModeNotes[1], 0.5);
  delay(250);
  sin1.play(currentModeNotes[2], 0.5);
  delay(250);
  sin1.play(currentModeNotes[3], 0.5);
  delay(250);
  sin1.play(currentModeNotes[4], 0.5);
  delay(250);
  sin1.play(currentModeNotes[5], 0.5);
  delay(250);
  sin1.play(currentModeNotes[6], 0.5);
  delay(250);
  sin1.play(currentModeNotes[7], 0.5);
  delay(250);
  sin1.stop();
}

// Stops what's playing
void stopPlaying() {
  sin1.stop();
  sin2.stop();
  sin3.stop();
  sin4.stop();
  sin5.stop();
}


/*
 *    *************
 *    *************
 *    *************
 *    SETTING STUFF
 *    *************
 *    *************
 *    *************
 */

// Sets the current scale to be messed with, major or minor
void setScale() {
  float[] noteBank = new float[13];
  switch(Math.round(currentRootNote)) {
    case 262:
      noteBank = octaveFromC;    
      break;
    case 277:
      noteBank = octaveFromCs;
      break;
    case 294:
      noteBank = octaveFromD;
      break;
    case 311:
      noteBank = octaveFromDs;    
      break;
    case 330:
      noteBank = octaveFromE;
      break;
    case 349:
      noteBank = octaveFromF;
      break;
    case 370:
      noteBank = octaveFromFs;
      break;
    case 392:
      noteBank = octaveFromG;
      break;
    case 415:
      noteBank = octaveFromGs;
      break;
    case 440:
      noteBank = octaveFromA;
      break;
    case 466:
      noteBank = octaveFromAs;
      break;
    case 494:
       noteBank = octaveFromB;
      break;
  }

  if (currentKeyIsMajor) {
    currentKeyNotes[0] = currentRootNote;
    currentKeyNotes[1] = noteBank[2];
    currentKeyNotes[2] = noteBank[4];
    currentKeyNotes[3] = noteBank[5];
    currentKeyNotes[4] = noteBank[7];
    currentKeyNotes[5] = noteBank[9];
    currentKeyNotes[6] = noteBank[11];
    currentKeyNotes[7] = noteBank[12];
  } else if (!currentKeyIsMajor) {
    currentKeyNotes[0] = currentRootNote;
    currentKeyNotes[1] = noteBank[2];
    currentKeyNotes[2] = noteBank[3];
    currentKeyNotes[3] = noteBank[5];
    currentKeyNotes[4] = noteBank[7];
    currentKeyNotes[5] = noteBank[8];
    currentKeyNotes[6] = noteBank[10];
    currentKeyNotes[7] = noteBank[12];
  }
}

// Sets the current modes relative to current root note
void setCurrentMode(float rootNote) {
  switch (currentMode) {
  case "Ionian": // Equivalent to major scale, cool!
    currentModeNotes[0] = rootNote;
    currentModeNotes[1] = currentModeNotes[0] * TONE;
    currentModeNotes[2] = currentModeNotes[1] * TONE;
    currentModeNotes[3] = currentModeNotes[2] * SEMITONE;
    currentModeNotes[4] = currentModeNotes[3] * TONE;
    currentModeNotes[5] = currentModeNotes[4] * TONE;
    currentModeNotes[6] = currentModeNotes[5] * TONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Dorian":
    currentModeNotes[0] = rootNote * TONE;
    currentModeNotes[1] = currentModeNotes[0] * TONE;
    currentModeNotes[2] = currentModeNotes[1] * SEMITONE;
    currentModeNotes[3] = currentModeNotes[2] * TONE;
    currentModeNotes[4] = currentModeNotes[3] * TONE;
    currentModeNotes[5] = currentModeNotes[4] * TONE;
    currentModeNotes[6] = currentModeNotes[5] * SEMITONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Phrygian":
    currentModeNotes[0] = rootNote * MAJORTHIRD;
    currentModeNotes[1] = currentModeNotes[0] * SEMITONE;
    currentModeNotes[2] = currentModeNotes[1] * TONE;
    currentModeNotes[3] = currentModeNotes[2] * TONE;
    currentModeNotes[4] = currentModeNotes[3] * TONE;
    currentModeNotes[5] = currentModeNotes[4] * SEMITONE;
    currentModeNotes[6] = currentModeNotes[5] * TONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Lydian":
    currentModeNotes[0] = rootNote * PERFECTFOURTH;
    currentModeNotes[1] = currentModeNotes[0] * TONE;
    currentModeNotes[2] = currentModeNotes[1] * TONE;
    currentModeNotes[3] = currentModeNotes[2] * TONE;
    currentModeNotes[4] = currentModeNotes[3] * SEMITONE;
    currentModeNotes[5] = currentModeNotes[4] * TONE;
    currentModeNotes[6] = currentModeNotes[5] * TONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Mixolydian":
    currentModeNotes[0] = rootNote * PERFECTFIFTH;
    currentModeNotes[1] = currentModeNotes[0] * TONE;
    currentModeNotes[2] = currentModeNotes[1] * TONE;
    currentModeNotes[3] = currentModeNotes[2] * SEMITONE;
    currentModeNotes[4] = currentModeNotes[3] * TONE;
    currentModeNotes[5] = currentModeNotes[4] * TONE;
    currentModeNotes[6] = currentModeNotes[5] * SEMITONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Aeolian": // Equivalent to minor scale, NEATO!
    currentModeNotes[0] = rootNote * MAJORSIXTH;
    currentModeNotes[1] = currentModeNotes[0] * TONE;
    currentModeNotes[2] = currentModeNotes[1] * SEMITONE;
    currentModeNotes[3] = currentModeNotes[2] * TONE;
    currentModeNotes[4] = currentModeNotes[3] * TONE;
    currentModeNotes[5] = currentModeNotes[4] * SEMITONE;
    currentModeNotes[6] = currentModeNotes[5] * TONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  case "Locrian":
    currentModeNotes[0] = rootNote * MAJORSEVENTH;
    currentModeNotes[1] = currentModeNotes[0] * SEMITONE;
    currentModeNotes[2] = currentModeNotes[1] * TONE;
    currentModeNotes[3] = currentModeNotes[2] * TONE;
    currentModeNotes[4] = currentModeNotes[3] * SEMITONE;
    currentModeNotes[5] = currentModeNotes[4] * TONE;
    currentModeNotes[6] = currentModeNotes[5] * TONE;
    currentModeNotes[7] = currentModeNotes[0] * 2;
    break;
  }
}


/*
 *    **************
 *    **************
 *    **************
 *    CHANGING STUFF
 *    **************
 *    **************
 *    **************
 */

void changeKey() {
  // THIS COULD BE TIED TO THE BEAT? AS IN MILIS() / ARRAY LENGTH??
  Random randy = new Random(); 
  int randomIndex = randy.nextInt(possibleRootNotes.length); 
  currentRootNote = possibleRootNotes[randomIndex];
  currentKeyIsMajor = randy.nextBoolean();
  
  setScale();
  print("The current key is " + frequencyToNoteMap.get(currentRootNote));
  println(currentKeyIsMajor ? " Major." : " Minor.");
}