//import processing.opengl.*;
import java.awt.Frame;
//import javax.media.opengl.*;

PShader texlightShader;
float time = 0.0; // Cycles from 0.0 to 1.0 and starts again to animate the torus

class Animation {
  int localWidth = width;
  int localHeight = height;
  int positionOffset = 0;
  int localFrameCount;
  int numMax = 35; // divisions along larger axis (height or width of image)
  int numa = numMax; // number of columns
  int numb = numMax; // number of rows
  int subDivisions = 5; // number of quads inside each division
  float elementWidth = 10; // width and height of row/column (in pixels)
  PVector[][] Init = new PVector[numa][numb]; // init position
  PVector[][] X = new PVector[numa][numb]; // current position
  PVector[][] V = new PVector[numa][numb]; // force from wind
  PVector[][] F = new PVector[numa][numb]; // force from gravity
  float k = 0.1;
  float c = 0.01;
  float cubismEffect = 1.0; // Obscures image with cubism effect - ranges from 0.0 to 1.0
  color bg = color(0, 0, 255);
  int lightUp = 0;
  float zTranslate;
  boolean rotate = false;
  
  // Mini-square distortion
  float miniSquareDistortion = 0.0;
  
  // Transparency
  int transparency = 0; // Makes image see-through (0 = transparent, 255 = opaque)
  float transparencyCycle = 0.5; // Move from 0.0 (opaque) to 0.5 (transparent) to 1.0 (opaque)
  
  // Glitch squares
  boolean glitchesOn = false;
  int glitchX1 = 0;
  int glitchY1 = 0;
  int glitchX2 = 0;
  int glitchY2 = 0;
  int glitchX3 = 0;
  int glitchY3 = 0;

  // The following variables control the changes in the camera angle
  float speedOfMovement = 0.3; // 0.0 = no movement & 1.0 = fast movement
  float xRotation = 0.0; // Amount of rotation on x-axis
  float yRotation = 0.25; // Amount of rotation on y-axis

  // Magnitude of explosion effect
  float magnitude = 0.0;
  boolean exploding = false;

  // gravity resists the wind force by making the flag gravitate toward its initial state (i.e. flat)
  float gravity = 0.0; // Turn up to 0.1 to reduce amount of "waving in the wind"
  // the wind force begins at windStart and moves toward windEnd by windIncrement each draw cycle
  float windStart = 0.2; // The beginning amount of wind force
  float windEnd = 0.05; // The final amount of wind force
  float windIncrement = 0.0002; // The increment by which the wind force is changed each draw cycle
  float wind = windStart; // The current wind force at any given time
  
  // Flying light effect
  int numLights = 2; // max 6
  // Track position of lights
  PVector[] lightsPos = new PVector[numLights];

  // Arrays used to pass data to the texlight shader
  float[] specularContribution = new float[(numLights + 2)*3]; // Colour of specular highlight
  float[] specularFocus = new float[numLights + 2];
  float[] diffuseContribution = new float[(numLights + 2)*3]; // Colour of diffuse component
  float[] ambientLight = new float[(numLights + 2)*3]; // Colour of ambient light

  PVector[] constraint = new PVector[numMax];
  PImage flag;
  //Zubi transformation variables
  boolean distorted = true;
  boolean facingViewer = false;
  boolean portrait = true;
  boolean setWindowPosition = false;

  public Animation(){
  }
  void setDimensions(int theWidth, int theHeight, boolean rotate) {
    localWidth = theWidth;
    localHeight = theHeight;
    this.rotate = rotate;
  }

  void initDistorted(String fileName) { // Re-initialises sketch and loads file
    localFrameCount = 1;
    cubismEffect = 1.0; // Obscures image with cubism effect - ranges from 0.0 to 1.0
    bg = color(0, 0, 255);
    lightUp = 0;
    
    miniSquareDistortion = 0.0;
    
    transparency = 0; // Makes image see-through (0 = transparent, 255 = opaque)
    transparencyCycle = 0.5; // Move from 0.0 (opaque) to 0.5 (transparent) to 1.0 (opaque)
  
    xRotation = 0.0; // Amount of rotation on x-axis
    yRotation = 0.25; // Amount of rotation on y-axis
  
    magnitude = 0.0;
    exploding = false;
  
    gravity = 0.0; // Turn up to 0.1 to reduce amount of "waving in the wind"
    windIncrement = 0.0002; // The increment by which the wind force is changed each draw cycle
    wind = windStart; // The current wind force at any given time
    distorted = true;
    facingViewer = false;
    portrait = true;
    setWindowPosition = false;
    
    facingViewer = false;
    texlightShader=loadShader("texture_displacefrag.glsl","texture_displacevert.glsl");
    
    distorted = true;
    flag = loadImage(fileName);

    if(flag.width > flag.height) {
      portrait = false;
      numa = numMax;
      elementWidth = flag.width / numMax;
      numb = flag.height / (int)elementWidth;
    } else {
      portrait = true;
      numb = numMax;
      elementWidth = flag.height / numMax;
      numa = flag.width / (int)elementWidth;
    }
    //zTranslate = ((localWidth - 30) - flag.width) * 1.42298;
    

    texlightShader.set("magnitude", magnitude); // Magnitude of vector distortion in vertex shader
    texlightShader.set("offset", 0.25);
    texlightShader.set("amplitude", 0.05);
    
    for(int i = 0; i < 6; i++) {
      specularContribution[i] = 0.05;
      diffuseContribution[i] = 0.15;
      ambientLight[i] = 0.3;
    }

    for(int i = 6; i < (numLights + 2) * 3; i++) {
      specularContribution[i] = 0.5;
      diffuseContribution[i] = 0.05;
      ambientLight[i] = 0.0;
    }

    for(int i = 0; i < (numLights + 2); i++) {
      specularFocus[i] = 1.0;
    }

    // Initialise positions of lights
    for(int i = 0; i < numLights; i++) {
      lightsPos[i] = new PVector(int(random(localWidth)), (int)random (localWidth * 0.8) + localWidth * 0.1, int(random(-10.0,10.0)));
    }

    texlightShader.set("SpecularFocus", specularFocus);
    texlightShader.set("SpecularContribution", specularContribution, 3); // 3 indicates this is a 2d array, each element is of length 3
    texlightShader.set("DiffuseContribution", diffuseContribution, 3); 
    texlightShader.set("AmbientLight", ambientLight, 3);

    reset();
    setupConstraint();
  }
  
  void runAnimation() { // run from draw() in Mel's sketch
/*
    if(lightUp > 0) {
      bg = color(75 - abs(75 - lightUp), 75 - abs(75 - lightUp), 150 - abs(75 - lightUp));
      lightUp -= 1;
    }
*/
    if(!distorted) { // undistorting image
      if(transparency < 255) {
        transparency++;
      }
      if(miniSquareDistortion > 0.0 && facingViewer) {
        miniSquareDistortion -= 0.005;
      }
      glitchX1 = numa;
      glitchY1 = numb;
      glitchX2 = numa;
      glitchY2 = numb;
      glitchX3 = numa;
      glitchY3 = numb;
      gravity = 0.001;
      wind = 0.0001;
      if(cubismEffect > 0.0 && facingViewer) {
        cubismEffect -= 0.003;
        if(cubismEffect < 0.0) {
          cubismEffect = 0.0;
        }
      }
      if (magnitude != 0.0) {
        magnitude -= 0.006;
        if(magnitude < 0.0) {
          magnitude = 0.0;
          exploding = false;
        }
        texlightShader.set("magnitude", magnitude * flag.width / 2.0); // Magnitude of vector distortion
      }
    } else { // Still in distorted phase
        if(((localFrameCount + 300)%700.0) <= 200) {
          miniSquareDistortion = (100 - abs(100 - (localFrameCount + 300)%700)) / 100.0;
        }
        if(localFrameCount%15 == 0) {
          glitchX1 = (int)random(numa);
          glitchY1 = (int)random(numb);
          glitchX2 = (int)random(numa);
          glitchY2 = (int)random(numb);
          glitchX3 = (int)random(numa);
          glitchY3 = (int)random(numb);
        }

      if(localFrameCount == 800) {
        gravity = 0.0005;
      }
    
      if((localFrameCount+150)%700 == 0) {
        transparencyCycle = 0.0;
      }
      if(transparencyCycle < 1.0) {
        transparencyCycle += 0.002;
        transparency = 255 - (int)((0.5 - abs(0.5 - transparencyCycle)) * 2 * 175);
      }
    
      if(magnitude <= 0.0) {
        magnitude = 0.0;
        cubismEffect = 0.7 + 0.3 * noise(localFrameCount / 100.0);
        if(localFrameCount%700 == 0) {
          exploding = true;
          magnitude += 0.05;
          texlightShader.set("magnitude", magnitude * flag.width / 2.0); // Magnitude of vector distortion
        }
      } else if (exploding && magnitude < 1.5) {
        cubismEffect -= 0.025 / 1.5;
        magnitude += 0.025;
        texlightShader.set("magnitude", magnitude * flag.width / 2.0); // Magnitude of vector distortion
      } else {
        exploding = false;
        cubismEffect += 0.006 / 1.5;
        magnitude -= 0.006;
        texlightShader.set("magnitude", magnitude * flag.width / 2.0); // Magnitude of vector distortion
      }
  
      if(!setWindowPosition){
        //surface.setLocation(displayWidth/2 - width/2, displayHeight/2 - height/2);
        setWindowPosition = true;
      }
    }
    if(windStart < windEnd && wind < windEnd) {
      wind += windIncrement;
    } else if(windStart > windEnd && wind > windEnd) {
      wind -= windIncrement;
    }

    time = (localFrameCount % 500) / 500.0;
    texlightShader.set("breathCycle", time);
    
    //background(bg);
    background(0);
    fill(bg);
    pushMatrix();
    translate(0,0,-3000);
    box(10000.0,10000.0,2.0);
    popMatrix();
    physics(); // Apply physical forces
    pointLight(255, 255, 255, localWidth / 3, localHeight / 3, 0);
    pointLight(255, 255, 255, -localWidth / 3, -localHeight / 3, 0);

    //Zubi translations and rotations
    applyTransformations();

    // Falling lights
    for (int i = 0;i < numLights; i++) {
      PVector lp = lightsPos[i];
      // Lights don't turn suddenly on and off, they fade on and off as they come on and off screen
      int intensity = int(sin((lp.y + 500)/(localHeight + 1000) * PI) * 100);
      pointLight(intensity, intensity, intensity, lp.x, lp.y, lp.z); // Set the brightness of the lights so the texlight shader reflects light properly
      
      int speedOfLightFall = localHeight / 30;
      // Increment the position of the lights so that they appear to fall
      lp.y = lp.y + (i + 1) * map(speedOfLightFall, localHeight, 0, 0, 20);
      // Reset if required
      if (lp.y > localHeight + 500) {
        lp.x = int(random(localWidth));
        lp.y = -500;
        lp.z = int(random(-10.0,10.0));
      }
    }  

    drawSheet();
    shader(texlightShader);
    localFrameCount++;
  }
  
  void undistort() { // undistort the image
    if(distorted) {
      distorted = false;
      //lightUp = 150;
    }
  }

  void applyTransformations() {
    if(distorted) {
      if(localFrameCount > 100) {
        xRotation = (xRotation + random(0.5, 1.5) * (0.0013 * speedOfMovement))%1.0;
        yRotation = (yRotation + random(0.5, 1.5) * (0.002 * speedOfMovement))%1.0;
      }
    } else {
      if(xRotation > 0.0) {
        xRotation -= 0.0026 * speedOfMovement;
      }
      if(yRotation > 0.0) {
        yRotation -= 0.0035 * speedOfMovement;
      }
      if(xRotation < 0.0) {
        xRotation = 0.0;
      }
      if(yRotation < 0.0) {
        yRotation = 0.0;
      }
      if(xRotation == 0 && yRotation == 0) {
        facingViewer = true;
      }
    }
    
      if (rotate) {
        translate(35, -350, -800);
      }
      zTranslate = ((localWidth - 30) - flag.width) * 1.92298;

      // Go to default position
      translate((localWidth - flag.width) / 2.45, (localHeight - flag.height) / 2.0 , zTranslate );
      fill(255,0,0);
      //rect(0,0,flag.width,flag.height);

      // Rotation about the x-axis
      translate(0, flag.height / 2 - (flag.height / 2) * (cos(xRotation * 2 * PI)), -sin(xRotation * 2 * PI) * flag.height / 2);
      rotateX(2 * PI * xRotation);
      // Rotation about the y-axis
      translate(flag.width / 2 - (flag.width / 2) * (cos(yRotation * 2 * PI)), 0, sin(yRotation * 2 * PI) * flag.width / 2);
      rotateY(2 * PI * yRotation);
  }

  int[][] slate = new int[numa*numb][2];
  int nodeCount = 0;
  void collisionSetup(){
    for (int i=0; i<numa; i++){
      for (int j=0; j<numb; j++){
        slate[nodeCount][0] = i;
        slate[nodeCount][1] = j;
        nodeCount++;
      }
    }
  }
  boolean hasBeen = false;
  
  void collide(){
    float bumpRad = elementWidth * 1.5;
    if (hasBeen == false){
      collisionSetup();
      hasBeen = true;
    }
    for (int i=1; i<nodeCount; i++){
      for (int j=0; j<i; j++){
        if (testAdjacency(i,j)){
          PVector dx = PVector.sub(X[slate[j][0]][slate[j][1]],
                                   X[slate[i][0]][slate[i][1]]);
          if (abs(dx.x)<bumpRad){
            if (abs(dx.y)<bumpRad){
              if (abs(dx.z)<bumpRad){
                if (dx.mag()<bumpRad){
                  float delta = (bumpRad - dx.mag()) * k;
                  dx.normalize();
                  F[slate[j][0]][slate[j][1]].add(PVector.mult(
                                                    dx,delta));
                  F[slate[i][0]][slate[i][1]].sub(PVector.mult(
                                                    dx,delta));
                }
              }
            }
          }
        }
      }
    }
  }
  boolean testAdjacency(int i,int j){
    int a = slate[i][0];
    int b = slate[i][1];
    int c = slate[j][0];
    int d = slate[j][1];
    boolean val = false;
    if (((abs(a-c)<2)&&(abs(b-d)<2))==false){
      val = true;
    }
    return val;
  }

  void reset(){
    for (int i=0; i<numa; i++){
      for (int j=0; j<numb; j++){
        Init[i][j] = new PVector(elementWidth * (i) + 0 * localWidth/4,
                              elementWidth * (j) + 0 * localHeight/4,
                              random(-0.1,0.1));
        X[i][j] = new PVector(elementWidth * (i) + 0 * localWidth/4,
                              elementWidth * (j) + 0 * localHeight/4,
                              random(-0.1,0.1));
        V[i][j] = new PVector();
      }
    }
  }
  void physics(){
    for (int i=0; i<numa; i++){
      for (int j=0; j<numb; j++){
        F[i][j] = new PVector((Init[i][j].x - X[i][j].x) * gravity,
                              (Init[i][j].y - X[i][j].y) * gravity,
                              (Init[i][j].z - X[i][j].z) * gravity);
      }
    }
    for (int i=0; i<numa; i++){
      for (int j=0; j<numb; j++){
        normalForce(i,j);
        windForce(i,j);
      }
    }
    collide();
    for (int i=0; i<numa; i++){
      for (int j=0; j<numb; j++){
        V[i][j].add(F[i][j]);
        X[i][j].add(V[i][j]);
      }
    }
    useConstraint();
  }
  void drawSheet(){
    noStroke();
    for (int j=0; j < numb - 1; j++){
      beginShape(QUADS);
      tint(255,transparency);
      texture(flag);
 
      float xtweak = portrait ? 1.02 * flag.height/numMax : 1.02 * flag.width/numMax;
      float ytweak = xtweak;
      for (int i=0; i < numa - 1; i++){
        for (int h=0; h < subDivisions; h++){
          for (int g=0; g < subDivisions; g++){
            // Top left of quad
            float topLeftX = (((subDivisions - h) * ((subDivisions - g) * X[i][j].x + (g * X[i+1][j].x)) / subDivisions) + (h * ((subDivisions - g) * X[i][j+1].x + (g * X[i+1][j+1].x)) / subDivisions)) / subDivisions;
            float topLeftY = (((subDivisions - h) * ((subDivisions - g) * X[i][j].y + (g * X[i+1][j].y)) / subDivisions) + (h * ((subDivisions - g) * X[i][j+1].y + (g * X[i+1][j+1].y)) / subDivisions)) / subDivisions;
            float topLeftZ = (((subDivisions - h) * ((subDivisions - g) * X[i][j].z + (g * X[i+1][j].z)) / subDivisions) + (h * ((subDivisions - g) * X[i][j+1].z + (g * X[i+1][j+1].z)) / subDivisions)) / subDivisions;
            float topLeftU;
            float topLeftV;
            // Top right of quad
            float topRightX = (((subDivisions - h) * ((subDivisions - g - 1) * X[i][j].x + ((g + 1) * X[i+1][j].x)) / subDivisions) + (h * ((subDivisions - g - 1) * X[i][j+1].x + ((g + 1) * X[i+1][j+1].x)) / subDivisions)) / subDivisions;
            float topRightY = (((subDivisions - h) * ((subDivisions - g - 1) * X[i][j].y + ((g + 1) * X[i+1][j].y)) / subDivisions) + (h * ((subDivisions - g - 1) * X[i][j+1].y + ((g + 1) * X[i+1][j+1].y)) / subDivisions)) / subDivisions;
            float topRightZ = (((subDivisions - h) * ((subDivisions - g - 1) * X[i][j].z + ((g + 1) * X[i+1][j].z)) / subDivisions) + (h * ((subDivisions - g - 1) * X[i][j+1].z + ((g + 1) * X[i+1][j+1].z)) / subDivisions)) / subDivisions;
            float topRightU;
            float topRightV;
            // Bottom right of quad
            float bottomRightX = (((subDivisions - h - 1) * ((subDivisions - g - 1) * X[i][j].x + ((g + 1) * X[i+1][j].x)) / subDivisions) + ((h + 1) * ((subDivisions - g - 1) * X[i][j+1].x + ((g + 1) * X[i+1][j+1].x)) / subDivisions)) / subDivisions;
            float bottomRightY = (((subDivisions - h - 1) * ((subDivisions - g - 1) * X[i][j].y + ((g + 1) * X[i+1][j].y)) / subDivisions) + ((h + 1) * ((subDivisions - g - 1) * X[i][j+1].y + ((g + 1) * X[i+1][j+1].y)) / subDivisions)) / subDivisions;
            float bottomRightZ = (((subDivisions - h - 1) * ((subDivisions - g - 1) * X[i][j].z + ((g + 1) * X[i+1][j].z)) / subDivisions) + ((h + 1) * ((subDivisions - g - 1) * X[i][j+1].z + ((g + 1) * X[i+1][j+1].z)) / subDivisions)) / subDivisions;
            float bottomRightU;
            float bottomRightV;
            // Bottom left of quad
            float bottomLeftX = (((subDivisions - h - 1) * ((subDivisions - g) * X[i][j].x + (g * X[i+1][j].x)) / subDivisions) + ((h + 1) * ((subDivisions - g) * X[i][j+1].x + (g * X[i+1][j+1].x)) / subDivisions)) / subDivisions;
            float bottomLeftY = (((subDivisions - h - 1) * ((subDivisions - g) * X[i][j].y + (g * X[i+1][j].y)) / subDivisions) + ((h + 1) * ((subDivisions - g) * X[i][j+1].y + (g * X[i+1][j+1].y)) / subDivisions)) / subDivisions;
            float bottomLeftZ = (((subDivisions - h - 1) * ((subDivisions - g) * X[i][j].z + (g * X[i+1][j].z)) / subDivisions) + ((h + 1) * ((subDivisions - g) * X[i][j+1].z + (g * X[i+1][j+1].z)) / subDivisions)) / subDivisions;
            float bottomLeftU;
            float bottomLeftV;
            if(glitchesOn && ((i == glitchX1 && j == glitchY1) || (i == glitchX2 && j == glitchY2) || (i == glitchX3 && j == glitchY3))) {
              int randomX = (int)random(numa);
              int randomY = (int)random(numb);
              topLeftU = ((randomX + (float)g / subDivisions) * xtweak);
              topLeftV = ((randomY + (float)h / subDivisions) * ytweak);
              topRightU = ((randomX + (float)(g + 1) / subDivisions) * xtweak);
              topRightV = ((randomY + (float)h / subDivisions) * ytweak);
              bottomRightU = ((randomX + (float)(g + 1) / subDivisions) * xtweak);
              bottomRightV = ((randomY + (float)(h + 1) / subDivisions) * ytweak);
              bottomLeftU = ((randomX + (float)g / subDivisions) * xtweak);
              bottomLeftV = ((randomY + (float)(h + 1) / subDivisions) * ytweak);
            } else {
              topLeftU = ((1 - cubismEffect) * ((i + (float)g / subDivisions) * xtweak) + cubismEffect * ((i + g / subDivisions) * xtweak)) + miniSquareDistortion * xtweak * noise(0);
              topLeftV = ((1 - cubismEffect) * ((j + (float)h / subDivisions) * ytweak) + cubismEffect * ((j + h / subDivisions) * ytweak)) + miniSquareDistortion * xtweak * noise(1);
              topRightU = ((1 - cubismEffect) * ((i + (float)(g + 1) / subDivisions) * xtweak) + cubismEffect * ((i + (g + 1) / subDivisions) * xtweak)) + miniSquareDistortion * xtweak * noise(2);
              topRightV = ((1 - cubismEffect) * ((j + (float)h / subDivisions) * ytweak) + cubismEffect * ((j + h / subDivisions) * ytweak)) + miniSquareDistortion * xtweak * noise(3);
              bottomRightU = ((1 - cubismEffect) * ((i + (float)(g + 1) / subDivisions) * xtweak) + cubismEffect * ((i + (g + 1) / subDivisions) * xtweak)) + miniSquareDistortion * xtweak * noise(4);
              bottomRightV = ((1 - cubismEffect) * ((j + (float)(h + 1) / subDivisions) * ytweak) + cubismEffect * ((j + (h + 1) / subDivisions) * ytweak)) + miniSquareDistortion * xtweak * noise(5);
              bottomLeftU = ((1 - cubismEffect) * ((i + (float)g / subDivisions) * xtweak) + cubismEffect * ((i + g / subDivisions) * xtweak)) + miniSquareDistortion * xtweak * noise(6);
              bottomLeftV = ((1 - cubismEffect) * ((j + (float)(h + 1) / subDivisions) * ytweak) + cubismEffect * ((j + (h + 1) / subDivisions) * ytweak)) + miniSquareDistortion * xtweak * noise(7);
            }
            // Draw quad
            vertex(topLeftX, topLeftY, topLeftZ,
                   topLeftU, topLeftV);
            vertex(topRightX, topRightY, topRightZ,
                   topRightU, topRightV);
            vertex(bottomRightX, bottomRightY, bottomRightZ,
                   bottomRightU, bottomRightV);
            vertex(bottomLeftX, bottomLeftY, bottomLeftZ,
                   bottomLeftU, bottomLeftV);
          }
        }
      }
      endShape();
    }
  }
  void setupConstraint(){
    for (int j=1; j<4; j++){
      constraint[j] = new PVector(X[j * numa / 4][j * numb / 4].x,
                                  X[j * numa / 4][j * numb / 4].y,
                                  X[j * numa / 4][j * numb / 4].z);
    }    
  }
  void useConstraint(){
    for (int j=1; j<4; j++){
    X[j * numa / 4][j * numb / 4] = new PVector(constraint[j].x,
                          constraint[j].y,
                          constraint[j].z);
    V[j * numa / 4][j * numb / 4] = new PVector();
    }    
}

  void normalForce(int i, int j){
    int a = i+1;
    int b = j;
    force2(i,j,a,b,1);
    a = i-1;
    b = j;
    force2(i,j,a,b,1);
    a = i;
    b = j+1;
    force2(i,j,a,b,1);
    a = i;
    b = j-1;
    force2(i,j,a,b,1);
    a = i+1;
    b = j+1;
    force2(i,j,a,b,pow(2,0.5));
    a = i-1;
    b = j+1;
    force2(i,j,a,b,pow(2,0.5));
    a = i+1;
    b = j-1;
    force2(i,j,a,b,pow(2,0.5));
    a = i-1;
    b = j-1;
    force2(i,j,a,b,pow(2,0.5));
    boolean jump = true;
    if (jump == true){
      int jumper = 2;
      a = i+jumper;
      b = j;
      force2(i,j,a,b,jumper);
      a = i-jumper;
      b = j;
      force2(i,j,a,b,jumper);
      a = i;
      b = j+jumper;
      force2(i,j,a,b,jumper);
      a = i;
      b = j-jumper;
      force2(i,j,a,b,jumper);
      a = i+jumper;
      b = j+jumper;
      force2(i,j,a,b,jumper*pow(2,0.5));
      a = i-jumper;
      b = j+jumper;
      force2(i,j,a,b,jumper*pow(2,0.5));
      a = i+jumper;
      b = j-jumper;
      force2(i,j,a,b,jumper*pow(2,0.5));
      a = i-jumper;
      b = j-jumper;
      force2(i,j,a,b,jumper*pow(2,0.5));
    }
  }
  void force2(int i,int j,int a,int b,float distMult){
    float eW2 = elementWidth * distMult;
    if ((a>=0)&&(b>=0)&&(a<numa)&&(b<numb)){
      PVector dx = PVector.sub(X[a][b], X[i][j]);
      float bufferWidth = 0.01 * elementWidth;
      float delta = 0;
      if ((dx.mag() < eW2 - bufferWidth/2)||
          (dx.mag() > eW2 + bufferWidth/2)){
        delta = abs(dx.mag() - eW2)
                     - bufferWidth/2;
      }
      int sighn = 0;
      if (dx.mag() < eW2 - bufferWidth/2){
        sighn = -1;
      }else if (dx.mag() > eW2 + bufferWidth/2){
        sighn = +1;
      }
      dx.normalize();
      float v1 = dx.dot(V[i][j]);
      float v2 = dx.dot(V[a][b]);
      float dv = v2 - v1;
      float fmag = k * delta * sighn + c * dv;
      PVector df = PVector.mult(dx,fmag);
      F[i][j].add(df);
      F[a][b].sub(df);
    }
  }

  void windForce(int i,int j){
    // NOTE: vector selected based on right hand rule
    int a = i+1;
    int b = j;
    int c = i;
    int d = j+1;
    wind2(i,j,a,b,c,d);
    a = i;
    b = j+1;
    c = i-1;
    d = j;
    wind2(i,j,a,b,c,d);
    a = i-1;
    b = j;
    c = i;
    d = j-1;
    wind2(i,j,a,b,c,d);
    a = i;
    b = j-1;
    c = i+1;
    d = j;
    wind2(i,j,a,b,c,d);
  }
  void wind2(int i,int j,int a,int b,int c,int d){
    PVector windV = new PVector(wind,0.0,0.0);
    if ((a>=0)&&(b>=0)&&(a<numa)&&(b<numb)){
      if ((c>=0)&&(d>=0)&&(c<numa)&&(d<numb)){
        PVector ab = PVector.sub(X[a][b], X[i][j]);
        PVector cd = PVector.sub(X[c][d], X[i][j]);
        PVector un = ab.cross(cd);
        un.normalize();
        float fmag = un.dot(windV);
        F[i][j].add(PVector.mult(un,fmag));
      }
    }
  }
}