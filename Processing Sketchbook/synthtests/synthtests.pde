import java.util.*;
import processing.sound.*;

// We are making sound!
Sound s = new Sound(this);


// Global variables that will be needed
TriOsc[]  sinWaves;
Env[]     envelopes;
float     totalAmplitude;
float     currentRootNote;
int       numberOfSins;
int       oscsSharingAmplitude;
boolean   currentKeyIsMajor;
boolean   userStopped = false;
boolean   generatorRunning = false;
String    userMessage = "Ready to generate";
String    ampMessage = "Silent...";

// Note maps initialised
HashMap<String, Float> noteMap = new HashMap<String, Float>();
LinkedHashMap<Float, String> frequencyToNoteMap = new LinkedHashMap<Float, String>();

float[] definedNotes = new float[24];
float[] octaveFromC  = new float[13];
float[] octaveFromCs = new float[13];
float[] octaveFromD  = new float[13];
float[] octaveFromDs = new float[13];
float[] octaveFromE  = new float[13];
float[] octaveFromF  = new float[13];
float[] octaveFromFs = new float[13];
float[] octaveFromG  = new float[13];
float[] octaveFromGs = new float[13];
float[] octaveFromA  = new float[13];
float[] octaveFromAs = new float[13];
float[] octaveFromB  = new float[13];

float[] generatorNotes        = new float[8];
float[] currentlyPlayingNotes = new float[8];

// Floats (then arrays of floats) for storing the notes in chords and scales
float tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave;

float[] currentKeyNotes        = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave};
float[] currentModeNotes       = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, sixthDegree, seventhDegree, octave};
float[] currentPentatonicNotes = {tonic, secondDegree, thirdDegree, fourthDegree, fifthDegree, octave};

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


// Strings and arrays for modes and major/minor
String currentChordType;
String currentMode;
String[] modes = {"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"};

// Variables for buttons
int     synthButtonX, synthButtonY, generateButtonX, generateButtonY, modeButtonX, modeButtonY, 
        keyButtonX, keyButtonY, stopButtonX, stopButtonY;
int     squareButtonSize = 100;
int     rectButtonSize = 300;
color   synthButtonColor, generateButtonColor, modeButtonColor, keyButtonColor, stopButtonColor, baseColor,
        synthButtonHighlight, generateButtonHighlight, modeButtonHighlight, keyButtonHighlight, stopButtonHighlight,
        currentColor;
boolean synthButtonOver, generateButtonOver, modeButtonOver, stopButtonOver, keyButtonOver = false;

void setup() {
  // Size of the canvas
  size(500, 700);

  // Prepare enough sin waves and envelopes
  numberOfSins = 5;
  sinWaves = new TriOsc[numberOfSins];
  envelopes = new Env[numberOfSins];

  for (int i = 0; i < numberOfSins; ++i) {
    sinWaves[i] = new TriOsc(this);
    envelopes[i] = new Env(this);
  }

  // Define the frequencies for notes
  definedNotes[0] = 261.63;  definedNotes[1] = 277.18;  definedNotes[2] = 293.66;  definedNotes[3] = 311.13; 
  definedNotes[4] = 329.63;  definedNotes[5] = 349.23;  definedNotes[6] = 369.99;  definedNotes[7] = 392.00; 
  definedNotes[8] = 415.30;  definedNotes[9] = 440.00;  definedNotes[10] = 446.16; definedNotes[11] = 493.88; 
  
  definedNotes[12] = 523.25; definedNotes[13] = 554.37; definedNotes[14] = 587.33; definedNotes[15] = 622.25; 
  definedNotes[16] = 659.26; definedNotes[17] = 698.46; definedNotes[18] = 739.99; definedNotes[19] = 783.99; 
  definedNotes[20] = 830.61; definedNotes[21] = 880.00; definedNotes[22] = 932.33; definedNotes[23] = 987.77;

  // Defining colours
  synthButtonColor = modeButtonColor = color(0);
  keyButtonColor      = color( 15, 175, 205);
  generateButtonColor = color( 20, 215,  50);
  stopButtonColor     = color(215,  20,  20);

  generateButtonHighlight = modeButtonHighlight = keyButtonHighlight = stopButtonHighlight = color(50);
  synthButtonHighlight    = color( 10,  80,  95);
  keyButtonHighlight      = color( 10,  80,  95);
  generateButtonHighlight = color( 15, 115,  20);
  stopButtonHighlight     = color(180,  40,  25);

  currentColor = baseColor = color(255);

  // Positioning buttons
  keyButtonX = 100;       keyButtonY = 100;
  synthButtonX = 100;     synthButtonY = 300;
  generateButtonX = 300;  generateButtonY = 300;
  modeButtonX = 100;      modeButtonY = 500;
  stopButtonX = 300;      stopButtonY = 500;

  // Note map
  noteMap.put("C4" , 261.63); noteMap.put("CS4", 277.18); noteMap.put("D4" , 293.66);
  noteMap.put("DS4", 311.13); noteMap.put("E4" , 329.63); noteMap.put("F4" , 349.23);
  noteMap.put("FS4", 369.99); noteMap.put("G4" , 392.00); noteMap.put("GS4", 415.30);
  noteMap.put("A4" , 440.00); noteMap.put("AS4", 446.16); noteMap.put("B4" , 493.88);

  noteMap.put("C5" , 523.25); noteMap.put("CS5", 554.37); noteMap.put("D5" , 587.33);
  noteMap.put("DS5", 622.25); noteMap.put("E5" , 659.26); noteMap.put("F5" , 698.46);
  noteMap.put("FS5", 739.99); noteMap.put("G5" , 783.99); noteMap.put("GS5", 830.61);
  noteMap.put("A5" , 880.00); noteMap.put("AS5", 932.33); noteMap.put("B5" , 987.77);  

  // Note naming map
  frequencyToNoteMap.put(261.63, "C" ); frequencyToNoteMap.put(277.18, "C#");
  frequencyToNoteMap.put(293.66, "D" ); frequencyToNoteMap.put(311.13, "D#");
  frequencyToNoteMap.put(329.63, "E" ); frequencyToNoteMap.put(349.23, "F" );
  frequencyToNoteMap.put(369.99, "F#"); frequencyToNoteMap.put(392.00, "G" );
  frequencyToNoteMap.put(415.30, "G#"); frequencyToNoteMap.put(440.00, "A" );
  frequencyToNoteMap.put(446.16, "A#"); frequencyToNoteMap.put(493.88, "B" );
  frequencyToNoteMap.put(523.25, "C" ); frequencyToNoteMap.put(554.37, "C#");
  frequencyToNoteMap.put(587.33, "D" ); frequencyToNoteMap.put(622.25, "D#");
  frequencyToNoteMap.put(659.26, "E" ); frequencyToNoteMap.put(698.46, "F" );
  frequencyToNoteMap.put(739.99, "F#"); frequencyToNoteMap.put(783.99, "G" );
  frequencyToNoteMap.put(830.61, "G#"); frequencyToNoteMap.put(880.00, "A" );
  frequencyToNoteMap.put(932.33, "A#"); frequencyToNoteMap.put(987.77, "B" );  

  
  // Build the octave ranges for root notes
  for (int i = 0; i < 13; ++i) {
    octaveFromC[i]  = definedNotes[i];
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

  // Start with default root note, key, chord type, and mode
  currentRootNote      = definedNotes[2];
  currentKeyIsMajor    = false;
  currentChordType     = "Minor";
  currentMode          = "Aeolian";
  oscsSharingAmplitude = 1;
  setScale();

} // End of setup

void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(currentColor);

  // Keep the volume at a reasonable level by sharing amongest the
  // oscillators
  for (int i = 0; i < oscsSharingAmplitude; ++i) {
    sinWaves[i].amp((1.0 / oscsSharingAmplitude));
    ampMessage = String.valueOf((1.0 / oscsSharingAmplitude));
  }

  // User info
  textAlign(CENTER);
  fill(50);
  text("The current key is " + frequencyToNoteMap.get(currentRootNote) 
   + (currentKeyIsMajor ? " Major" : " Minor") +
   "\nPlaying these notes: " + 
   (currentlyPlayingNotes[0] != 0.0f ? frequencyToNoteMap.get(currentlyPlayingNotes[0]) : " - ") + ", " + 
   (currentlyPlayingNotes[1] != 0.0f ? frequencyToNoteMap.get(currentlyPlayingNotes[1]) : " - ") + ", " +  
   (currentlyPlayingNotes[2] != 0.0f ? frequencyToNoteMap.get(currentlyPlayingNotes[2]) : " - ") + ", " +  
   (currentlyPlayingNotes[3] != 0.0f ? frequencyToNoteMap.get(currentlyPlayingNotes[3]) : " - ") + ", " + 
   (currentlyPlayingNotes[4] != 0.0f ? frequencyToNoteMap.get(currentlyPlayingNotes[4]) : " - ") +
   "\n Current amplitude for each osc is: " + ampMessage +
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

  // Draw and track the synth button
  if (synthButtonOver) {
    fill(synthButtonHighlight);
  } else {
    fill(synthButtonColor);
  }
  squareButtonMaker(synthButtonX, synthButtonY, "CHANGE SYNTH");

  // Draw and track the generate button
  if (generateButtonOver) {
    fill(generateButtonHighlight);
  } else {
    fill(generateButtonColor);
  }
  squareButtonMaker(generateButtonX, generateButtonY, "GENERATE!");


  // Draw and track the mode button
  if (modeButtonOver) {
    fill(modeButtonHighlight);
  } else {
    fill(modeButtonColor);
  }
  squareButtonMaker(modeButtonX, modeButtonY, "PLAY MODES");

  // Draw and track the stop button
  if (stopButtonOver) {
    fill(stopButtonHighlight);
  } else {
    fill(stopButtonColor);
  }
  squareButtonMaker(stopButtonX, stopButtonY, "STOP!");
}

void squareButtonMaker(int buttonX, int buttonY, String message) {
  stroke(255);
  rect(buttonX, buttonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text(message, buttonX+(squareButtonSize/2), buttonY+(squareButtonSize/2));
}

// Handle higlighting and selections from mouse movements
void update(int x, int y) {
  if (overKeyButton(keyButtonX, keyButtonY, rectButtonSize, squareButtonSize)) {
    keyButtonOver = true;
    synthButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (oversynthButton(synthButtonX, synthButtonY, squareButtonSize, squareButtonSize)) {
    synthButtonOver = true;
    keyButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overgenerateButton(generateButtonX, generateButtonY, squareButtonSize, squareButtonSize)) {
    generateButtonOver = true;
    keyButtonOver = synthButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overModeButton(modeButtonX, modeButtonY, squareButtonSize, squareButtonSize)) {
    modeButtonOver = true;
    keyButtonOver = synthButtonOver = generateButtonOver = stopButtonOver = false;
  } else if (overStopButton(stopButtonX, stopButtonY, squareButtonSize, squareButtonSize)) {
    stopButtonOver = true;
    keyButtonOver = synthButtonOver = generateButtonOver = modeButtonOver = false;
  } else {
    keyButtonOver = synthButtonOver = generateButtonOver = modeButtonOver = stopButtonOver = false;
  }
}

// Dealing with the mouse
boolean overKeyButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean oversynthButton(int x, int y, int width, int height) {
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
  if (synthButtonOver) {
    changeSynth();
  }
  // Button to do chords stuff
  if (generateButtonOver) {
    if (!generatorRunning) {
      generatorRunning = true;
      thread("startGenerating");
    }
  }
  // Button to play related modes
  if (modeButtonOver) {
    stopPlaying();
    for (int i = 0; i < modes.length; ++i) {
      currentMode = modes[i];
      setCurrentMode(currentRootNote);
      print(currentMode + ". ");
      playCurrentMode();
    }
  }
  // Button to randomise key
  if (keyButtonOver) {
    changeKey();
  }
  // Stops everything after the current pattern finishes
  if (stopButtonOver) {
    if (generatorRunning) {
      userMessage = "Stopping generator";
      userStopped = true;
      stopPlaying();
    }
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
// This runs as a separate thread
void startGenerating() {
  // Let the user know we are generating
  userMessage = "Generating...";

  // Randy the Java Random is VERY important
  Random randy = new Random();
  boolean addNote = false;

  // These values are used for the ASR envelope
  float attackTime = 0.5;
  float sustainTime = 3.0;
  float sustainLevel = 0.3;
  float releaseTime = 0.5;

  // Used for pulling random notes
  int randomIndex = randy.nextInt(currentKeyNotes.length - 1);

  // Array to track which oscillators are playing
  boolean isPlaying[] = new boolean[numberOfSins];
  Arrays.fill(isPlaying, false);

  println();
  print("Current generator notes: ");

  for (int i = 0; i < generatorNotes.length; ++i) {
    generatorNotes[i] = currentKeyNotes[randomIndex];
    randomIndex = randy.nextInt(currentKeyNotes.length);
    print("," + generatorNotes[i]);
  }
  println();

  // Looping until user stopped
  while (!userStopped) {  
    // Play at least one note from the curent key, 50/50 chance for more notes, each for
    // a random amount of time, and at random amplitude, checking after note whether to stop.
    currentlyPlayingNotes[0] = generatorNotes[0];
    sinWaves[0].play(generatorNotes[0], 0.5);
    envelopes[0].play(sinWaves[0], attackTime, sustainTime, sustainLevel, releaseTime);
    delay((int)((attackTime + sustainTime + releaseTime) * 1000));
    isPlaying[0] = true;
    addNote = randy.nextBoolean();
    println();

    if(userStopped) stopPlaying();
    else {
      if(addNote && !isPlaying[1]) {
        oscsSharingAmplitude++;
        isPlaying[1] = true;
        currentlyPlayingNotes[1] = generatorNotes[1];
        sinWaves[1].play(generatorNotes[1], randy.nextFloat());
        envelopes[1].play(sinWaves[1], attackTime, sustainTime, sustainLevel, releaseTime);
        println("+Current osc's sharing: " + oscsSharingAmplitude);
      } else if (!addNote && isPlaying[1]) {
        sinWaves[1].stop();
        currentlyPlayingNotes[1] = 0;
        oscsSharingAmplitude--;
        println("-Current osc's sharing: " + oscsSharingAmplitude);
      }
      delay((int)((attackTime + sustainTime + releaseTime) * 1000));
      addNote = randy.nextBoolean();

      if(userStopped) stopPlaying();
      else { 
        if(addNote && !isPlaying[2]) {
          oscsSharingAmplitude++;
          isPlaying[2] = true;
          currentlyPlayingNotes[2] = generatorNotes[2];
          sinWaves[2].play(generatorNotes[2], randy.nextFloat());
          envelopes[2].play(sinWaves[2], attackTime, sustainTime, sustainLevel, releaseTime);
          println("+Current osc's sharing: " + oscsSharingAmplitude);
        } else if (!addNote && isPlaying[2]) { 
          sinWaves[2].stop();
          currentlyPlayingNotes[2] = 0;
          oscsSharingAmplitude--;
          println("-Current osc's sharing: " + oscsSharingAmplitude);
        }
        delay((int)((attackTime + sustainTime + releaseTime) * 1000));
        addNote = randy.nextBoolean();

        if(userStopped) stopPlaying();
        else {
          if(addNote && !isPlaying[3]) {
            oscsSharingAmplitude++;
            isPlaying[3] = true;
            currentlyPlayingNotes[3] = generatorNotes[3];
            sinWaves[3].play(generatorNotes[3], randy.nextFloat());
            envelopes[3].play(sinWaves[3], attackTime, sustainTime, sustainLevel, releaseTime);
            println("+Current osc's sharing: " + oscsSharingAmplitude);
          } else if (!addNote && isPlaying[3]) { 
            sinWaves[3].stop();
            currentlyPlayingNotes[3] = 0;
            oscsSharingAmplitude--;
            println("-Current osc's sharing: " + oscsSharingAmplitude);
          }
          delay((int)((attackTime + sustainTime + releaseTime) * 1000));
          addNote = randy.nextBoolean();

          if(userStopped) stopPlaying();
          else {
            if(addNote && !isPlaying[4]) {
              oscsSharingAmplitude++;
              isPlaying[4] = true;
              currentlyPlayingNotes[4] = generatorNotes[4];
              sinWaves[4].play(generatorNotes[4], randy.nextFloat());
              envelopes[4].play(sinWaves[4], attackTime, sustainTime, sustainLevel, releaseTime);
              println("+Current osc's sharing: " + oscsSharingAmplitude);
            } else if (!addNote && isPlaying [4]) {
              sinWaves[4].stop();
              currentlyPlayingNotes[4] = 0;
              oscsSharingAmplitude--;
              println("-Current osc's sharing: " + oscsSharingAmplitude);
            }
            delay((int)((attackTime + sustainTime + releaseTime) * 1000));
            addNote = randy.nextBoolean();
          }
        }
      }
    } // End of the else loop for playing
  } // End of the while loop for generating

  stopPlaying();
  userStopped = false;
  generatorRunning = false;
  userMessage = "Stopped the generator";
}

// Plays the current key scale through once
void changeSynth() {  
  sinWaves[0].play(currentKeyNotes[0], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[1], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[2], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[3], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[4], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[5], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[6], 0.5);
  delay(250);
  sinWaves[0].play(currentKeyNotes[7], 0.5);
  delay(250);
  sinWaves[0].stop();
}

void playCurrentMode() {
  sinWaves[0].play(currentModeNotes[0], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[1], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[2], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[3], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[4], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[5], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[6], 0.5);
  delay(250);
  sinWaves[0].play(currentModeNotes[7], 0.5);
  delay(250);
  sinWaves[0].stop();
}

// Stops what's playing
void stopPlaying() {
  for (int i = 0; i < numberOfSins; ++i) {
    sinWaves[i].stop(); 
  }
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
    case 262: // C4
    noteBank = octaveFromC; 
    break;
    case 277: // C#4
    noteBank = octaveFromCs;
    break;
    case 294: // D4
    noteBank = octaveFromD;
    print("Octave from D: " + octaveFromD[0]);
    for (int i = 1; i < octaveFromD.length; ++i) {
      print(", " + octaveFromD[i]);
    }
    println();
    print("Notebank: " + noteBank[0]);
    for (int i = 1; i < noteBank.length; ++i) {
      print(", " + noteBank[i]);
    }
    break;
    case 311: // D#4
    noteBank = octaveFromDs;    
    break;
    case 330: // E4
    noteBank = octaveFromE;
    break;
    case 349: // F4
    noteBank = octaveFromF;
    break;
    case 370: // F#4
    noteBank = octaveFromFs;
    break;
    case 392: // G4
    noteBank = octaveFromG;
    break;
    case 415: //G#4
    noteBank = octaveFromGs;
    break;
    case 440: // A4
    noteBank = octaveFromA;
    break;
    case 466: // A#4
    noteBank = octaveFromAs;
    break;
    case 494: // B4
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

  println();
  print("Current key notes: " + currentKeyNotes[0]);
  for (int i = 1; i < currentKeyNotes.length; ++i) {
    print(", " + currentKeyNotes[i]);
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
  int randomIndex = randy.nextInt(definedNotes.length); 
  currentRootNote = definedNotes[randomIndex];
  currentKeyIsMajor = randy.nextBoolean();
  setScale();
}