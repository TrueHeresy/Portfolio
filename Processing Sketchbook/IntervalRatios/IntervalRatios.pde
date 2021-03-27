import processing.sound.*;

Sound s = new Sound(this);
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);
float note1, note2, note3;

// Set up all the root frequencies around A440Hz (hashmap would be better)
float A = 440.00;
float AS = 446.16;
float B = 493.88;
float C = 261.63;
float CS = 277.18;
float D = 293.66;
float DS = 311.13;
float E = 329.63;
float F = 349.23;
float FS = 369.99;
float G = 392.00;
float GS = 415.30;


void setup() {
  size(500, 500);
  background(255);
  
  note1 = C;
  note2 = note1 * pow(2, (4/12.0));
  note3 = note1 * pow(2, (7/12.0));
  print("The notes are %f %f %f" ,note1, note2, note3);
  
  sin1.play(note1, 0.5);
  delay(500);
  sin2.play(note2, 0.5);
  delay(500);
  sin3.play(note3, 0.5);
}

void draw() {
}
