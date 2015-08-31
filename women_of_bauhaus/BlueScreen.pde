class BlueScreen {
  
  BSState bsState; // DISTORTED,UNDISTORTED,BSOD,BLUESCREEN
  Table table;
  Artwork[] artworks;
  AllListener al;
  int time;
  int currentWork;
  Animation anim;
  PFont bsFont;
  PFont bsFontSmall;
  PFont bsFontItalic;
  String bsodText = "Ein Fehler ist aufgetreten. Der Hashtag #artist wurde nicht verwendet. \r\n\t\r\nEs liegt in unserer gesellschaftlichen Verantwortung, das Andenken an die vorgestellten Künstlerinnen zu erhalten. Sie können mithelfen, indem Sie Ihr Wissen zu diesen Persönlichkeiten mit der Welt teilen. \r\nUm Informationen zur nächsten Künstlerin zu verbreiten, benutzen Sie bitte den angezeigten Hashtag auf Twitter oder Instagram. Dadurch wird das Werk der Künstlerin direkt hier enthüllt. \r\n\t\r\nWenn Sie die angezeigten Hashtags benutzen, wird dieser Fehler nicht noch einmal auftreten. \r\n\t\r\nError: #artist : #0000ff \r\n\t\r\n\t\r\nhttp://www.bluescreenofbauhaus.de";
  int bsodCursor = 0;
  int bsodTransitionCounter = 800;
  int localWidth;
  int localHeight;
  boolean rotate;
  
  public BlueScreen() {
    
    bsState = BSState.BLUESCREEN;
    anim = new Animation();
    bsFont = loadFont("Cabin-Regular-28.vlw");
    bsFontItalic = loadFont("Cabin-Italic-28.vlw");
    bsFontSmall = loadFont("VT323-Regular-28.vlw");
    
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
    if (millis() - time < 6000) {
      pushMatrix();
      anim.runAnimation();
      popMatrix();
      resetShader();
      showTag();
    }
    if (millis() - time >= 6000 || (millis()/bsodTransitionCounter)%2 ==0) {
      pushMatrix();
      fill(0,0,255);
      textAlign(CENTER);
      textFont(bsFontSmall);
      textSize(28);
      if (rotate) {
        translate(220,-512,0);
        rect(0,0,localHeight,localWidth);
        if (millis() - time >= 6000) {
          fill(180,180,180);
          rect(120,120, localHeight-240,30);
          fill(0,0,255);
          text("Bluescreen of Bauhaus",80,126, localHeight-160,40);
        }
      } else {
        rect(0,0,localWidth,localHeight);
        if (millis() - time >= 6000) {
          
          fill(180,180,180);
          rect(120,120, localWidth-240,30);
          fill(0,0,255);
          text("Bluescreen of Bauhaus",80,126, localWidth-160,40);
        }
      }
      popMatrix();
      
    }
    if (millis() - time >= 7500) {
      pushMatrix();
      fill(230);
      textAlign(LEFT);
      String fullTmpText = bsodText.replaceAll("#artist", "#" + artworks[currentWork].hashtag);
      String tmpText;
      if (bsodCursor < fullTmpText.length()) {
        tmpText = fullTmpText.substring(0, bsodCursor);
      } else {
        tmpText = fullTmpText;
        if ((millis()/400)%2 ==0) {
          tmpText += " _";
        }
      }
      if (rotate) {
        translate(220,-512,0);
        text(tmpText,20,220, localHeight-40,localWidth-40);
      } else {
        text(tmpText,20,220, localWidth-40,localHeight - 40);
      }
      
      popMatrix();
      bsodCursor++;
    }
    bsodTransitionCounter = max(floor(bsodTransitionCounter*.99),1);
  }
  
  void showTag() {
    textAlign(CENTER);
    textSize(28);
    textFont(bsFont);
    fill(230);
    lights();
    text("#" + artworks[currentWork].hashtag, 0, localHeight - 200, localWidth, 100);
    switch(bsState) {
      case UNDISTORTED :
        fill(230,230,230,min((millis() - time)/20,255));
        textFont(bsFontItalic);
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
          bsodTransitionCounter = 800;
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