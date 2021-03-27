PFont  SFMono;
import java.util.*;
import processing.sound.*;

Sound s = new Sound(this);

float     currentRootNote;
int       bpm;
int       beatValue;
int       beatsPerBar;
int       beatDelay;
float     beatLength;
boolean   currentKeyIsMajor;

String    userMessage;
String    countMessage = ".";

volatile boolean userStopped  = false;

HashMap<Float, String> frequencyToNoteMap = new HashMap<Float, String>();
ArrayList<Oscillator> oscillatorList = new ArrayList<Oscillator>();

int[] noteRoll;

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

float[] currentKeyFrequencies  = new float[8];
String[] currentKeyNotes = new String[8];
String currentChordType;

// Variables for buttons
int     keyButtonX,     keyButtonY,     timeButtonX,  timeButtonY,
				addNoteButtonX, addNoteButtonY, synthButtonX, synthButtonY, 
				goButtonX,      goButtonY,      stopButtonX,  stopButtonY;
int     buttonWidth = 250;
int     buttonHeight = 200;
int     infoWidth = 500;
int     infroHeight = 50;
color   keyButtonColor,     timeButtonColor, 
				addNoteButtonColor, synthButtonColor,
				goButtonColor,      stopButtonColor, 
				baseColor,
        keyButtonHighlight,     timeButtonHighlight,
        addNoteButtonHighlight, synthButtonHighlight,
        goButtonHighlight,      stopButtonHighlight,
        currentColor;
boolean keyButtonOver,     timeButtonOver,
				addNoteButtonOver, synthButtonOver, 
				goButtonOver,      stopButtonOver
				= false;

void setup() {
  // Size of the canvas
  size(500, 750);
  SFMono = loadFont("SFMono-Medium-15.vlw");
  textFont(SFMono);
  
  // Define the frequencies for notes
  definedNotes[0] = 261.63;  definedNotes[1] = 277.18;  definedNotes[2] = 293.66;  definedNotes[3] = 311.13; 
  definedNotes[4] = 329.63;  definedNotes[5] = 349.23;  definedNotes[6] = 369.99;  definedNotes[7] = 392.00; 
  definedNotes[8] = 415.30;  definedNotes[9] = 440.00;  definedNotes[10] = 466.16; definedNotes[11] = 493.88; 
  
  definedNotes[12] = 523.25; definedNotes[13] = 554.37; definedNotes[14] = 587.33; definedNotes[15] = 622.25; 
  definedNotes[16] = 659.26; definedNotes[17] = 698.46; definedNotes[18] = 739.99; definedNotes[19] = 783.99; 
  definedNotes[20] = 830.61; definedNotes[21] = 880.00; definedNotes[22] = 932.33; definedNotes[23] = 987.77;

  // Defining colours
  keyButtonColor     = #0091FF; // Blue
  timeButtonColor    = #0091FF; // Blue
  addNoteButtonColor = #0091FF; // Blue
  synthButtonColor   = #0091FF; // Blue
  goButtonColor      = #6DD400; // Green
  stopButtonColor    = #E02020; // Red

  keyButtonHighlight     = color( 10,  80,  95); // Dark Blue
  timeButtonHighlight    = color( 10,  80,  95); // Dark Blue
	addNoteButtonHighlight = color( 10,  80,  95); // Dark Blue
  synthButtonHighlight   = color( 10,  80,  95); // Dark Blue
  goButtonHighlight      = color( 15, 115,  20); // Dark Green
  stopButtonHighlight    = color(180,  40,  25); // Dark Red

  currentColor = baseColor = color(255);

  // Positioning buttons
  keyButtonX     =   0; keyButtonY     = 150; timeButtonX  = 250; timeButtonY  = 150;
  addNoteButtonX =   0; addNoteButtonY = 350; synthButtonX = 250; synthButtonY = 350; 
  goButtonX      =   0; goButtonY      = 550; stopButtonX  = 250; stopButtonY  = 550;

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
  currentRootNote   = definedNotes[0];
  currentKeyIsMajor = false;
  currentChordType  = "Minor";
  bpm               = 70;
  beatValue         = 4;
  beatsPerBar       = 4;
	beatLength        = 60000 / bpm;
	beatDelay         = (int)beatLength;
	noteRoll = new int[beatsPerBar * 4];
	Arrays.fill(noteRoll, 0);
	userMessage = "Randomise key, add notes, and go!";

  setScale();

} // End of setup

void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(currentColor);

  for (int i = 0; i < currentKeyFrequencies.length; ++i) {
  	currentKeyNotes[i] = frequencyToNoteMap.get(currentKeyFrequencies[i]);
  }

    // User info
  textAlign(LEFT,TOP); fill(50);
  text("CURRENT INFORMATION" + 
       "\n" + frequencyToNoteMap.get(currentRootNote) + (currentKeyIsMajor ? " Major " : " Minor ") + " Notes:" + 
       Arrays.toString(currentKeyNotes) +
       "\nTime signature: " + beatValue + "/" + beatsPerBar + " at " + bpm + "bpm" +
       "\nSound:" + " Oscillator" + 
       "\nTIMELINE" +
       "\n" + Arrays.toString(noteRoll) + 
       "\n" + countMessage +
       "\n" + userMessage
       , 0, 0);

  // Draw and track the key button
  if (keyButtonOver) {
    fill(keyButtonHighlight);
  } else {
    fill(keyButtonColor);
  }
  buttonMaker(keyButtonX, keyButtonY, "Change Notes");

  // Draw and track the time button
  if (timeButtonOver) {
    fill(timeButtonHighlight);
  } else {
    fill(timeButtonColor);
  }
  buttonMaker(timeButtonX, timeButtonY, "Change Time Signature");

    // Draw and track the mode button
  if (addNoteButtonOver) {
    fill(addNoteButtonHighlight);
  } else {
    fill(addNoteButtonColor);
  }
  buttonMaker(addNoteButtonX, addNoteButtonY, "Add Note to Timeline");

  // Draw and track the synth button
  if (synthButtonOver) {
    fill(synthButtonHighlight);
  } else {
    fill(synthButtonColor);
  }
  buttonMaker(synthButtonX, synthButtonY, "Change Sound");

  // Draw and track the generate button
  if (goButtonOver) {
    fill(goButtonHighlight);
  } else {
    fill(goButtonColor);
  }
  buttonMaker(goButtonX, goButtonY, "Play Timeline");

  // Draw and track the stop button
  if (stopButtonOver) {
    fill(stopButtonHighlight);
  } else {
    fill(stopButtonColor);
  }
  buttonMaker(stopButtonX, stopButtonY, "Stop Playing");
}

/*              *\
|* SETTING STUFF*|
\*              */

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
    currentKeyFrequencies[0] = currentRootNote;
    currentKeyFrequencies[1] = noteBank[2];
    currentKeyFrequencies[2] = noteBank[4];
    currentKeyFrequencies[3] = noteBank[5];
    currentKeyFrequencies[4] = noteBank[7];
    currentKeyFrequencies[5] = noteBank[9];
    currentKeyFrequencies[6] = noteBank[11];
    currentKeyFrequencies[7] = noteBank[12];
  } else if (!currentKeyIsMajor) {
    currentKeyFrequencies[0] = currentRootNote;
    currentKeyFrequencies[1] = noteBank[2];
    currentKeyFrequencies[2] = noteBank[3];
    currentKeyFrequencies[3] = noteBank[5];
    currentKeyFrequencies[4] = noteBank[7];
    currentKeyFrequencies[5] = noteBank[8];
    currentKeyFrequencies[6] = noteBank[10];
    currentKeyFrequencies[7] = noteBank[12];
  }

  print("Current key notes: " + currentKeyFrequencies[0]);
  for (int i = 1; i < currentKeyFrequencies.length; ++i) {
    print(", " + currentKeyFrequencies[i]);
  }
  println();
}

// Stubbed for later
void changeSynth() {}

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
  if (overKeyButton(keyButtonX, keyButtonY, buttonWidth, buttonHeight)) {
    keyButtonOver = true;
    timeButtonOver = addNoteButtonOver = synthButtonOver = goButtonOver = stopButtonOver = false;
  } else if (overTimeButton(timeButtonX, timeButtonY, buttonWidth, buttonHeight)) {
    timeButtonOver = true;
    keyButtonOver = addNoteButtonOver = synthButtonOver = goButtonOver = stopButtonOver = false;
  } else if (overAddNoteButton(addNoteButtonX, addNoteButtonY, buttonWidth, buttonHeight)) {
    addNoteButtonOver = true;
    keyButtonOver = timeButtonOver = synthButtonOver = goButtonOver = stopButtonOver = false;
  } else if (overSynthButton(synthButtonX, synthButtonY, buttonWidth, buttonHeight)) {
    synthButtonOver = true;
    keyButtonOver = timeButtonOver = addNoteButtonOver = goButtonOver = stopButtonOver = false;
  } else if (overGoButton(goButtonX, goButtonY, buttonWidth, buttonHeight)) {
    goButtonOver = true;
    keyButtonOver = timeButtonOver = addNoteButtonOver = synthButtonOver = stopButtonOver = false;
  } else if (overStopButton(stopButtonX, stopButtonY, buttonWidth, buttonHeight)) {
    stopButtonOver = true;
    keyButtonOver = timeButtonOver = addNoteButtonOver = synthButtonOver = goButtonOver = false;
  } else {
    keyButtonOver = timeButtonOver = addNoteButtonOver = synthButtonOver = goButtonOver = stopButtonOver = false;
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
boolean overTimeButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overAddNoteButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overSynthButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overGoButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}
boolean overStopButton(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}

// Handle clicking the mouse on various functions
void mousePressed() {
  if (keyButtonOver) {
    changeKey();
  }
  if (timeButtonOver) {
  	changeTime();
  }
  if (addNoteButtonOver) {
    addNote();
  }
  if (synthButtonOver) {
    changeSynth();
  }
  if (goButtonOver) {
    thread("startPlaying");
  }
  if (stopButtonOver) {
  	userStopped = true;
  	Arrays.fill(noteRoll, 0);
    for (Oscillator oscillator : oscillatorList) {
      oscillator.stopPlaying();
    }
  }
}

void startPlaying() {
	while(!userStopped){
		int oscillatorInfo = 0;
		countMessage = "";
		for (int i = 0; i < noteRoll.length; i++) {
			if (noteRoll[i] == 1) {
				oscillatorList.get(oscillatorInfo).run();
				oscillatorInfo++;
			  userMessage = "Count: " + Integer.toString(i + 1) + " - osc data: " + oscillatorInfo;
			  countMessage = countMessage.concat("--|");
			}
			else {
			  	userMessage = "Count: " + Integer.toString(i + 1) + " - osc data: " + oscillatorInfo;
			  	countMessage = countMessage.concat("--|");
			  }
			delay(beatDelay);;
		}
	}
	oscillatorList.clear();
	userMessage = "Start again?";
	countMessage = "";
	userStopped = false;
}

void changeTime() {
	Random randy = new Random();
	bpm          = (randy.nextInt(14) + 6) * 10;
	beatValue    = randy.nextInt(5) + 1;
	beatLength   = 60000 / bpm;
	beatDelay    = (int)beatLength;
	noteRoll     = new int[beatsPerBar * 4];
	Arrays.fill(noteRoll, 0);
}

void addNote() {
	Random randy = new Random();
  int randomIndex = randy.nextInt(noteRoll.length - 1);
  noteRoll[randomIndex] = 1;
  randomIndex = randy.nextInt(currentKeyFrequencies.length - 1);

	SinOsc oscillator = new SinOsc(this);
  Env    envelope   = new Env(this);

  float  oscillatorNote         = currentKeyFrequencies[randomIndex];
  float  oscillatorAmplitude    = 0.5;
  float  oscillatorSustainTime  = ((beatLength * ((randy.nextInt(beatsPerBar * 4) + beatsPerBar))) / 1000);
  float  oscillatorAttackTime   = oscillatorSustainTime / 3;
  float  oscillatorSustainLevel = 0.25 + randy.nextFloat() * (0.8 - 0.25);
  float  oscillatorReleaseTime  = oscillatorSustainTime / 3;

  println("Note: "      + frequencyToNoteMap.get(oscillatorNote) +
          ", Attack: "  + oscillatorAttackTime + 
          ", Sustain: " + oscillatorSustainTime +
          ", Level: "   + oscillatorSustainLevel +
          ", Release: " + oscillatorReleaseTime + 
          ", Total: "   + (oscillatorAttackTime+oscillatorSustainTime+oscillatorReleaseTime));

  Oscillator newOscillator = new Oscillator(oscillator, oscillatorNote, oscillatorAmplitude,
	                                     envelope,
	                                     oscillatorAttackTime, oscillatorSustainTime, 
	                                     oscillatorSustainLevel, oscillatorReleaseTime);

  oscillatorList.add(newOscillator);
}

void buttonMaker(int buttonX, int buttonY, String message) {
  stroke(255);
  rect(buttonX, buttonY, buttonWidth, buttonHeight, 6, 6, 6, 6);
  fill(255);
  textAlign(CENTER);
  text(message, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
}


class Oscillator extends Thread {
  SinOsc oscillator;
  String message;
  float note;
  float amplitude;
  Env envelope;
  float attackTime;
  float sustainTime;
  float sustainLevel;
  float releaseTime;

  Oscillator(SinOsc givenOscillator, float givenNote, float givenAmplitude,
             Env givenEnvelope,
             float givenAttackTime, float givenSustainTime,
             float givenSustainLevel, float givenReleaseTime) {
    this.oscillator = givenOscillator;
    this.note = givenNote;
    this.amplitude = givenAmplitude;
    this.envelope = givenEnvelope;
    this.attackTime = givenAttackTime;
    this.sustainTime = givenSustainTime;
    this.sustainLevel = givenSustainLevel;
    this.releaseTime = givenReleaseTime;
  }

  void run() {
    oscillator.play(note, amplitude);
    envelope.play(oscillator, attackTime, sustainTime, sustainLevel, releaseTime);
    delay((int)(attackTime + sustainTime + releaseTime));
  }

  void stopPlaying() {
	  oscillator.stop();
  }
}