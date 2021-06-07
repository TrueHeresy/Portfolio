/* 
 * A program that creates generative music through
 * parameters set on a GUI
 *
 * Author: Declan Kehoe (9769475), 2020/2021
 */

import java.util.*;
import processing.sound.*;

// Initialises the Sound (which allows sound output)
Sound s = new Sound(this);

// Global variables, names are self explanatory, apart from enumerating for GUI array
float     currentRootNote;
int       bpm, beatValue, beatsPerBar, beatDelay, notesInTimeline;
final int SIMPLE = 0, COMPLEX = 1, SIN = 0, SAW = 1, SQR = 2, TRI = 3;
int       currentOscType;
float     beatLength;
boolean   currentKeyIsMajor;

// For the readout on the GUI
String[]  spinner         = new String[16];
String[]  userMessage     = new String[2];
String[]  oscTypes        = new String[4];
String    countMessage    = ".";

// Decides if the whole thing will play or not...
volatile boolean userStopped  = false;

// Hash map for looking up note names to display to the user
HashMap<Float, String> frequencyToNoteMap = new HashMap<Float, String>();

// Array list holds all the oscillators that are currently added to the timeline
ArrayList<Oscillator> oscillatorList = new ArrayList<Oscillator>();

// Represents timeline, a sequence of 1s and 0s for play and don't play
Integer[] noteRoll;

// Octaves that all the sounds will be drawn from
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

// Current values of the playing elements including GUI
float[]  currentKeyFrequencies  = new float[8];
String[] currentKeyNotes = new String[8];
String   currentChordType, complexReadout, infoUpdate = "";

// Variables for button placement, graphics, colouring, and font
int     addButtonX,     addButtonY, removeButtonX, removeButtonY,
        keyAndTempoX, keyAndTempoY,  synthButtonX,  synthButtonY, 
        playButtonX,   playButtonY,   stopButtonX,   stopButtonY;
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
PImage iAdd,      iAddPressed,      iRemove, iRemovePressed,
       iKeyTempo, iKeyTempoPressed, iSound,  iSoundPressed,
       iPlay,     iPlayPressed,     iStop,   iStopPressed;
PFont  menlo;


/*  -----  *\
|*  SETUP  *|
\*  -----  */
void setup() {
  // Size of the canvas
  size(500, 750);
  // Set up font (this may not look right on Windows)
  menlo = createFont("Menlo", 15);
  textFont(menlo);
  
  // Define the frequencies for notes, C4 - B5
  definedNotes[0] = 261.63;  definedNotes[1] = 277.18;  definedNotes[2] = 293.66;  definedNotes[3] = 311.13; 
  definedNotes[4] = 329.63;  definedNotes[5] = 349.23;  definedNotes[6] = 369.99;  definedNotes[7] = 392.00; 
  definedNotes[8] = 415.30;  definedNotes[9] = 440.00;  definedNotes[10] = 466.16; definedNotes[11] = 493.88; 
  
  definedNotes[12] = 523.25; definedNotes[13] = 554.37; definedNotes[14] = 587.33; definedNotes[15] = 622.25; 
  definedNotes[16] = 659.26; definedNotes[17] = 698.46; definedNotes[18] = 739.99; definedNotes[19] = 783.99; 
  definedNotes[20] = 830.61; definedNotes[21] = 880.00; definedNotes[22] = 932.33; definedNotes[23] = 987.77;

  // Defining colours
  addButtonColor         = #EAF0F8; addButtonHighlight     = #D2DEEF; // Blue & Dark Blue
  removeButtonColor      = #EAF0F8; removeButtonHighlight  = #D2DEEF; // Blue & Dark Blue
  keyAndTempoButtonColor = #EAF0F8; keyAndTempoHighlight   = #D2DEEF; // Blue & Dark Blue
  synthButtonColor       = #EAF0F8; synthButtonHighlight   = #D2DEEF; // Blue & Dark Blue
  playButtonColor        = #D0F0D3; playButtonHighlight    = #A8ECAE; // Green & Dark Green
  stopButtonColor        = #F6A4A4; stopButtonHighlight    = #FE7676; // Red & Dark Red
  glyph = #717171; // Grey

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
  
  // Build the octave ranges for root notes (this could be done dynamically)
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

  // Descibe oscillator types for the GUI
  oscTypes[0] = "Sin"; oscTypes[1] = "Saw"; oscTypes[2] = "Square"; oscTypes[3] = "Triangle";

  // Load in GUI images
  iAdd      = loadImage("Add.png");      iAddPressed      = loadImage("AddPressed.png"); 
  iRemove   = loadImage("Remove.png");   iRemovePressed   = loadImage("RemovePressed.png");
  iKeyTempo = loadImage("KeyTempo.png"); iKeyTempoPressed = loadImage("KeyTempoPressed.png");
  iSound    = loadImage("Sound.png");    iSoundPressed    = loadImage("SoundPressed.png");
  iPlay     = loadImage("Play.png");     iPlayPressed     = loadImage("PlayPressed.png");
  iStop     = loadImage("Stop.png");     iStopPressed     = loadImage("StopPressed.png");  

  // Start with a default root note, key, oscillator type, bpm, and empty timeline (noteroll)
  currentRootNote   = definedNotes[2];
  notesInTimeline   = 0;
  currentKeyIsMajor = false;
  currentChordType  = "Minor";
  currentOscType    = TRI;
  bpm               = 70;
  beatValue         = 4;
  beatsPerBar       = 4;
  beatLength        = 60000 / bpm;
  beatDelay         = (int)beatLength;
  noteRoll          = new Integer[16];
  setScale();
  Arrays.fill(noteRoll, 0);
  
  // Populate the GUI with start messages
  userMessage[SIMPLE] = "Click in this black box at any time for more detail" +
                        "\nTry all the buttons, go slow, it's all chill :)" +
                        "\nHint: + Adds notes | - Removes notes | \u25b6 Plays";
  userMessage[COMPLEX] = "Clicking again returns to the less detailed look ;)\n" + 
                         "Key: " + frequencyToNoteMap.get(currentRootNote) + (currentKeyIsMajor ? "maj " : "min ") + 
                         "\nTempo: " + bpm + "bpm" + "     |     Oscillator: " + oscTypes[currentOscType];
  // Build the progress spinner array                         
  spinner[0] = "-";  spinner[1] = "\\"; spinner[2] = "|"; spinner[3] = "/"; 
  spinner[4] = "-";  spinner[5] = "\\"; spinner[6] = "|"; spinner[7] = "/";
  spinner[8] = "-";  spinner[9] = "\\"; spinner[10] = "|";spinner[11] = "/"; 
  spinner[12] = "-"; spinner[13] = "\\";spinner[14] = "|";spinner[15] = "/"; 
} // End setup


/*  -----  *\
|*  DRAW!  *|
\*  -----  */
void draw() {
  // Track the mouse and fill in the window
  update(mouseX, mouseY);
  background(color(0));
  
  // Constantly update the readout with the key, key notes, tempo, and oscillator type
  complexReadout = "Key: " + frequencyToNoteMap.get(currentRootNote) + (currentKeyIsMajor ? "maj " : "min ") + Arrays.toString(currentKeyNotes) +
                    "\nTempo: " + bpm + "bpm" + "     |     Oscillator: " + oscTypes[currentOscType];

  // Get the note names
  for (int i = 0; i < currentKeyFrequencies.length; ++i) {
    currentKeyNotes[i] = frequencyToNoteMap.get(currentKeyFrequencies[i]);
  }

  // User layout
  textAlign(CENTER,TOP); 
  fill(255);
  // Simple mode definition and positioning
  if (!complexMode) {
    text(userMessage[SIMPLE], 250, 10);
    textAlign(LEFT, CENTER);
    // Timeline
    fill(255);
    text(Arrays.toString(noteRoll) + "\n" + countMessage, 28, 125);
    // Draw and track the buttons for highlighting
    if (addButtonOver) {
      circleHighlightButton(addButtonX, addButtonY, addButtonColor, addButtonHighlight, "", iAddPressed);
    } else { basicCircleButton(addButtonX, addButtonY, addButtonColor, "", iAdd); }
    if (removeButtonOver) {
      circleHighlightButton(removeButtonX, removeButtonY, removeButtonColor, removeButtonHighlight, "", iRemovePressed);
    } else { basicCircleButton(removeButtonX, removeButtonY, removeButtonColor, "", iRemove); }
    if (keyAndTempoOver) {
      circleHighlightButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, keyAndTempoHighlight, "", iKeyTempoPressed);
    } else { basicCircleButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, "", iKeyTempo); }
    if (synthButtonOver) {
      circleHighlightButton(synthButtonX, synthButtonY, synthButtonColor, synthButtonHighlight, "", iSoundPressed);
    } else { basicCircleButton(synthButtonX, synthButtonY, synthButtonColor, "", iSound); }
    if (playButtonOver || nowPlaying) {
      squareHighlightButton(playButtonX, playButtonY, playButtonColor, playButtonHighlight, "", iPlayPressed);
    } else { basicSquare(playButtonX, playButtonY, playButtonColor, "", iPlay); }
    if (stopButtonOver) {
      squareHighlightButton(stopButtonX, stopButtonY, stopButtonColor, stopButtonHighlight, "", iStopPressed);
    } else { basicSquare(stopButtonX, stopButtonY, stopButtonColor, "", iStop); }
  } 
  // Complex mode defintion and positioning
  else {
    text(userMessage[COMPLEX],
        250, 10);
    textAlign(LEFT, CENTER);
    // Timeline
    fill(255);
    text(Arrays.toString(noteRoll) + "\n" + countMessage, 28, 125);
    // Draw and track the buttons for highlighting
    if (addButtonOver) {
      circleHighlightButton(addButtonX, addButtonY, addButtonColor, addButtonHighlight, "ADD A\nNOTE", iAddPressed);
    } else { basicCircleButton(addButtonX, addButtonY, addButtonColor, "ADD A\nNOTE", iAdd); }
    if (removeButtonOver) {
      circleHighlightButton(removeButtonX, removeButtonY, removeButtonColor, removeButtonHighlight, "REMOVE\nA NOTE", iRemove);
    } else { basicCircleButton(removeButtonX, removeButtonY, removeButtonColor, "REMOVE\nA NOTE", iRemovePressed); }
    if (keyAndTempoOver) {
      circleHighlightButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, keyAndTempoHighlight, "CHANGE\nKEY &\nTEMPO", iKeyTempo);
    } else { basicCircleButton(keyAndTempoX, keyAndTempoY, keyAndTempoButtonColor, "CHANGE\nKEY &\nTEMPO", iKeyTempoPressed); }
    if (synthButtonOver) {
      circleHighlightButton(synthButtonX, synthButtonY, synthButtonColor, synthButtonHighlight, "CHANGE\nSOUND", iSound);
    } else { basicCircleButton(synthButtonX, synthButtonY, synthButtonColor, "CHANGE\nSOUND", iSoundPressed); }
    if (playButtonOver || nowPlaying) {
      squareHighlightButton(playButtonX, playButtonY, playButtonColor, playButtonHighlight, "PLAY", iPlay);
    } else { basicSquare(playButtonX, playButtonY, playButtonColor, "PLAY", iPlayPressed); }
    if (stopButtonOver) {
      squareHighlightButton(stopButtonX, stopButtonY, stopButtonColor, stopButtonHighlight, "STOP", iStop);
    } else { basicSquare(stopButtonX, stopButtonY, stopButtonColor, "STOP", iStopPressed); }
  } 
} // End draw


/*                      *\
|* Interaction handling *|
\*                      */
// Following the mouse
boolean hoveringOver(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) { return true; } 
  else { return false; }
}

// Handle selections from mouse movements, triggered every screen refresh
void update(int x, int y) {
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

// Handle clicking the mouse while over the various function buttons
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
    // Plays only if there are notes to play
    if (!Arrays.asList(noteRoll).contains(1)) {
      infoUpdate = "\nMake sure to add a note before you play!";
      userMessage[SIMPLE] = userMessage[SIMPLE] + infoUpdate;
      userMessage[COMPLEX] = userMessage[COMPLEX] + infoUpdate;
    } else {
      nowPlaying = true;
      thread("startPlaying");
    }
  }
  if (stopButtonOver) {
  }
  // Bug fix TODO - if an osc is playing but then all notes are removed from the
  // note list, the attached oscillator can't be stopped as it is now detached 
  if (stopButtonOver && nowPlaying) {
    userStopped = true;
    nowPlaying = false;
    for (Oscillator oscillator : oscillatorList) {
      oscillator.stopPlaying();
    }
    infoUpdate = "";
  }
  // Switches betwen 
  if (readoutOver) {
    complexMode = !complexMode;
  }
}


/*              *\
|*    METHODS   *|
\*              */

// Sets the notes to use via the defined octaves
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
  // Set the intervals correctly for major or minor
  if (currentKeyIsMajor) {
    currentKeyFrequencies[0] = currentRootNote; currentKeyFrequencies[1] = noteBank[2]; currentKeyFrequencies[2] = noteBank[4];  currentKeyFrequencies[3] = noteBank[5];
    currentKeyFrequencies[4] = noteBank[7];     currentKeyFrequencies[5] = noteBank[9]; currentKeyFrequencies[6] = noteBank[11]; currentKeyFrequencies[7] = noteBank[12];
  } else if (!currentKeyIsMajor) {
    currentKeyFrequencies[0] = currentRootNote; currentKeyFrequencies[1] = noteBank[2]; currentKeyFrequencies[2] = noteBank[3];  currentKeyFrequencies[3] = noteBank[5];
    currentKeyFrequencies[4] = noteBank[7];     currentKeyFrequencies[5] = noteBank[8]; currentKeyFrequencies[6] = noteBank[10]; currentKeyFrequencies[7] = noteBank[12];
  }
  // For debugging, print the current key frequencies to console
  print("New Note Frequencies: " + currentKeyFrequencies[0]);
  for (int i = 1; i < currentKeyFrequencies.length; ++i) {
    print(", " + currentKeyFrequencies[i]);
  }
  println();
}

// Adds a note to a random point in the timeline
void addNote() {
  Random randy = new Random();
  int randomIndex = randy.nextInt(noteRoll.length);

  // Ensures note is added to an empty place in the timeline
  if (notesInTimeline >= 16) {
    timelineFull = true;
    // Update user message
    userMessage[SIMPLE] = infoUpdate = "\nNo room to add a note, remove one first...";
    userMessage[COMPLEX] = complexReadout + "\nNo room to add a note, remove one first...";
  } else {
    notesInTimeline++;
    timelineFull = false;
    while (noteRoll[randomIndex] == 1 && !timelineFull) {
      randomIndex = randy.nextInt(noteRoll.length);
    }
    noteRoll[randomIndex] = 1;
    // Now change to a random index for the note
    randomIndex = randy.nextInt(currentKeyFrequencies.length - 1);
    // New envelope to attach to the oscillator
    Env    envelope   = new Env(this);
    // Set the oscillator paramters
    float  oscNote    = currentKeyFrequencies[randomIndex];
    float  oscAmp     = 0.3;
    float  oscSusTime = ((beatLength * ((randy.nextInt(16) + beatsPerBar))) / 1000);
    float  oscAtk     = oscSusTime / 3;
    float  oscSusLvl  = 0.25 + randy.nextFloat() * (0.8 - 0.25);
    float  oscRelTime = oscSusTime / 3;
    // For bugfinding print the oscillator stats to the console
    println("Note: "      + frequencyToNoteMap.get(oscNote) +
            ", Attack: "  + oscAtk + 
            ", Sustain: " + oscSusTime +
            ", Level: "   + oscSusLvl +
            ", Release: " + oscRelTime + 
            ", Total: "   + (oscAtk+oscSusTime+oscRelTime));
    // Based on the current oscillator type, create a new oscillator of the correct type 
    //(maybe this logic could be moved to the oscillator class)
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
    // Update the user message
    userMessage[SIMPLE] = infoUpdate = "\nAdded a note";
    userMessage[COMPLEX] = complexReadout + "\n" + frequencyToNoteMap.get(oscNote) + " added";
  }
}

// Removes a filled note from the timline, and the oldest oscillator from the oscillator list
void removeNote() {
  Random randy = new Random();
  int randomIndex = randy.nextInt(noteRoll.length);

  // Make sure there's a note to remove
  if (notesInTimeline <= 0) {
    timelineFull = true;
    // Update user message
    userMessage[SIMPLE] = infoUpdate = "\nNo note to remove";
    userMessage[COMPLEX] = complexReadout + "\nNo note to remove";
  } else {
    notesInTimeline--;
    timelineFull = false;
    while (noteRoll[randomIndex] == 0 && !timelineFull) {
      randomIndex = randy.nextInt(noteRoll.length);
    }
    noteRoll[randomIndex] = 0;
    oscillatorList.remove(0);
    
    // Update user message
    userMessage[SIMPLE] = infoUpdate = "\nRemoved a note";
    userMessage[COMPLEX] = complexReadout + "\n" + "Note removed";
  }
}

// Change the key and the tempo
void changeKeyandTempo() {
  Random randy = new Random();

  // Change the key
  int randomIndex = randy.nextInt(11); 
  currentRootNote = definedNotes[randomIndex];
  currentKeyIsMajor = randy.nextBoolean();
  setScale();

  // Set the maximum bpm somewhere between 40 and 120
  bpm          = (randy.nextInt(16) + 8) * 5;
  beatValue    = randy.nextInt(5) + 1;
  beatLength   = 60000 / bpm;
  beatDelay    = (int)beatLength;  

  // Work through the list of oscillators and replace them all with the new parameters
  ListIterator<Oscillator> itr = oscillatorList.listIterator();
  if (notesInTimeline != 0) {
    while (itr.hasNext()) {
      randomIndex = randy.nextInt(currentKeyFrequencies.length - 1);
      itr.next();
      Env    envelope   = new Env(this);
      float  oscNote    = currentKeyFrequencies[randomIndex];
      float  oscAmp     = 0.3;
      float  oscSusTime = ((beatLength * ((randy.nextInt(16) + beatsPerBar))) / 1000);
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
          itr.set(newSin);
        break;

        case SAW:
          SawOsc sawOsc = new SawOsc(this);
          Oscillator newSaw = new Oscillator(sawOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
          itr.set(newSaw);
        break;

        case SQR:
          SqrOsc sqrOsc = new SqrOsc(this);
          Oscillator newSqr = new Oscillator(sqrOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
          itr.set(newSqr);
        break;

        case TRI:
          TriOsc triOsc = new TriOsc(this);
          Oscillator newTri = new Oscillator(triOsc, currentOscType, oscNote, oscAmp, envelope, oscAtk, oscSusTime, oscSusLvl, oscRelTime);
          itr.set(newTri);
        break;
      }
    }
  }

  userMessage[SIMPLE] = infoUpdate = "\nChanged key & speed of play";
  userMessage[COMPLEX] = complexReadout + "\nKey and Tempo Changed";
}

// Changes the type of oscillator in the list
void changeSynth() {
  // There are 4 different types of oscillator, so pick one at random
  Random randy = new Random();
  int nextOscType = randy.nextInt(4);
  // Keep picking randoms until the new type is different from the current one
  while(nextOscType == currentOscType) {
    nextOscType = randy.nextInt(4);
  }
  currentOscType = nextOscType;

  // Go through all the current oscillators in the list and change them to the new type
  ListIterator<Oscillator> itr = oscillatorList.listIterator();
  if (notesInTimeline != 0) {
    while (itr.hasNext()) {
    Oscillator updatedOscillator = updateOscillator(itr.next());
    itr.set(updatedOscillator);
    }
  }

  // Update user message
  userMessage[SIMPLE] = infoUpdate = "\nChanged the sound";
  userMessage[COMPLEX] = complexReadout + "\n" + "Changed to a " + oscTypes[currentOscType] + " wave oscillator";
}

// Returns a new oscillator based on the supplied oscillator and the current oscillator type
Oscillator updateOscillator(Oscillator suppliedOsc) {
  Oscillator newOsc = suppliedOsc;
  switch (currentOscType) {
    case SIN: 
      SinOsc newSin = new SinOsc(this);
      newOsc = new Oscillator(newSin, SIN, suppliedOsc.note, suppliedOsc.amplitude, suppliedOsc.envelope, suppliedOsc.attackTime, 
                              suppliedOsc.sustainTime, suppliedOsc.sustainLevel, suppliedOsc.releaseTime);
      break;

    case SAW:
      SawOsc newSaw = new SawOsc(this);
      newOsc = new Oscillator(newSaw, SAW, suppliedOsc.note, suppliedOsc.amplitude, suppliedOsc.envelope, suppliedOsc.attackTime, 
                              suppliedOsc.sustainTime, suppliedOsc.sustainLevel, suppliedOsc.releaseTime);
      break;

    case SQR:
      SqrOsc newSqr = new SqrOsc(this);
      newOsc = new Oscillator(newSqr, SQR, suppliedOsc.note, suppliedOsc.amplitude, suppliedOsc.envelope, suppliedOsc.attackTime, 
                              suppliedOsc.sustainTime, suppliedOsc.sustainLevel, suppliedOsc.releaseTime);
      break;

    case TRI:
      TriOsc newTri = new TriOsc(this);
      newOsc = new Oscillator(newTri, TRI, suppliedOsc.note, suppliedOsc.amplitude, suppliedOsc.envelope, suppliedOsc.attackTime, 
                              suppliedOsc.sustainTime, suppliedOsc.sustainLevel, suppliedOsc.releaseTime);
      break;
  }
  return newOsc;
}

// The main loop of the timeline
void startPlaying() {
  while(!userStopped){
    int ticker = 0;    // The ticker represents a count going over the timeline
    int oscToPlay = 0; // The oscillator in the oscillator list that will play next
    countMessage = ""; // Forms the ASCII counter that will show under the timeline to indicate place 
    System.out.println("New cycle"); // For debugging
    while (ticker < noteRoll.length) {
      if (oscillatorList.size() == 0 || notesInTimeline == 0) { // Handling if there are no notes
        System.out.println(ticker + "| !: next osc " + (oscToPlay) + " of " + oscillatorList.size() + ", in timeline of " + notesInTimeline);
        oscillatorList.clear();
        userMessage[SIMPLE] = spinner[ticker] + "\nNothing to play, add a note!";
        userMessage[COMPLEX] = complexReadout + "\n Nothing to play, add a note!";
        countMessage = countMessage.concat("--|");
      }
      else if (oscToPlay + 1 > oscillatorList.size()) { // If the user removed an oscillator before the end of the cycle, needs correcting or IOB error
        System.out.print(ticker + "| X: next osc " + (oscToPlay + 1) + " of " + oscillatorList.size() + ", in timeline of " + notesInTimeline);
        oscToPlay = oscillatorList.size() - 1;
        oscillatorList.get(oscToPlay).run();
        System.out.println(" (fixed to osc " + (oscToPlay + 1) + ")");
        
        //Updating the display, it gets a bit nuts so, please just read closely...
        userMessage[SIMPLE] = "Playing " + spinner[ticker] + "\n" + infoUpdate;
        userMessage[COMPLEX] = complexReadout + "\n" + Integer.toString(ticker + 1) + "| " + 
        (oscToPlay == 0 ? frequencyToNoteMap.get(oscillatorList.get(oscToPlay).note) : frequencyToNoteMap.get(oscillatorList.get(oscToPlay - 1).note)) + " playing for " + 
        (int)(oscToPlay == 0 ? (oscillatorList.get(oscToPlay).attackTime + oscillatorList.get(oscToPlay).sustainTime + oscillatorList.get(oscToPlay).releaseTime) : 
          (oscillatorList.get(oscToPlay -1).attackTime + oscillatorList.get(oscToPlay -1).sustainTime + oscillatorList.get(oscToPlay -1).releaseTime)) + " seconds";
        countMessage = countMessage.concat("--|");
      } else if (noteRoll[ticker] == 1 && !userStopped) {
        System.out.println(ticker + "| 1: next osc " + (oscToPlay + 1) + " of " + oscillatorList.size() + ", in timeline of " + notesInTimeline);
        oscillatorList.get(oscToPlay).run();
        oscToPlay++;
        
        // Updating the display again, this should be a method really
        userMessage[SIMPLE] = "Playing " + spinner[ticker] + "\n" + infoUpdate;
        userMessage[COMPLEX] = complexReadout + "\n" + Integer.toString(ticker + 1) + "| " + 
        (oscToPlay == 0 ? frequencyToNoteMap.get(oscillatorList.get(oscToPlay).note) : frequencyToNoteMap.get(oscillatorList.get(oscToPlay - 1).note)) + " playing for " + 
        (int)(oscToPlay == 0 ? (oscillatorList.get(oscToPlay).attackTime + oscillatorList.get(oscToPlay).sustainTime + oscillatorList.get(oscToPlay).releaseTime) : 
          (oscillatorList.get(oscToPlay -1).attackTime + oscillatorList.get(oscToPlay -1).sustainTime + oscillatorList.get(oscToPlay -1).releaseTime)) + " seconds";
        countMessage = countMessage.concat("--|");
      } 
      
      else if (noteRoll[ticker] == 0 && !userStopped) {
          System.out.println(ticker + "| 0: next osc " + (oscToPlay + 1) + " of " + oscillatorList.size() + ", in timeline of " + notesInTimeline);
          // Just update the user message, but it should still be a method...
          userMessage[SIMPLE] = "Playing " + spinner[ticker] + "\n" + infoUpdate;
          userMessage[COMPLEX] = complexReadout + "\n" + Integer.toString(ticker + 1) + "| " + 
          (oscToPlay == 0 ? frequencyToNoteMap.get(oscillatorList.get(oscToPlay).note) : frequencyToNoteMap.get(oscillatorList.get(oscToPlay - 1).note)) + " playing for " + 
          (int)(oscToPlay == 0 ? (oscillatorList.get(oscToPlay).attackTime + oscillatorList.get(oscToPlay).sustainTime + oscillatorList.get(oscToPlay).releaseTime) : 
            (oscillatorList.get(oscToPlay -1).attackTime + oscillatorList.get(oscToPlay -1).sustainTime + oscillatorList.get(oscToPlay -1).releaseTime)) + " seconds";
          countMessage = countMessage.concat("--|");
        } else {
          ticker = noteRoll.length;
          userMessage[SIMPLE] = "Stopping...\n" + infoUpdate;
          userMessage[COMPLEX] = "Stopping...";
        }
      delay(beatDelay);
      ticker++;
    }
  }
  countMessage = ".";
  infoUpdate = "";
  userStopped = false;

  userMessage[SIMPLE] = "Start again?\n\n(If you can still hear sounds don't worry,\nthey will fade...)" + infoUpdate;
  userMessage[COMPLEX] = complexReadout + "\n" + "Change parameters and start again?\n(Excess sounds will fade...)";
}


/*              *\
|*    DRAWING   *|
\*              */
// Makes a circle button
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

// Makes a highlgihted circle button
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

// Makes a square button
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

// Makes a highlighted square button
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

// The oscillator class
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
