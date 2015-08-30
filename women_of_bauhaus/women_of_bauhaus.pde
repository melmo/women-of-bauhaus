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

void init()
{
 frame.removeNotify();
 frame.setUndecorated(true);
 frame.addNotify();
 super.init();
}


BlueScreen bs;
int count = 0;

void setup() {
  size(576, 1024, P3D);
  bs = new BlueScreen();
  bs.start(); 
}

void draw() {
  bs.loop();
}

void pollQuery() {
  bs.al.pollQuery();
}

void keyPressed() {
  bs.success();
}
