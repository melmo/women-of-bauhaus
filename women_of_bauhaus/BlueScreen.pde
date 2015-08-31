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
  boolean rotate;
  
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
    this.rotate = rotate;
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
    background(0);
    pushMatrix();
    fill(0,0,255);
    if (rotate) {
      translate(220,-512,0);
      rect(0,0,localHeight,localWidth);
    } else {
      rect(0,0,localWidth,localHeight);
    }
    fill(255);
    textSize(18);
    textAlign(LEFT);
    String tmpText;
    if (bsodCursor < bsodText.length()) {
      tmpText = bsodText.substring(0, bsodCursor);
    } else {
      tmpText = bsodText;
    }
    if (rotate) {
      text(tmpText,20,20, localWidth-480,400);
    } else {
      text(tmpText,20,20, localWidth-40,localHeight - 40);
    }
    
    popMatrix();
    bsodCursor++;
  }
  
  void showTag() {
    textAlign(CENTER);
    textSize(28);
    textFont(bsFont);
    fill(255);
    lights();
    text("#" + artworks[currentWork].hashtag, 0, localHeight - 200, localWidth, 100);
    switch(bsState) {
      case UNDISTORTED :
        fill(255,255,255,min((millis() - time)/20,255));
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
        resetShader();
        showTag();
        fill(0,0,255,max(255 - ((millis() - time)/10),0));
        pushMatrix();
        translate(220,-512,0);
        rect(0,0,localHeight,localWidth);
        popMatrix();
        if (millis() - time > 420000) { // should be 420000 (7 minutes)
          time = millis();
          bsodCursor = 0;
          bsState = BSState.BSOD;
        }
      
      break;
      case UNDISTORTED :
        pushMatrix();
        anim.runAnimation();
        popMatrix();
        resetShader();
        showTag();
        if (millis() - time > 240000) { // Should be 240000 (4 minutes)
          time = millis();
          bsState = BSState.BLUESCREEN;
        }
      break;
      case BSOD :
        resetShader();
        showBSOD();
        if (millis() - time > 90000) { // should be 90000 (90 seconds)
          time = millis();
          bsState = BSState.BLUESCREEN;
        }
      break;
      case BLUESCREEN :
        fill(0,0,255,25);
        pushMatrix();
        translate(220,-512,0);
        rect(0,0,localHeight,localWidth);
        popMatrix();
        if (millis() - time > 2000) {
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