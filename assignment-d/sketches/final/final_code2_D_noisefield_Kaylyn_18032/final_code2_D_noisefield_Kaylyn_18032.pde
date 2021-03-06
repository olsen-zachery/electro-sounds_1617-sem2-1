//"Breathe" by Kaylyn Lee (18032)
//Electro-Sounds AY1617
//Lecturer Andreas Schlegel
//Inspired by Fluid Leaves, Okdeluxe
//Soundtrack Used: "Breathe" by Kaylyn Lee
//https://vimeo.com/213677997
//Libraries Used: Minim, Beat detect, Syphon, CP5

//IMPORT LIBRARIES

import ddf.minim.*;
import ddf.minim.analysis.*;
import codeanticode.syphon.SyphonServer;
import controlP5.*;

//ESTABLISH

Minim minim;
AudioInput in;
BeatDetect beat;
SyphonServer syphon;
ControlP5 cp5;
PGraphics buffer;


//VARIABLES

float noiseStrength = 100, noiseScale = 300;
float overlayAlpha = 70;
float randomize;
float x, y;

//CREATE ARRAY LIST

ArrayList<Agent> agents;

//Syphon Settings

void settings() {
  size(1280, 720, P3D);
  PJOGL.profile=1;
  smooth(8); //smooth lines
}

//SETUP
void setup() {

  //Syphon + Minim
  
  syphon = new SyphonServer( this, "p5-to-syphon" );
  minim = new Minim(this);
  minim.debugOn();
  in = minim.getLineIn(Minim.STEREO, 128);
  beat = new BeatDetect();
  
  //buffer to not render Cp5 into Syphon but control it inside Processing only.
  
  buffer = createGraphics(1280, 720, P3D);
  cp5 = new ControlP5(this);
  cp5.addSlider("noiseStrength").setRange(1, 100).setPosition(20, 20).setSize(200, 20);
  cp5.addSlider("noiseScale").setRange(1, 500).setPosition(20, 50).setSize(200, 20);
  cp5.addSlider("overlayAlpha").setRange(1, 128).setPosition(20, 80).setSize(200, 20);
  cp5.addBang("randomize").setPosition(300, 20).setSize(50, 50);
  // cp5.setAutoDraw(false);

  //create no. of agents, loop and add agents.
  
  agents = new ArrayList();

  for (int i=0; i<10000; i++) {
    agents.add(new Agent());
  }
}

//DRAW

void draw() {

//DRAW FLUIDS

  beat.detect(in.mix);
  buffer.beginDraw();
  buffer.background(0);
  buffer.noStroke();
  buffer.fill(0, overlayAlpha);
  buffer.rect(0, 0, width, height);
  buffer.strokeWeight(1);
  if ( beat.isOnset() ) {
    buffer.strokeWeight(15);
  }
  for (Agent agent : agents) {
    agent.update();
  }
  buffer.endDraw();
  image(buffer, 0 , 0);
  syphon.sendImage(buffer); // end of syphon
 
}

//Keyboard movement if cp5 still cant be removed in Syphon view, but problem solved.
void keyPressed() {
  if (key=='2') {
    cp5.setAutoDraw(!cp5.isAutoDraw());
  }
}

//randomize agents moving patterns

void randomize() {
  for (Agent agent : agents) {
    agent.randomize();
  }
}

class Agent {
  PVector current, previous, n1, velocity;
  float speed;
  int col;

//draw agents 

  Agent() {
    current = new PVector(random(width), random(height));
    previous = new PVector().set(current);
    speed = random(1, 4);
    col = color(255);
    // col = color(random(255),random(255),random(255));
  }

  void update() {
    
    float angle = noise(current.x/noiseScale, current.y/noiseScale) * noiseStrength;
    current.x += cos(angle) * speed;
    current.y += sin(angle) * speed;

    if (current.x<0 || current.x>width || current.y<0 || current.y>height) {
      randomize();
    }    

    buffer.stroke(col);
    buffer.line(previous.x, previous.y, current.x, current.y);
    
    previous.set(current);
  }

  void randomize() {
    current.x = random(width);
    current.y = random(height);
    previous.set(current);
  }
}
