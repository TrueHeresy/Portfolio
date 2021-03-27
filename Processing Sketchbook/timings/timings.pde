import java.util.*;
import processing.sound.*;

// This is a generative music maker! 
// By me, Declan Kehoe, a student. 
// A student that is tired, and 29.


Sound s = new Sound(this);

float     currentRootNote;
int       totalAvailableOscs;
int       totalOscsNowPlaying;
int       oscillatorNumber;
int       bpm;
int       beats;
int       bar;
boolean   currentKeyIsMajor;
boolean   generatorRunning;
String    userMessage;
String    ampMessage;

float  attackTime;
float  sustainTime;
float  sustainLevel;
float  releaseTime;
String oscMessage;

volatile boolean userStopped  = true;
volatile boolean stopOscOne   = false;
volatile boolean stopOscTwo   = false;
volatile boolean stopOscThree = false;
volatile boolean stopOscFour  = false;
volatile boolean stopOscFive  = false;
boolean allStopped   = true;


// Note maps initialiser
HashMap<Float, String> frequencyToNoteMap = new HashMap<Float, String>();
ArrayList<Oscillator> oscillatorList = new ArrayList<Oscillator>();

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

float[] generatorNotes   = new float[8];
float[] currentKeyNotes  = new float[8];
String currentChordType;

// Variables for buttons
int     synthButtonX, synthButtonY, genButtonX, genButtonY, modeButtonX, modeButtonY, 
        keyButtonX, keyButtonY, stopButtonX, stopButtonY;
int     squareButtonSize = 100;
int     rectButtonSize = 300;
color   synthButtonColor, genButtonColor, modeButtonColor, keyButtonColor, stopButtonColor, baseColor,
        synthButtonHighlight, genButtonHighlight, modeButtonHighlight, keyButtonHighlight, stopButtonHighlight,
        currentColor;
boolean synthButtonOver, genButtonOver, modeButtonOver, stopButtonOver, keyButtonOver = false;

void setup() {
  // Size of the canvas
  size(500, 700);

  // Prepare enough oscillators and envelopes
  totalAvailableOscs = 5;

  // Define the frequencies for notes
  definedNotes[0] = 261.63;  definedNotes[1] = 277.18;  definedNotes[2] = 293.66;  definedNotes[3] = 311.13; 
  definedNotes[4] = 329.63;  definedNotes[5] = 349.23;  definedNotes[6] = 369.99;  definedNotes[7] = 392.00; 
  definedNotes[8] = 415.30;  definedNotes[9] = 440.00;  definedNotes[10] = 466.16; definedNotes[11] = 493.88; 
  
  definedNotes[12] = 523.25; definedNotes[13] = 554.37; definedNotes[14] = 587.33; definedNotes[15] = 622.25; 
  definedNotes[16] = 659.26; definedNotes[17] = 698.46; definedNotes[18] = 739.99; definedNotes[19] = 783.99; 
  definedNotes[20] = 830.61; definedNotes[21] = 880.00; definedNotes[22] = 932.33; definedNotes[23] = 987.77;

  // Defining colours
  synthButtonColor = modeButtonColor = color(0);
  keyButtonColor   = color( 15, 175, 205);
  genButtonColor   = color( 20, 215,  50);
  stopButtonColor  = color(215,  20,  20);

  genButtonHighlight   = modeButtonHighlight = keyButtonHighlight = stopButtonHighlight = color(50);
  synthButtonHighlight = color( 10,  80,  95);
  keyButtonHighlight   = color( 10,  80,  95);
  genButtonHighlight   = color( 15, 115,  20);
  stopButtonHighlight  = color(180,  40,  25);

  currentColor = baseColor = color(255);

  // Positioning buttons
  keyButtonX   = 100; keyButtonY   = 100;
  synthButtonX = 100; synthButtonY = 300;
  genButtonX   = 300; genButtonY   = 300;
  modeButtonX  = 100; modeButtonY  = 500;
  stopButtonX  = 300; stopButtonY  = 500;

  // Note naming map
  frequencyToNoteMap.put(261.63, "C4" ); frequencyToNoteMap.put(277.18, "C#4");
  frequencyToNoteMap.put(293.66, "D4" ); frequencyToNoteMap.put(311.13, "D#4");
  frequencyToNoteMap.put(329.63, "E4" ); frequencyToNoteMap.put(349.23, "F4" );
  frequencyToNoteMap.put(369.99, "F#4"); frequencyToNoteMap.put(392.00, "G4" );
  frequencyToNoteMap.put(415.30, "G#4"); frequencyToNoteMap.put(440.00, "A4" );
  frequencyToNoteMap.put(466.16, "A#4"); frequencyToNoteMap.put(493.88, "B4" );

  frequencyToNoteMap.put(523.25, "C5" ); frequencyToNoteMap.put(554.37, "C#5");
  frequencyToNoteMap.put(587.33, "D5" ); frequencyToNoteMap.put(622.25, "D#5");
  frequencyToNoteMap.put(659.26, "E5" ); frequencyToNoteMap.put(698.46, "F5" );
  frequencyToNoteMap.put(739.99, "F#5"); frequencyToNoteMap.put(783.99, "G5" );
  frequencyToNoteMap.put(830.61, "G#5"); frequencyToNoteMap.put(880.00, "A5" );
  frequencyToNoteMap.put(932.33, "A#5"); frequencyToNoteMap.put(987.77, "B5" );  
  
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
  currentRootNote        = definedNotes[0];
  currentKeyIsMajor      = false;
  currentChordType       = "Minor";
  bpm                    = 100;
  beats                  = 4;
  bar                    = 4;
  totalOscsNowPlaying    = 0;
  oscillatorNumber       = 0;
  setScale();

} // End of setup

void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(currentColor);

  allStopped = (totalOscsNowPlaying == 0) ? true : false;

  // User info
  textAlign(CENTER); fill(50);
  text("The current key is " + frequencyToNoteMap.get(currentRootNote) + 
      (currentKeyIsMajor ? " Major" : " Minor") +
      "\nPlaying these notes: " + 
      ((generatorNotes[0] != 0.0f && !allStopped) ? frequencyToNoteMap.get(generatorNotes[0]) : " - ") + ", " + 
      ((generatorNotes[1] != 0.0f && !allStopped) ? frequencyToNoteMap.get(generatorNotes[1]) : " - ") + ", " +  
      ((generatorNotes[2] != 0.0f && !allStopped) ? frequencyToNoteMap.get(generatorNotes[2]) : " - ") + ", " +  
      ((generatorNotes[3] != 0.0f && !allStopped) ? frequencyToNoteMap.get(generatorNotes[3]) : " - ") + ", " + 
      ((generatorNotes[4] != 0.0f && !allStopped) ? frequencyToNoteMap.get(generatorNotes[4]) : " - ") +
      "\nCurrent amplitude for each of the " + totalOscsNowPlaying + " osc's is: " + ampMessage +
      "\n " + oscillatorList.toString() +
      "\nAll stopped: " + allStopped + " | User stopped: " + userStopped +
      "\n" + userMessage, width/2, 220);

  // Draw and track the key notes button
  if (keyButtonOver) {
    fill(keyButtonHighlight);
  } else {
    fill(keyButtonColor);
  }
  stroke(255); rect(keyButtonX, keyButtonY, rectButtonSize, rectButtonSize/3, 6, 6, 6, 6);
  fill(255); textAlign(CENTER);
  text("RANDOMISE KEY", keyButtonX+(rectButtonSize/2), keyButtonY+(squareButtonSize/2));

  // Draw and track the synth button
  if (synthButtonOver) {
    fill(synthButtonHighlight);
  } else {
    fill(synthButtonColor);
  }
  squareButtonMaker(synthButtonX, synthButtonY, "CHANGE SYNTH");

  // Draw and track the generate button
  if (genButtonOver) {
    fill(genButtonHighlight);
  } else {
    fill(genButtonColor);
  }
  squareButtonMaker(genButtonX, genButtonY, "GENERATE!");


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

/*               *\
|* PLAYING STUFF *|
\*               */

// Called to start generating, based on possible notes from the current key
void startGenerating() {
  // Let the user know we are generating
  userMessage = "Generating...";

  // Randy the Java Random is VERY important
  Random randy = new Random();

  // Used for pulling random notes
  int randomIndex = randy.nextInt(currentKeyNotes.length - 1);

  // Array to track which oscillators are playing
  boolean isPlaying[] = new boolean[totalAvailableOscs];
  Arrays.fill(isPlaying, false);

  oscillatorNumber++;
  String oscillatorName = "Oscillator" + oscillatorNumber;
  SinOsc oscillator = new SinOsc(this);
  String oscillatorMessage = "NEW BOI";
  Env    envelope = new Env(this);
  float  oscillatorNote = currentKeyNotes[randomIndex];
  float  oscillatorAmplitude = 0.5;
  float  oscillatorSustainTime = (((60000/bpm) * ((randy.nextInt(bar * 4) + bar))) / 1000);
  float  oscillatorAttackTime = oscillatorSustainTime / 3;
  float  oscillatorSustainLevel = 0.3;
  float  oscillatorReleaseTime = oscillatorSustainTime / 3;

  println("Note: "      + frequencyToNoteMap.get(oscillatorNote) +
          ", Attack: "  + oscillatorAttackTime + 
          ", Sustain: " + oscillatorSustainTime +
          ", Release: " + oscillatorReleaseTime + 
          ", Total: "   + (oscillatorAttackTime+oscillatorSustainTime+oscillatorReleaseTime));

  Oscillator newOscillator = new Oscillator(oscillator, oscillatorMessage, 
                                     oscillatorNote, oscillatorAmplitude,
                                     envelope,
                                     oscillatorAttackTime, oscillatorSustainTime, 
                                     oscillatorSustainLevel, oscillatorReleaseTime);
  newOscillator.run();
  oscillatorList.add(newOscillator);
  println("NAME: " + oscillatorList.get(oscillatorNumber - 1));
}

// Stubbed for later
void changeSynth() {}
void playCurrentMode() {}


/*
 * SETTING STUFF
\               */

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
  println();
}

void changeKey() {
  // THIS COULD BE TIED TO THE BEAT? AS IN MILIS() / ARRAY LENGTH??
  Random randy = new Random(); 
  int randomIndex = randy.nextInt(11); 
  currentRootNote = definedNotes[randomIndex];
  currentKeyIsMajor = randy.nextBoolean();
  println();
  setScale();
}


// Handle higlighting and selections from mouse movements
void update(int x, int y) {
  if (overKeyButton(keyButtonX, keyButtonY, rectButtonSize, squareButtonSize)) {
    keyButtonOver = true;
    synthButtonOver = genButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (oversynthButton(synthButtonX, synthButtonY, squareButtonSize, squareButtonSize)) {
    synthButtonOver = true;
    keyButtonOver = genButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overgenButton(genButtonX, genButtonY, squareButtonSize, squareButtonSize)) {
    genButtonOver = true;
    keyButtonOver = synthButtonOver = modeButtonOver = stopButtonOver = false;
  } else if (overModeButton(modeButtonX, modeButtonY, squareButtonSize, squareButtonSize)) {
    modeButtonOver = true;
    keyButtonOver = synthButtonOver = genButtonOver = stopButtonOver = false;
  } else if (overStopButton(stopButtonX, stopButtonY, squareButtonSize, squareButtonSize)) {
    stopButtonOver = true;
    keyButtonOver = synthButtonOver = genButtonOver = modeButtonOver = false;
  } else {
    keyButtonOver = synthButtonOver = genButtonOver = modeButtonOver = stopButtonOver = false;
  }
}


/*                      *\
|* Interaction handling *|
\*                      */

// Dealing with the mouse
boolean overKeyButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean oversynthButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overgenButton(int x, int y, int width, int height) {
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
  if (genButtonOver) {
    if (totalOscsNowPlaying == 0) {
      startGenerating();
    }
  }
  // Button to play related modes
  if (modeButtonOver) {
    playCurrentMode();
  }
  // Button to randomise key
  if (keyButtonOver) {
    changeKey();
  }
  // Stops everything after the current pattern finishes
  if (stopButtonOver) {
    for (Oscillator oscillator : oscillatorList) {
      oscillator.stopPlaying();
    }
    oscillatorList.clear();
    oscillatorNumber = 0;
  }
}

void squareButtonMaker(int buttonX, int buttonY, String message) {
  stroke(255);
  rect(buttonX, buttonY, squareButtonSize, squareButtonSize, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text(message, buttonX+(squareButtonSize/2), buttonY+(squareButtonSize/2));
}

class Oscillator extends Thread {
  private volatile boolean inLoop = false; 
  SinOsc oscillator;
  String message;
  float note;
  float amplitude;
  Env envelope;
  float attackTime;
  float sustainTime;
  float sustainLevel;
  float releaseTime;

  Oscillator(SinOsc givenOscillator, String givenMessage,
             float givenNote, float givenAmplitude,
             Env givenEnvelope,
             float givenAttackTime, float givenSustainTime,
             float givenSustainLevel, float givenReleaseTime) {
    this.oscillator = givenOscillator;
    this.message = givenMessage;
    this.note = givenNote;
    this.amplitude = givenAmplitude;
    this.envelope = givenEnvelope;
    this.attackTime = givenAttackTime;
    this.sustainTime = givenSustainTime;
    this.sustainLevel = givenSustainLevel;
    this.releaseTime = givenReleaseTime;
  }

  void run() {
    inLoop = true;
    oscillator.play(note, amplitude);
    envelope.play(oscillator, attackTime, sustainTime, sustainLevel, releaseTime);
    delay((int)(attackTime + sustainTime + releaseTime));
  }

  void stopPlaying() {
    oscillator.stop();
  }

}