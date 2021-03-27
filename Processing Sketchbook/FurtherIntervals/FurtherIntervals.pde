// Declan Kehoe 9th September 2020

import processing.sound.*;

Sound s = new Sound(this);
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);
float note1, note2, note3;
// Processing has a 'FloatDict' that acts like a hasmap
FloatDict notes = new FloatDict();


void setup() {
  size(500, 500);
  background(255);
  
  // Set all the root notes
  notes.set("a", 440.00);
  notes.set("as", 446.16);
  notes.set("b", 493.88);
  notes.set("c", 261.63);
  notes.set("cs", 277.18);
  notes.set("d", 293.66);
  notes.set("ds", 311.13);
  notes.set("e", 329.63);
  notes.set("f", 349.23);
  notes.set("fs", 369.99);
  notes.set("g", 392.00);
  notes.set("gs", 415.30);
  
  note1 = notes.get("a");
  note2 = note1 * pow(2, (4/12.0));
  note3 = note1 * pow(2, (7/12.0));
  print("The notes are", note1, note2, note3, "\n");
  
  sin1.play(note1, 0.5);
  delay(500);
  sin2.play(note2, 0.5);
  delay(500);
  sin3.play(note3, 0.5);
}

void draw() {
  // Map vertical mouse position to a variable
  float amplitude = map(mouseY, 0, height, 1.0, 0.0);
  s.volume(amplitude);
  
}

// Makes it minor :(
void mouseClicked() {
  note2 = note1 * pow(2, (3/12.0));
  note3 = note1 * pow(2, (7/12.0));
  print("The notes are", note1, note2, note3, "\n");
  
  sin1.stop();
  sin2.stop();
  sin3.stop();
  
  sin1.play(note1, 0.5);
  delay(500);
  sin2.play(note2, 0.5);
  delay(500);
  sin3.play(note3, 0.5);
}

// Change the root note (there's no error handling yet, and no flats or sharps)
void keyPressed() {
  note1 = notes.get(str(key));
  note2 = note1 * pow(2, (4/12.0));
  note3 = note1 * pow(2, (7/12.0));
  print("The notes are" , note1, note2, note3, "/n");
  
  sin1.stop();
  sin2.stop();
  sin3.stop();
  
  sin1.play(note1, 0.5);
  delay(500);
  sin2.play(note2, 0.5);
  delay(500);
  sin3.play(note3, 0.5);
}
