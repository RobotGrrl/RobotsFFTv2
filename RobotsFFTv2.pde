import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;

Serial myPort;
Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;
AudioInput input;

float kickSize, snareSize, hatSize;

void setup()
{
  size(512, 200);
  smooth();
  
  println(Serial.list());
  
  myPort = new Serial(this, Serial.list()[0], 9600);
  
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO, 2048);
  //song = minim.loadFile("marcus_kellis_theme.mp3", 2048);
  //song.play();
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(input.bufferSize(), input.sampleRate());
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(10);  
  kickSize = snareSize = hatSize = 16;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, input);  
  textFont(createFont("SanSerif", 16));
  textAlign(CENTER);
}

void draw()
{
  background(0);
  fill(255);
  if ( beat.isKick() ) {
    kickSize = 32;
    myPort.write("B");
  }
  if ( beat.isSnare() ) {
    snareSize = 32;
    myPort.write("S");
  }
  if ( beat.isHat() ) {
    hatSize = 32;
    myPort.write("H");
  }
  textSize(kickSize);
  text("KICK", width/4, height/2);
  textSize(snareSize);
  text("SNARE", width/2, height/2);
  textSize(hatSize);
  text("HAT", 3*width/4, height/2);
  kickSize = constrain(kickSize * 0.95, 16, 32);
  snareSize = constrain(snareSize * 0.95, 16, 32);
  hatSize = constrain(hatSize * 0.95, 16, 32);
}

void stop()
{
  myPort.stop();
  // always close Minim audio classes when you are finished with them
  input.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}



class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioInput source;
  
  BeatListener(BeatDetect beat, AudioInput source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

