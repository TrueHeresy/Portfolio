import java.util.*;
import processing.sound.*;

Sound s = new Sound(this);

float     currentRootNote;
int       bpm, beatValue, beatsPerBar, beatDelay, notesInTimeline;
final int SIMPLE = 0, COMPLEX = 1, SIN = 0, SAW = 1, SQR = 2, TRI = 3;
int       currentOscType;
float     beatLength;
boolean   currentKeyIsMajor;

String[]  userMessage     = new String[2];
String[]  oscTypes        = new String[4];
String    countMessage    = ".";

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

float[]  currentKeyFrequencies  = new float[8];
String[] currentKeyNotes = new String[8];
String   currentChordType, complexReadout;

// Variables for buttons
int     addButtonX,     addButtonY,     removeButtonX,  removeButtonY,
        keyAndTempoX, keyAndTempoY, synthButtonX, synthButtonY, 
        playButtonX,      playButtonY,      stopButtonX,  stopButtonY;
int     buttonWidth  = 250;
int     buttonHeight = 200;
int     infoWidth    = 500;
int     infoHeight   = 100;
color   addButtonColor,         removeButtonColor, 
        keyAndTempoButtonColor, synthButtonColor,
        playButtonColor,        stopButtonColor, 
        addButtonHighlight,     removeButtonHighlight,
        keyAndTempoHighlight,   synthButtonHighlight,
        playButtonHighlight,    stopButtonHighlight,
        glyph;
boolean addButtonOver,          removeButtonOver,
        keyAndTempoOver,        synthButtonOver, 
        playButtonOver,         stopButtonOver,
        readoutOver,            complexMode,
        nowPlaying,             timelineFull = false;

PImage iAdd, iAddPressed, iRemove, iRemovePressed,
       iKeyTempo, iKeyTempoPressed, iSound, iSoundPressed,
       iPlay, iPlayPressed, iStop, iStopPressed;

PFont  SFMono;


void setup() {
  // Size of the canvas
  size(500, 750);
  SFMono = loadFont("SFMono-Medium-15.vlw");
  textFont(SFMono);
  
  // Define the frequencies for notes, C4 - B5
  definedNotes[0] = 261.63;  definedNotes[1] = 277.18;  definedNotes[2] = 293.66;  definedNotes[3] = 311.13; 
  definedNotes[4] = 329.63;  definedNotes[5] = 349.23;  definedNotes[6] = 369.99;  definedNotes[7] = 392.00; 
  definedNotes[8] = 415.30;  definedNotes[9] = 440.00;  definedNotes[10] = 466.16; definedNotes[11] = 493.88; 
  
  definedNotes[12] = 523.25; definedNotes[13] = 554.37; definedNotes[14] = 587.33; definedNotes[15] = 622.25; 
  definedNotes[16] = 659.26; definedNotes[17] = 698.46; definedNotes[18] = 739.99; definedNotes[19] = 783.99; 
  definedNotes[20] = 830.61; definedNotes[21] = 880.00; definedNotes[22] = 932.33; definedNotes[23] = 987.77;

  // Defining colours
  addButtonColor         = #EAF0F8; // Blue
  removeButtonColor      = #EAF0F8; // Blue
  keyAndTempoButtonColor = #EAF0F8; // Blue
  synthButtonColor       = #EAF0F8; // Blue
  playButtonColor        = #D0F0D3; // Green
  stopButtonColor        = #F6A4A4; // Red

  addButtonHighlight     = #D2DEEF; // Dark Blue
  removeButtonHighlight  = #D2DEEF; // Dark Blue
  keyAndTempoHighlight   = #D2DEEF; // Dark Blue
  synthButtonHighlight   = #D2DEEF; // Dark Blue
  playButtonHighlight    = #A8ECAE; // Dark Green
  stopButtonHighlight    = #FE7676; // Dark Red

  glyph = #717171;


  // Positioning buttons
  addButtonX     =   0; addButtonY     = 150; removeButtonX  = 250; removeButtonY  = 150;
  keyAndTempoX   =   0; keyAndTempoY   = 350; synthButtonX   = 250; synthButtonY   = 350; 
  playButtonX    =   0; playButtonY    = 550; stopButtonX    = 250; stopButtonY    = 550;

  // Note naming map
  frequencyToNoteMap.put(261.63, "C" ); frequencyToNoteMap.put(277.18, "C#");
  frequencyToNoteMap.put(293.66, "D" ); frequencyToNoteMap.put(311.13, "D#");
  frequencyToNoteMap.put(329.63, "E" ); frequencyToNoteMap.put(349.23, "F" );
  frequencyToNoteMap.put(369.99, "F#"); frequencyToNoteMap.put(392.00, "G" );
  frequencyToNoteMap.put(415.30, "G#"); frequencyToNoteMap.put(440.00, "A" );
  frequencyToNoteMap.put(466.16, "A#"); frequencyToNoteMap.put(493.88, "B" );

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

  // Descibe the oscillator types
  oscTypes[0] = "Sin"; oscTypes[1] = "Saw"; oscTypes[2] = "Square"; oscTypes[3] = "Triangle";

  // Load in the images
  iAdd      = loadImage("Add.png");      iAddPressed      = loadImage("AddPressed.png"); 
  iRemove   = loadImage("Remove.png");   iRemovePressed   = loadImage("RemovePressed.png");
  iKeyTempo = loadImage("KeyTempo.png"); iKeyTempoPressed = loadImage("KeyTempoPressed.png");
  iSound    = loadImage("Sound.png");    iSoundPressed    = loadImage("SoundPressed.png");
  iPlay     = loadImage("Play.png");     iPlayPressed     = loadImage("PlayPressed.png");
  iStop     = loadImage("Stop.png");     iStopPressed     = loadImage("StopPressed.png");

  // Start with default root note, key, chord type, and mode
  currentRootNote   = definedNotes[0];
  notesInTimeline   = 0;
  currentKeyIsMajor = false;
  currentChordType  = "Minor";
  currentOscType    = SIN;
  bpm               = 70;
  beatValue         = 4;
  beatsPerBar       = 4;
  beatLength        = 60000 / bpm;
  beatDelay         = (int)beatLength;
  noteRoll          = new int[beatsPerBar * 4];

  Arrays.fill(noteRoll, 0);

  userMessage[SIMPLE] = "Add some notes, play, mess around, have fun!" +
                        "\nClick this readout screen to toggle more/less detail" +
                        "\nYou probably won't break anything...";

  userMessage[COMPLEX] = "Add notes, and go!" + 
                         "\nNote Bank: currently empty" +
                         "\nTempo: N/A " + "    |     Oscillator: N/A";

  setScale();

} // End of setup

void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(color(0));

  complexReadout    = "\nNote Bank: " + frequencyToNoteMap.get(currentRootNote) + (currentKeyIsMajor ? "maj " : "min ") + 
                    Arrays.toString(currentKeyNotes) +
                    "\nTempo: " + bpm + "bpm" + "     |     Oscillator: " + oscTypes[currentOscType];

  // Get the note names
  for (int i = 0; i < currentKeyFrequencies.length; ++i) {
    currentKeyNotes[i] = frequencyToNoteMap.get(currentKeyFrequencies[i]);
  }

  // User info
  textAlign(CENTER,TOP); 
  fill(255);
  // Basic mode
  if (!complexMode) {
    text(userMessage[SIMPLE], 250, 10);
    textAlign(LEFT, CENTER);
    // Timeline
    fill(255);
    text(Arrays.toString(noteRoll) + "\n" + countMessage, 34, 125);

    // Draw and track the add note button
    if (addButtonOver) {
      circleHighlightButton(addButtonX, addButtonY, addButtonColor, addButtonHighlight, "", iAddPressed);
    } else {
      basicCircleButton(addButtonX, addButtonY, addButtonColor, "", iAdd);
    }
    // Draw and track the remove note button
    if (removeButtonOver) {
      circleHighlightButton(removeButtonX, removeButtonY, removeButtonColor, removeButtonHighlight, "", iRemovePressed);
    } else {
      basicCircleButton(removeButtonX, removeButtonY, removeButtonColor, "", iRemove);
    }
    // Draw and track the key and tempo button
    if (keyAndTempoOver) {
      circleHighlightButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, keyAndTempoHighlight, "", iKeyTempoPressed);
    } else {
      basicCircleButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, "", iKeyTempo);
    }
    // Draw and track the synth button
    if (synthButtonOver) {
      circleHighlightButton(synthButtonX, synthButtonY, synthButtonColor, synthButtonHighlight, "", iSoundPressed);
    } else {
      basicCircleButton(synthButtonX, synthButtonY, synthButtonColor, "", iSound);
    }
    // Draw and track the play button
    if (playButtonOver || nowPlaying) {
      squareHighlightButton(playButtonX, playButtonY, playButtonColor, playButtonHighlight, "", iPlayPressed);
    } else {
      basicSquare(playButtonX, playButtonY, playButtonColor, "", iPlay);
    }
    // Draw and track the stop button
    if (stopButtonOver) {
      squareHighlightButton(stopButtonX, stopButtonY, stopButtonColor, stopButtonHighlight, "", iStopPressed);
    } else {
      basicSquare(stopButtonX, stopButtonY, stopButtonColor, "", iStop);
    }
  } 

  // Complex mode
  else {
    text(userMessage[COMPLEX],
        250, 10);
    textAlign(LEFT, CENTER);
    // Timeline
    fill(255);
    text(Arrays.toString(noteRoll) + "\n" + countMessage, 34, 125);

    // Draw and track the add note button
    if (addButtonOver) {
      circleHighlightButton(addButtonX, addButtonY, addButtonColor, addButtonHighlight, "ADD\nNOTE", iAddPressed);
    } else {
      basicCircleButton(addButtonX, addButtonY, addButtonColor, "ADD\nNOTE", iAdd);
    }
    // Draw and track the remove note button
    if (removeButtonOver) {
      circleHighlightButton(removeButtonX, removeButtonY, removeButtonColor, removeButtonHighlight, "REMOVE\nNOTE", iRemove);
    } else {
      basicCircleButton(removeButtonX, removeButtonY, removeButtonColor, "REMOVE\nNOTE", iRemovePressed);
    }
    // Draw and track the key and tempo button
    if (keyAndTempoOver) {
      circleHighlightButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, keyAndTempoHighlight, "CHANGE\nKEY &\nTEMPO", iKeyTempo);
    } else {
      basicCircleButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, "CHANGE\nKEY &\nTEMPO", iKeyTempoPressed);
    }
    // Draw and track the synth button
    if (synthButtonOver) {
      circleHighlightButton(synthButtonX, synthButtonY, synthButtonColor, synthButtonHighlight, "CHANGE\nSOUND", iSound);
    } else {
      basicCircleButton(synthButtonX, synthButtonY, synthButtonColor, "CHANGE\nSOUND", iSoundPressed);
    }
    // Draw and track the play button
    if (playButtonOver || nowPlaying) {
      squareHighlightButton(playButtonX, playButtonY, playButtonColor, playButtonHighlight, "PLAY", iPlay);
    } else {
      basicSquare(playButtonX, playButtonY, playButtonColor, "PLAY", iPlayPressed);
    }
    // Draw and track the stop button
    if (stopButtonOver) {
      squareHighlightButton(stopButtonX, stopButtonY, stopButtonColor, stopButtonHighlight, "STOP", iStop);
    } else {
      basicSquare(stopButtonX, stopButtonY, stopButtonColor, "STOP", iStopPressed);
    }
  } 
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

  print("Note Frequencies: " + currentKeyFrequencies[0]);
  for (int i = 1; i < currentKeyFrequencies.length; ++i) {
    print(", " + currentKeyFrequencies[i]);
  }
  println();
}

/*                      *\
|* Interaction handling *|
\*                      */

// Dealing with the mouse
boolean hoveringOver(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}

// Handle higlighting and selections from mouse movements
void update(int x, int y) {
  // Add button, remove button, key & tempo button, synth button, play button, stop button, readout
  if (hoveringOver(addButtonX, addButtonY, buttonWidth, buttonHeight)) {
    addButtonOver = true;
    readoutOver = removeButtonOver = keyAndTempoOver = synthButtonOver = playButtonOver = stopButtonOver = false;
  } else if (hoveringOver(removeButtonX, removeButtonY, buttonWidth, buttonHeight)) {
    removeButtonOver = true;
    readoutOver = addButtonOver = keyAndTempoOver = synthButtonOver = playButtonOver = stopButtonOver = false;
  } else if (hoveringOver(keyAndTempoX, keyAndTempoY, buttonWidth, buttonHeight)) {
    keyAndTempoOver = true;
    readoutOver = addButtonOver = removeButtonOver = synthButtonOver = playButtonOver = stopButtonOver = false;
  } else if (hoveringOver(synthButtonX, synthButtonY, buttonWidth, buttonHeight)) {
    synthButtonOver = true;
    readoutOver = addButtonOver = removeButtonOver = keyAndTempoOver = playButtonOver = stopButtonOver = false;
  } else if (hoveringOver(playButtonX, playButtonY, buttonWidth, buttonHeight)) {
    playButtonOver = true;
    readoutOver = addButtonOver = removeButtonOver = keyAndTempoOver = synthButtonOver = stopButtonOver = false;
  } else if (hoveringOver(stopButtonX, stopButtonY, buttonWidth, buttonHeight)) {
    stopButtonOver = true;
    readoutOver = addButtonOver = removeButtonOver = keyAndTempoOver = synthButtonOver = playButtonOver = false;
  } else if (hoveringOver(0, 0, 500, 200)) {
    readoutOver = true;
    addButtonOver = removeButtonOver = keyAndTempoOver = synthButtonOver = playButtonOver = stopButtonOver = false;
  } else {
    readoutOver = addButtonOver = removeButtonOver = keyAndTempoOver = synthButtonOver = playButtonOver = stopButtonOver = false;
  }
}

// Handle clicking the mouse on various functions
void mousePressed() {
  if (addButtonOver) {
    addNote();
  }
  if (removeButtonOver) {
    removeNote();
  }
  if (keyAndTempoOver) {
    changeKeyandTempo();
  }
  if (synthButtonOver) {
    changeSynth();
  }
  if (playButtonOver) {
    nowPlaying = true;
    thread("startPlaying");
  }
  if (stopButtonOver) {
    userStopped = true;
    nowPlaying = false;
    timelineFull = false;
    notesInTimeline = 0;
    Arrays.fill(noteRoll, 0);
    for (Oscillator oscillator : oscillatorList) {
      oscillator.stopPlaying();
    }
  }
  if (readoutOver) {
    complexMode = !complexMode;
  }
}

// Add a note to a random point in the timeline
void addNote() {
  Random randy = new Random();
  int randomIndex = randy.nextInt(noteRoll.length);

  // Make sure to add a note to an empty place in the timeline, up to the max of 16
  if (notesInTimeline >= 16) {
    timelineFull = true;
  } else {
    notesInTimeline++;
    timelineFull = false;
  }
  while (noteRoll[randomIndex] == 1 && !timelineFull) {
    randomIndex = randy.nextInt(noteRoll.length);
  }

  noteRoll[randomIndex] = 1;

  // Now change to a random index for the note
  randomIndex = randy.nextInt(currentKeyFrequencies.length - 1);
  
  Env    envelope   = new Env(this);

  float  oscNote    = currentKeyFrequencies[randomIndex];
  float  oscAmp     = 0.5;
  float  oscSusTime = ((beatLength * ((randy.nextInt(beatsPerBar * 4) + beatsPerBar))) / 1000);
  float  oscAtk     = oscSusTime / 3;
  float  oscSusLvl  = 0.25 + randy.nextFloat() * (0.8 - 0.25);
  float  oscRelTime = oscSusTime / 3;

  println("Note: "      + frequencyToNoteMap.get(oscNote) +
          ", Attack: "  + oscAtk + 
          ", Sustain: " + oscSusTime +
          ", Level: "   + oscSusLvl +
          ", Release: " + oscRelTime + 
          ", Total: "   + (oscAtk+oscSusTime+oscRelTime));

  switch (currentOscType) {
    case SIN: 
    SinOsc sinOsc = new SinOsc(this);
    Oscillator newSin = new Oscillator(sinOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
    oscillatorList.add(newSin);
    break;

    case SAW:
    SawOsc sawOsc = new SawOsc(this);
    Oscillator newSaw = new Oscillator(sawOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
    oscillatorList.add(newSaw);
    break;

    case SQR:
    SqrOsc sqrOsc = new SqrOsc(this);
    Oscillator newSqr = new Oscillator(sqrOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
    oscillatorList.add(newSqr);
    break;

    case TRI:
    TriOsc triOsc = new TriOsc(this);
    Oscillator newTri = new Oscillator(triOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
    oscillatorList.add(newTri);
    break;
  }


  // Add a user message
  userMessage[SIMPLE] = "Note added";
  userMessage[COMPLEX] = complexReadout + "\n" + frequencyToNoteMap.get(oscNote) + " added";
}

// Remove a filled note from the timline
void removeNote() {
  Random randy = new Random();
  int randomIndex = randy.nextInt(noteRoll.length);

  // Make sure there's a note to remove
  if (notesInTimeline <= 0) {
    timelineFull = true;
  } else {
    notesInTimeline--;
    timelineFull = false;
  }
  while (noteRoll[randomIndex] == 0 && !timelineFull) {
    randomIndex = randy.nextInt(noteRoll.length);
  }
  
  noteRoll[randomIndex] = 0;

  // Update user message
  userMessage[SIMPLE] = "Note removed";
  userMessage[COMPLEX] = complexReadout + "\n" + "Note removed";
}

// Change the oscillator type in the timeline
void changeSynth() {
  Random randy = new Random();
  currentOscType = randy.nextInt(4);
  ListIterator<Oscillator> itr = oscillatorList.listIterator();

  // Replace all the current oscillators in the oscillator list
  if (notesInTimeline != 0) {
    switch (currentOscType) {
      case SIN: 
      while (itr.hasNext()) {
        Oscillator oscToChange = itr.next();
        SinOsc newSin = new SinOsc(this);
        Oscillator newOsc = new Oscillator(newSin, SIN, oscToChange.note, 
                                           oscToChange.amplitude, oscToChange.envelope, oscToChange.attackTime, 
                                           oscToChange.sustainTime, oscToChange.sustainLevel, oscToChange.releaseTime);
        itr.set(newOsc);
      }
      break;

      case SAW:
       while (itr.hasNext()) {
        Oscillator oscToChange = itr.next();
        SawOsc newSaw = new SawOsc(this);
        Oscillator newOsc = new Oscillator(newSaw, SAW, oscToChange.note, 
                                           oscToChange.amplitude, oscToChange.envelope, oscToChange.attackTime, 
                                           oscToChange.sustainTime, oscToChange.sustainLevel, oscToChange.releaseTime);
        itr.set(newOsc);
      }
      break;

      case SQR:
       while (itr.hasNext()) {
        Oscillator oscToChange = itr.next();
        SqrOsc newSqr = new SqrOsc(this);
        Oscillator newOsc = new Oscillator(newSqr, SQR, oscToChange.note, 
                                           oscToChange.amplitude, oscToChange.envelope, oscToChange.attackTime, 
                                           oscToChange.sustainTime, oscToChange.sustainLevel, oscToChange.releaseTime);
        itr.set(newOsc);
      }
      break;

      case TRI:
       while (itr.hasNext()) {
        Oscillator oscToChange = itr.next();
        TriOsc newTri = new TriOsc(this);
        Oscillator newOsc = new Oscillator(newTri, TRI, oscToChange.note, 
                                           oscToChange.amplitude, oscToChange.envelope, oscToChange.attackTime, 
                                           oscToChange.sustainTime, oscToChange.sustainLevel, oscToChange.releaseTime);
        itr.set(newOsc);
      }
      break;
    }
  }

  println(oscillatorList.toString());

  // Update user message
  userMessage[SIMPLE] = "Changed the sound";
  userMessage[COMPLEX] = complexReadout + "\n" + "Changed to a " + oscTypes[currentOscType] + " wave oscillator";
}

// Change the key and the tempo
void changeKeyandTempo() {
  Random randy = new Random();

  // Change the key
  Arrays.fill(noteRoll, 0);
  int randomIndex = randy.nextInt(11); 
  currentRootNote = definedNotes[randomIndex];
  currentKeyIsMajor = randy.nextBoolean();
  setScale();

  // Set the maximum bpm somewhere between 40 and 120
  bpm          = (randy.nextInt(16) + 8) * 5;
  beatValue    = randy.nextInt(5) + 1;
  beatLength   = 60000 / bpm;
  beatDelay    = (int)beatLength;
  noteRoll     = new int[beatsPerBar * 4];

  userMessage[SIMPLE] = "Changed notes that will be added & speed of play";
  userMessage[COMPLEX] = complexReadout + "\nKey and Tempo Changed";
}

void startPlaying() {
  while(!userStopped){
    int i = 0;
    int oscillatorInfo = 0;
    countMessage = "";
    while (i < noteRoll.length) {
      if (noteRoll[i] == 1 && !userStopped) {
        oscillatorList.get(oscillatorInfo).run();
        oscillatorInfo++;
        userMessage[SIMPLE] = "Playing";
        userMessage[COMPLEX] = complexReadout + "\n" + "Count: " + Integer.toString(i + 1) + " - osc data: " + oscillatorInfo;
        countMessage = countMessage.concat("--|");
      } else if (!userStopped) {
          userMessage[SIMPLE] = "Playing";
          userMessage[COMPLEX] = complexReadout + "\n" + "Count: " + Integer.toString(i + 1) + " - osc data: " + oscillatorInfo;
          countMessage = countMessage.concat("--|");
        } else {
          i = noteRoll.length;
          userMessage[SIMPLE] = "Stopping...";
          userMessage[COMPLEX] = "Stopping...";
        }
      delay(beatDelay);;
      i++;
    }
  }

  countMessage = ".";
  userStopped = false;

  userMessage[SIMPLE] = "Start again?";
  userMessage[COMPLEX] = complexReadout + "\n" + "Change parameters and start again?";
}

void basicCircleButton(int buttonX, int buttonY, color background, String message, PImage imageName) {
  // Rectangle parameters
  stroke(0);
  fill(background);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  // Circle paramters
  stroke(255);
  fill(background);
  circle(buttonX+(buttonWidth/2), buttonY+(buttonHeight/2), 120);
  if (complexMode) {
    // Glyph parameters
    textAlign(CENTER, CENTER);
    fill(glyph);
    text(message, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  } else {
    imageMode(CENTER);
    image(imageName, buttonX + (buttonWidth/2), buttonY+(buttonHeight/2));
  }
}

void circleHighlightButton(int buttonX, int buttonY, color background, color highlight, String message, PImage imageName) {
  // Rectangle parameter
  stroke(0);
  fill(background);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  // Circle paramters
  stroke(255);
  fill(highlight);
  circle(buttonX+(buttonWidth/2), buttonY+(buttonHeight/2), 120);
  if (complexMode) {
    // Glyph parameters
    textAlign(CENTER, CENTER);
    fill(glyph);
    text(message, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  } else {
    imageMode(CENTER);
    image(imageName, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  }
}

void basicSquare(int buttonX, int buttonY, color background, String message, PImage imageName) {
  // Rectangle parameters
  stroke(0);
  fill(background);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  if (complexMode) {
    // Glyph & Button paramters
    stroke(255);
    fill(background);
    rect(buttonX+75, buttonY+50, 100, 100);
    textAlign(CENTER, CENTER);
    fill(glyph);
    text(message, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  } else {
    imageMode(CENTER);
    image(imageName, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  }
}

void squareHighlightButton(int buttonX, int buttonY, color background, color highlight, String message, PImage imageName) {
  // Rectangle parameter
  stroke(0);
  fill(background);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  if (complexMode) {
    // Glyph & Button paramters
    stroke(255);
    fill(highlight);
    rect(buttonX+75, buttonY+50, 100, 100);
    textAlign(CENTER, CENTER);
    fill(glyph);
    text(message, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  } else {
    imageMode(CENTER);
    image(imageName, buttonX+(buttonWidth/2), buttonY+(buttonHeight/2));
  }
}


class Oscillator extends Thread {
  SinOsc sinOsc;
  SawOsc sawOsc;
  SqrOsc sqrOsc;
  TriOsc triOsc;
  int    oscType;
  String message;
  float note;
  float amplitude;
  Env   envelope;
  float attackTime;
  float sustainTime;
  float sustainLevel;
  float releaseTime;

  // Methods for creating each type of oscillator
  Oscillator(SinOsc givenOscillator, int oscType, float givenNote, float givenAmplitude, Env givenEnvelope,
             float givenAttackTime, float givenSustainTime, float givenSustainLevel, float givenReleaseTime) {
    this.sinOsc       = givenOscillator;  this.oscType      = oscType;          this.note        = givenNote;
    this.amplitude    = givenAmplitude;   this.envelope     = givenEnvelope;    this.attackTime  = givenAttackTime;   
    this.sustainTime  = givenSustainTime; this.sustainLevel = givenSustainLevel;this.releaseTime = givenReleaseTime;
  }

  Oscillator(SawOsc givenOscillator, int oscType, float givenNote, float givenAmplitude, Env givenEnvelope,
             float givenAttackTime, float givenSustainTime, float givenSustainLevel, float givenReleaseTime) {
    this.sawOsc       = givenOscillator;  this.oscType      = oscType;          this.note        = givenNote;
    this.amplitude    = givenAmplitude;   this.envelope     = givenEnvelope;    this.attackTime  = givenAttackTime;   
    this.sustainTime  = givenSustainTime; this.sustainLevel = givenSustainLevel;this.releaseTime = givenReleaseTime;
  }

  Oscillator(SqrOsc givenOscillator, int oscType, float givenNote, float givenAmplitude, Env givenEnvelope,
             float givenAttackTime, float givenSustainTime, float givenSustainLevel, float givenReleaseTime) {
    this.sqrOsc       = givenOscillator;  this.oscType      = oscType;          this.note        = givenNote;
    this.amplitude    = givenAmplitude;   this.envelope     = givenEnvelope;    this.attackTime  = givenAttackTime;   
    this.sustainTime  = givenSustainTime; this.sustainLevel = givenSustainLevel;this.releaseTime = givenReleaseTime;
  }

  Oscillator(TriOsc givenOscillator, int oscType, float givenNote, float givenAmplitude, Env givenEnvelope,
             float givenAttackTime, float givenSustainTime, float givenSustainLevel, float givenReleaseTime) {
    this.triOsc       = givenOscillator;  this.oscType      = oscType;          this.note        = givenNote;
    this.amplitude    = givenAmplitude;   this.envelope     = givenEnvelope;    this.attackTime  = givenAttackTime;   
    this.sustainTime  = givenSustainTime; this.sustainLevel = givenSustainLevel;this.releaseTime = givenReleaseTime;
  }

  void run() {     
    if (oscType == SIN) {
      sinOsc.play(note, amplitude);
      envelope.play(sinOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    } else if (oscType == SAW) {
      sawOsc.play(note, amplitude);
      envelope.play(sawOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    } else if (oscType == SQR) {
      sqrOsc.play(note, amplitude);
      envelope.play(sqrOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    } else if (oscType == TRI) {
      triOsc.play(note, amplitude);
      envelope.play(triOsc, attackTime, sustainTime, sustainLevel, releaseTime);
    }
    delay((int)(attackTime + sustainTime + releaseTime));
  }

  void stopPlaying() {
    if (oscType == SIN) {
      sinOsc.stop();
    } else if (oscType == SAW) {
      sawOsc.stop();
    } else if (oscType == SQR) {
      sqrOsc.stop();
    } else if (oscType == TRI) {
      triOsc.stop();
    }
  }
}
