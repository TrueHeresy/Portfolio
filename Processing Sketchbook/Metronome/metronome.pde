import java.util.Map;
import processing.sound.*;

Sound s = new Sound(this);
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);

/*
 * Define the root frequencies around A4(440Hz)
 */
float a4 = 440.00;

/*
 * Defines the note values (lengths)
 * To be clear - the 'patternLength' is how many 'repeats'
 * of the 'barLength' are played before the next phase in
 * the generation of a pattern 
 * tickGap is defined in milliseconds and is the time before 
 * the next tick (minus the actual tickLength)
 */

float beatsPerBar = 4;
// int beatUnit = QUAVER;
float bpm = 90;
float tickLength = 100;
float tickGap = (60000 / bpm) - tickLength;
// probably only need repeat OR patternLength 
int repeats = 4;
int patternLength = repeats * 2;

void setup() {
  size(500, 500);
  background(255);
}

void draw() {
  int m = millis();
  noStroke();
  fill(m % 255);
  rect(25, 25, 50, 50);
}


void keyPressed() {
	if (key==CODED) {
    switch(keyCode) {
      case UP:
        bpm += 10;
        playMetronome();
        break;
      case DOWN:
        bpm -= 10;
        playMetronome();
        break;
       default :
       	playMetronome();
       break;
     }
	}
  else {
  	playMetronome();
  }
 }

void playMetronome() {
	tickLength = 100;
  tickGap = (60000 / bpm) - tickLength;
	for (int i = 0; i < patternLength; ++i) {
		sin1.play(a4, 0.5);
	  delay(int(tickLength));
	  sin1.stop();
	  delay(int(tickGap));
	}
}