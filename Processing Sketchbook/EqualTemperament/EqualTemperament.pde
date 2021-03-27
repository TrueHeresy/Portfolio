import processing.sound.*;

SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);

void setup(){
  size(500,500);
  background(255);

// Play two sine oscillators with slightly different frequencies for a nice "beat"
 sin1.play(440, 1);
 delay(1000);
 sin2.play(440 * (3/2) * (3/2), 1);
 delay(1000);
 sin3.play(440 * (3/2) * (3/2) * (3/2) * (3/2), 1);
 delay(1000);
}

void draw(){
}
