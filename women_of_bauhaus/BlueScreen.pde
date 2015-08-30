class BlueScreen {
  
  BSState bsState; // DISTORTED,UNDISTORTED,BSOD,BLUESCREEN
  Table table;
  Artwork[] artworks;
  AllListener al;
  int time;
  int currentWork;
  Animation anim;
  PFont bsFont;
  String bsodText = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.";
  int bsodCursor = 0;
  int localWidth;
  int localHeight;
  
  public BlueScreen() {
    
    bsState = BSState.BLUESCREEN;
    anim = new Animation();
    bsFont = createFont("Lucida Console", 28);
    
    table = loadTable("artists.csv", "header");
    artworks = new Artwork[table.getRowCount()];
    int rowCount = 0;
    for (TableRow row : table.rows()) {

      String artist = row.getString("artist");
      String hashtag = row.getString("hashtag");
      String title = row.getString("title");
      String filename = row.getString("filename");
      
      artworks[rowCount] = new Artwork(artist, hashtag, title, filename);
      rowCount++;
      
    }
    
    al = new AllListener();
    int currentWork = 0;
    
  }
  
  void setDimensions(int theWidth, int theHeight, boolean rotate) {
    localWidth = theWidth;
    localHeight = theHeight;
    anim.setDimensions( theWidth,  theHeight, rotate);
  }
  
  void start() {
    bsState = BSState.DISTORTED;
    time = millis();
    al.setQuery(artworks[currentWork].hashtag);
     println(artworks[currentWork].hashtag);
    thread("pollQuery");
    anim.initDistorted("Pictures/" + artworks[currentWork].filename);
  }
  
  void success() {
    switch (bsState) {
     case DISTORTED : 
       pushMatrix();
       anim.undistort();
       popMatrix();
       bsState = BSState.UNDISTORTED;
       time = millis();
     break;
    } 
  }
  
  void showBSOD() {
    fill(0,0,255);
    rect(0,0,localWidth,localHeight);
    fill(255);
    textSize(18);
    textAlign(LEFT);
    String tmpText;
    if (bsodCursor < bsodText.length()) {
      tmpText = bsodText.substring(0, bsodCursor);
    } else {
      tmpText = bsodText;
    }
    text(tmpText,20,20, localWidth - 40,localHeight - 40);
    bsodCursor++;
  }
  
  void showTag() {
    textAlign(CENTER);
    textSize(28);
    textFont(bsFont);
    fill(255);
    text("#" + artworks[currentWork].hashtag, 0, localHeight - 200, localWidth, 100);
    switch(bsState) {
      case UNDISTORTED :
        text(artworks[currentWork].title, 0, localHeight - 150, localWidth, 100);
        break;
    }
    
    
  }
  
  void loop() {
    switch (bsState) {
      case DISTORTED:
        // Check for new instagram posts every 2000 frames
        if (frameCount % 100 == 0) {
          thread("pollQuery");
        }
        pushMatrix();
        anim.runAnimation();
        popMatrix();
        showTag();
        if (millis() - time > 100000) { // should be 420000 (7 minutes)
          time = millis();
          bsodCursor = 0;
          bsState = BSState.BSOD;
        }
      
      break;
      case UNDISTORTED :
        pushMatrix();
        anim.runAnimation();
        popMatrix();
        showTag();
        if (millis() - time > 2000) { // Should be 240000 (4 minutes)
          time = millis();
          bsState = BSState.BLUESCREEN;
        }
      break;
      case BSOD :
        showBSOD();
        if (millis() - time > 30000) { // should be 90000 (90 seconds)
          time = millis();
          bsState = BSState.BLUESCREEN;
        }
      break;
      case BLUESCREEN :
        background(0,0,255,25);
        fill(255);
        if (millis() - time > 200) {
          time = millis();
          currentWork++;
          if (currentWork == artworks.length) {
            currentWork = 0;
          }
          start();
        }
        
      break;
    }
    
  }
  
}