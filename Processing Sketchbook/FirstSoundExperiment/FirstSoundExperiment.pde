// Code is based on https://processing.org/reference/libraries/sound/Sound.html

import processing.sound.*;
Sound s;
SinOsc sin1 = new SinOsc(this);
SinOsc sin2 = new SinOsc(this);
SinOsc sin3 = new SinOsc(this);

void setup(){
  size(500,500);
  background(255);

// Play two sine oscillators with slightly different frequencies for a nice "beat".
 sin1.play(100, 0.5);
 sin2.play(120, 0.5);
 sin3.play(150, 0.5);
 
 s = new Sound(this);
 
}

void draw(){
  // Map vertical mouse position to a variable
  float amplitude = map(mouseY, 0, height, 0.4, 0.0);
  float pitch = map(mouseX, 0, width, 0, 500);
  
  // Use the amplitude variable to control volume
  s.volume(amplitude);
  sin1.freq(pitch);
  sin2.freq(pitch * pow(2, (3/12));
  sin3.freq(pitch * pow(2, (5/12));
}
