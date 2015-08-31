import java.util.*;
import org.instagram4j.*;
import org.instagram4j.Result;
import org.instagram4j.entity.*;
import facebook4j.*;
import facebook4j.auth.*;
import twitter4j.TwitterStream;
import twitter4j.StatusListener;
import twitter4j.StallWarning;
import twitter4j.StatusDeletionNotice;
import twitter4j.Status;
import twitter4j.TwitterStreamFactory;
import twitter4j.FilterQuery;
import twitter4j.conf.ConfigurationBuilder;

BlueScreen bs;
int count = 0;
boolean rotate = true; // If this is true, rotates sketch 90 degrees clockwise in frame

void settings() {
  fullScreen(P3D);
}


void setup() {
  surface.setSize(rotate ? 1024 : 576, rotate ? 576 : 1024);
  surface.hideCursor();
  bs = new BlueScreen();
  bs.setDimensions(rotate ? 1024 : 576, rotate ? 576 : 1024, rotate);
  bs.start(); 
}

void draw() {
  pushMatrix();
  if (rotate) {
    translate(1024/2, -220,0);
    rotateZ(PI/2);   
  }
  bs.loop();
  popMatrix();
}


void pollQuery() {
  bs.al.pollQuery();
}

void keyPressed() {
  bs.success();
}