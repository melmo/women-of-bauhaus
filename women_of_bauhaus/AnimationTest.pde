class AnimationTest {
  boolean distorted;
  PImage image;
  public AnimationTest() {
    distorted = true;
  
  }
  void initDistorted(String filename) {
    distorted = true;
    image = loadImage(filename);
    println(filename);
  
  }
  void runAnimation() {
    textSize(12);
    textAlign(LEFT);
    if (distorted) {
        
        fill(0,0,255);
        rect(0,0,width,height);
        fill(255);
        text("Distorted" ,0,0, 200,300);
        image(image, 0, 50);
    } else {
      fill(0,0,255);
      rect(0,0,width,height);
      fill(255);
      text("Undistorted",0,0, 200,300);
      image(image, 0, 50);
    }
 
  }
  void undistort() {
    distorted = false;
  }
  
}
