/*
====================================================================
                 SQUARE GRID SNACK CHIP 3D
                 APDE / PROCESSING ANDROID / P3D

                 TRUE HOLLOW SQUARE VERSION
====================================================================

FEATURES
--------------------------------------------------------------------
• ONLY SQUARE CHIP
• TRUE HOLLOW 3D EXTRUDED STRUCTURE
• SQUARE OUTER RIM
• SQUARE INNER OPENING
• VERTICAL GRID
• HORIZONTAL GRID
• EMPTY GRID CELLS ARE FULLY HOLLOW
• AUTO ROTATION
• DRAG ROTATION
• TOUCH SLIDERS
====================================================================
*/

// ================================================================
// BACKGROUND
// ================================================================

int BG_R = 7;
int BG_G = 11;
int BG_B = 25;


// ================================================================
// GRID SETTINGS
// ================================================================

int verticalGrid   = 4;
int horizontalGrid = 4;

int speedValue = 20;


// ================================================================
// ROTATION
// ================================================================

float globalRotation = 0.0;

boolean dragging = false;
float previousX = 0;

int selectedSlider = -1;


// ================================================================
// CHIP COLOR
// ================================================================

color chipColor = color(255, 157, 30);


// ================================================================
// 3D GEOMETRY
// ================================================================

final float CHIP_DEPTH = 12.0;

final float TOP_Z =
  CHIP_DEPTH * 0.5;

final float BOTTOM_Z =
  -CHIP_DEPTH * 0.5;


// Grid is slightly recessed
final float STRUT_TOP_Z =
  TOP_Z - 0.8;

final float STRUT_BOT_Z =
  BOTTOM_Z + 0.8;


// Width of grid structures
final float STRUT_WIDTH = 5.0;


// Outer rim width
final float RIM_WIDTH = 8.0;


// ================================================================
// SETUP
// ================================================================

void setup() {

  orientation(LANDSCAPE);

  fullScreen(P3D);

  frameRate(60);

  smooth(4);

  textAlign(CENTER, CENTER);

  rectMode(CORNER);

  ellipseMode(CENTER);

  noStroke();
}


// ================================================================
// MAIN DRAW
// ================================================================

void draw() {

  background(BG_R, BG_G, BG_B);


  // --------------------------------------------------------------
  // LIGHTING
  // --------------------------------------------------------------

  ambientLight(
    90,
    90,
    90
  );

  directionalLight(
    255,
    220,
    180,
    -0.4,
    -0.6,
    -0.8
  );

  pointLight(
    255,
    180,
    100,
    width * 0.5,
    height * 0.35,
    400
  );


  // --------------------------------------------------------------
  // AUTO ROTATION
  // --------------------------------------------------------------

  if (speedValue > 0) {

    globalRotation +=
      speedValue * 0.0008;
  }


  drawHeader();

  drawSquareChip();

  drawControls();
}


// ================================================================
// HEADER
// ================================================================

void drawHeader() {

  hint(DISABLE_DEPTH_TEST);

  camera();

  noLights();


  fill(
    255,
    225,
    45
  );

  textSize(23);

  text(
    "TRUE HOLLOW 3D SQUARE GRID CHIP",
    width * 0.5,
    23
  );


  fill(
    90,
    220,
    255
  );

  textSize(11);

  text(
    "REALISTIC STRUCTURAL GRID • HOLLOW SQUARE CELLS",
    width * 0.5,
    44
  );


  hint(ENABLE_DEPTH_TEST);
}


// ================================================================
// DRAW SINGLE LARGE SQUARE CHIP
// ================================================================

void drawSquareChip() {

  float availableTop =
    60;

  float availableBottom =
    height - 145;

  float availableHeight =
    availableBottom - availableTop;


  float size =
    min(
      width * 0.48,
      availableHeight * 0.78
    );


  float cx =
    width * 0.5;

  float cy =
    availableTop +
    availableHeight * 0.5;


  pushMatrix();

  translate(
    cx,
    cy,
    0
  );


  // --------------------------------------------------------------
  // 3D TILT
  // --------------------------------------------------------------

  rotateX(-0.55);

  rotateZ(globalRotation);


  // --------------------------------------------------------------
  // OUTER SQUARE RIM
  // --------------------------------------------------------------

  drawSquareRim3D(
    size,
    chipColor
  );


  // --------------------------------------------------------------
  // GRID
  // --------------------------------------------------------------

  drawVerticalSquareGrid3D(
    size,
    chipColor
  );

  drawHorizontalSquareGrid3D(
    size,
    chipColor
  );


  popMatrix();


  // --------------------------------------------------------------
  // LABEL
  // --------------------------------------------------------------

  hint(DISABLE_DEPTH_TEST);

  camera();

  noLights();

  fill(235);

  textSize(13);

  text(
    "SQUARE GRID",
    cx,
    cy + size * 0.52
  );

  hint(ENABLE_DEPTH_TEST);
}


// ================================================================
// TRUE HOLLOW SQUARE RIM
// ================================================================

void drawSquareRim3D(
  float size,
  color c
) {

  float half =
    size * 0.5;

  float innerHalf =
    half - RIM_WIDTH;


  if (innerHalf < 2) {
    innerHalf = 2;
  }


  noStroke();


  // ============================================================
  // TOP FACE
  // ============================================================

  fill(c);

  beginShape(QUADS);

  // TOP BAR
  vertex(
    -half,
    -half,
    TOP_Z
  );

  vertex(
    half,
    -half,
    TOP_Z
  );

  vertex(
    innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    TOP_Z
  );

  endShape();


  // BOTTOM BAR

  beginShape(QUADS);

  vertex(
    -half,
    innerHalf,
    TOP_Z
  );

  vertex(
    half,
    innerHalf,
    TOP_Z
  );

  vertex(
    half,
    half,
    TOP_Z
  );

  vertex(
    -half,
    half,
    TOP_Z
  );

  endShape();


  // LEFT BAR

  beginShape(QUADS);

  vertex(
    -half,
    -innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    innerHalf,
    TOP_Z
  );

  vertex(
    -half,
    innerHalf,
    TOP_Z
  );

  endShape();


  // RIGHT BAR

  beginShape(QUADS);

  vertex(
    innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    half,
    -innerHalf,
    TOP_Z
  );

  vertex(
    half,
    innerHalf,
    TOP_Z
  );

  vertex(
    innerHalf,
    innerHalf,
    TOP_Z
  );

  endShape();


  // ============================================================
  // BOTTOM OUTER FRAME
  // ============================================================

  fill(
    red(c) * 0.55,
    green(c) * 0.55,
    blue(c) * 0.55
  );


  // Bottom frame

  beginShape(QUADS);

  vertex(
    -half,
    -half,
    BOTTOM_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    half,
    -half,
    BOTTOM_Z
  );

  endShape();


  beginShape(QUADS);

  vertex(
    -half,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    -half,
    half,
    BOTTOM_Z
  );

  vertex(
    half,
    half,
    BOTTOM_Z
  );

  vertex(
    half,
    innerHalf,
    BOTTOM_Z
  );

  endShape();


  beginShape(QUADS);

  vertex(
    -half,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    -half,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    -innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  endShape();


  beginShape(QUADS);

  vertex(
    innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    half,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    half,
    -innerHalf,
    BOTTOM_Z
  );

  endShape();


  // ============================================================
  // OUTER WALLS
  // ============================================================

  fill(
    red(c) * 0.75,
    green(c) * 0.75,
    blue(c) * 0.75
  );


  // TOP OUTER WALL

  beginShape(QUADS);

  vertex(
    -half,
    -half,
    TOP_Z
  );

  vertex(
    half,
    -half,
    TOP_Z
  );

  vertex(
    half,
    -half,
    BOTTOM_Z
  );

  vertex(
    -half,
    -half,
    BOTTOM_Z
  );

  endShape();


  // RIGHT OUTER WALL

  beginShape(QUADS);

  vertex(
    half,
    -half,
    TOP_Z
  );

  vertex(
    half,
    half,
    TOP_Z
  );

  vertex(
    half,
    half,
    BOTTOM_Z
  );

  vertex(
    half,
    -half,
    BOTTOM_Z
  );

  endShape();


  // BOTTOM OUTER WALL

  beginShape(QUADS);

  vertex(
    half,
    half,
    TOP_Z
  );

  vertex(
    -half,
    half,
    TOP_Z
  );

  vertex(
    -half,
    half,
    BOTTOM_Z
  );

  vertex(
    half,
    half,
    BOTTOM_Z
  );

  endShape();


  // LEFT OUTER WALL

  beginShape(QUADS);

  vertex(
    -half,
    half,
    TOP_Z
  );

  vertex(
    -half,
    -half,
    TOP_Z
  );

  vertex(
    -half,
    -half,
    BOTTOM_Z
  );

  vertex(
    -half,
    half,
    BOTTOM_Z
  );

  endShape();


  // ============================================================
  // INNER WALLS
  // ============================================================

  fill(
    red(c) * 0.65,
    green(c) * 0.65,
    blue(c) * 0.65
  );


  // INNER TOP WALL

  beginShape(QUADS);

  vertex(
    -innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  endShape();


  // INNER RIGHT WALL

  beginShape(QUADS);

  vertex(
    innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    innerHalf,
    innerHalf,
    TOP_Z
  );

  vertex(
    innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  endShape();


  // INNER BOTTOM WALL

  beginShape(QUADS);

  vertex(
    innerHalf,
    innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  vertex(
    innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  endShape();


  // INNER LEFT WALL

  beginShape(QUADS);

  vertex(
    -innerHalf,
    innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    TOP_Z
  );

  vertex(
    -innerHalf,
    -innerHalf,
    BOTTOM_Z
  );

  vertex(
    -innerHalf,
    innerHalf,
    BOTTOM_Z
  );

  endShape();
}


// ================================================================
// 3D STRUT
// ================================================================

void draw3DStrut(
  float x1,
  float y1,
  float x2,
  float y2,
  color c
) {

  float dx =
    x2 - x1;

  float dy =
    y2 - y1;

  float len =
    sqrt(
      dx * dx +
      dy * dy
    );


  if (len < 0.001) {
    return;
  }


  float nx =
    -dy / len *
    STRUT_WIDTH *
    0.5;

  float ny =
    dx / len *
    STRUT_WIDTH *
    0.5;


  float ax =
    x1 + nx;

  float ay =
    y1 + ny;

  float bx =
    x1 - nx;

  float by =
    y1 - ny;

  float cx =
    x2 - nx;

  float cy =
    y2 - ny;

  float dx2 =
    x2 + nx;

  float dy2 =
    y2 + ny;


  noStroke();


  // ============================================================
  // TOP
  // ============================================================

  fill(c);

  beginShape(QUADS);

  vertex(
    ax,
    ay,
    STRUT_TOP_Z
  );

  vertex(
    bx,
    by,
    STRUT_TOP_Z
  );

  vertex(
    cx,
    cy,
    STRUT_TOP_Z
  );

  vertex(
    dx2,
    dy2,
    STRUT_TOP_Z
  );

  endShape();


  // ============================================================
  // BOTTOM
  // ============================================================

  fill(
    red(c) * 0.55,
    green(c) * 0.55,
    blue(c) * 0.55
  );

  beginShape(QUADS);

  vertex(
    ax,
    ay,
    STRUT_BOT_Z
  );

  vertex(
    dx2,
    dy2,
    STRUT_BOT_Z
  );

  vertex(
    cx,
    cy,
    STRUT_BOT_Z
  );

  vertex(
    bx,
    by,
    STRUT_BOT_Z
  );

  endShape();


  // ============================================================
  // SIDE 1
  // ============================================================

  fill(
    red(c) * 0.75,
    green(c) * 0.75,
    blue(c) * 0.75
  );

  beginShape(QUADS);

  vertex(
    ax,
    ay,
    STRUT_TOP_Z
  );

  vertex(
    ax,
    ay,
    STRUT_BOT_Z
  );

  vertex(
    bx,
    by,
    STRUT_BOT_Z
  );

  vertex(
    bx,
    by,
    STRUT_TOP_Z
  );

  endShape();


  // ============================================================
  // SIDE 2
  // ============================================================

  beginShape(QUADS);

  vertex(
    cx,
    cy,
    STRUT_TOP_Z
  );

  vertex(
    cx,
    cy,
    STRUT_BOT_Z
  );

  vertex(
    dx2,
    dy2,
    STRUT_BOT_Z
  );

  vertex(
    dx2,
    dy2,
    STRUT_TOP_Z
  );

  endShape();


  // ============================================================
  // END 1
  // ============================================================

  beginShape(QUADS);

  vertex(
    bx,
    by,
    STRUT_TOP_Z
  );

  vertex(
    bx,
    by,
    STRUT_BOT_Z
  );

  vertex(
    cx,
    cy,
    STRUT_BOT_Z
  );

  vertex(
    cx,
    cy,
    STRUT_TOP_Z
  );

  endShape();


  // ============================================================
  // END 2
  // ============================================================

  beginShape(QUADS);

  vertex(
    dx2,
    dy2,
    STRUT_TOP_Z
  );

  vertex(
    dx2,
    dy2,
    STRUT_BOT_Z
  );

  vertex(
    ax,
    ay,
    STRUT_BOT_Z
  );

  vertex(
    ax,
    ay,
    STRUT_TOP_Z
  );

  endShape();
}


// ================================================================
// VERTICAL SQUARE GRID
// ================================================================

void drawVerticalSquareGrid3D(
  float size,
  color c
) {

  if (verticalGrid <= 0) {
    return;
  }


  float half =
    size * 0.5;

  float innerHalf =
    half - RIM_WIDTH;


  for (
    int i = 1;
    i <= verticalGrid;
    i++
  ) {

    float p =
      map(
        i,
        1,
        verticalGrid + 1,
        -1,
        1
      );


    float x =
      p * innerHalf;


    // ----------------------------------------------------------
    // FULL VERTICAL STRUT
    // ----------------------------------------------------------

    draw3DStrut(
      x,
      -innerHalf,
      x,
      innerHalf,
      c
    );
  }
}


// ================================================================
// HORIZONTAL SQUARE GRID
// ================================================================

void drawHorizontalSquareGrid3D(
  float size,
  color c
) {

  if (horizontalGrid <= 0) {
    return;
  }


  float half =
    size * 0.5;

  float innerHalf =
    half - RIM_WIDTH;


  for (
    int i = 1;
    i <= horizontalGrid;
    i++
  ) {

    float p =
      map(
        i,
        1,
        horizontalGrid + 1,
        -1,
        1
      );


    float y =
      p * innerHalf;


    // ----------------------------------------------------------
    // FULL HORIZONTAL STRUT
    // ----------------------------------------------------------

    draw3DStrut(
      -innerHalf,
      y,
      innerHalf,
      y,
      c
    );
  }
}


// ================================================================
// CONTROL PANEL
// ================================================================

void drawControls() {

  hint(DISABLE_DEPTH_TEST);

  camera();

  noLights();


  float panelTop =
    height - 135;


  noStroke();

  fill(
    18,
    23,
    45
  );

  rect(
    0,
    panelTop,
    width,
    135
  );


  float y =
    height - 76;


  float x1 =
    width * 0.20;

  float x2 =
    width * 0.50;

  float x3 =
    width * 0.80;


  drawSlider(
    x1,
    y,
    verticalGrid,
    0,
    12,
    "VERTICAL GRID"
  );


  drawSlider(
    x2,
    y,
    horizontalGrid,
    0,
    12,
    "HORIZONTAL GRID"
  );


  drawSlider(
    x3,
    y,
    speedValue,
    0,
    100,
    "ROTATION SPEED"
  );


  fill(
    180,
    220,
    255
  );

  textSize(10);


  if (speedValue > 0) {

    text(
      "AUTO ROTATION ON • DRAG SCREEN TO ROTATE",
      width * 0.5,
      height - 17
    );

  } else {

    text(
      "AUTO ROTATION OFF • DRAG SCREEN TO ROTATE",
      width * 0.5,
      height - 17
    );
  }


  hint(ENABLE_DEPTH_TEST);
}


// ================================================================
// SLIDER
// ================================================================

void drawSlider(
  float cx,
  float y,
  int value,
  int minimum,
  int maximum,
  String title
) {

  float sliderWidth =
    min(
      220,
      width * 0.22
    );


  float left =
    cx - sliderWidth * 0.5;

  float right =
    cx + sliderWidth * 0.5;


  fill(255);

  textSize(10);

  text(
    title + "  " + value,
    cx,
    y - 24
  );


  stroke(
    70,
    80,
    110
  );

  strokeWeight(8);

  line(
    left,
    y,
    right,
    y
  );


  float amount =
    map(
      value,
      minimum,
      maximum,
      0,
      1
    );


  amount =
    constrain(
      amount,
      0,
      1
    );


  float knobX =
    lerp(
      left,
      right,
      amount
    );


  stroke(
    255,
    60,
    190
  );

  strokeWeight(8);

  line(
    left,
    y,
    knobX,
    y
  );


  noStroke();

  fill(
    255,
    225,
    40
  );

  ellipse(
    knobX,
    y,
    24,
    24
  );


  fill(
    255,
    70,
    170
  );

  ellipse(
    knobX,
    y,
    10,
    10
  );
}


// ================================================================
// FIND SLIDER
// ================================================================

int findSlider(
  float x,
  float y
) {

  float sliderY =
    height - 76;


  if (
    abs(y - sliderY) > 38
  ) {
    return -1;
  }


  float hit =
    min(
      120,
      width * 0.15
    );


  if (
    abs(
      x - width * 0.20
    ) < hit
  ) {
    return 0;
  }


  if (
    abs(
      x - width * 0.50
    ) < hit
  ) {
    return 1;
  }


  if (
    abs(
      x - width * 0.80
    ) < hit
  ) {
    return 2;
  }


  return -1;
}


// ================================================================
// UPDATE SLIDER
// ================================================================

void updateSlider(
  int id,
  float x
) {

  float cx;


  if (id == 0) {

    cx =
      width * 0.20;

  } else if (id == 1) {

    cx =
      width * 0.50;

  } else {

    cx =
      width * 0.80;
  }


  float sliderWidth =
    min(
      220,
      width * 0.22
    );


  float left =
    cx - sliderWidth * 0.5;

  float right =
    cx + sliderWidth * 0.5;


  float p =
    constrain(
      x,
      left,
      right
    );


  float amount =
    map(
      p,
      left,
      right,
      0,
      1
    );


  if (id == 0) {

    verticalGrid =
      round(
        lerp(
          0,
          12,
          amount
        )
      );

  } else if (id == 1) {

    horizontalGrid =
      round(
        lerp(
          0,
          12,
          amount
        )
      );

  } else {

    speedValue =
      round(
        lerp(
          0,
          100,
          amount
        )
      );
  }
}


// ================================================================
// TOUCH / DRAG
// ================================================================

void mousePressed() {

  selectedSlider =
    findSlider(
      mouseX,
      mouseY
    );


  if (
    selectedSlider >= 0
  ) {

    updateSlider(
      selectedSlider,
      mouseX
    );

    dragging = false;

    return;
  }


  dragging = true;

  previousX =
    mouseX;
}


// ================================================================
// DRAG ROTATION
// ================================================================

void mouseDragged() {

  if (
    selectedSlider >= 0
  ) {

    updateSlider(
      selectedSlider,
      mouseX
    );

    return;
  }


  if (dragging) {

    float dx =
      mouseX - previousX;


    globalRotation +=
      dx * 0.01;


    previousX =
      mouseX;
  }
}


// ================================================================
// RELEASE
// ================================================================

void mouseReleased() {

  selectedSlider = -1;

  dragging = false;
}
