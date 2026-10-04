/*
====================================================================
      RADIAL / WHEEL SNACK CHIP
      APDE / PROCESSING ANDROID
      SIMPLE 2D STABLE VERSION
====================================================================

IMPORTANT
--------------------------------------------------------------------
THIS VERSION IS 2D ONLY.

NO P3D
NO LIGHTING
NO BOX
NO 3D
NO POLYGON INTERSECTION
NO CLIP
NO TOUCH CALLBACKS

12 SHAPES
--------------------------------------------------------------------
0  TRIANGLE
1  SQUARE
2  RECTANGLE
3  CIRCLE
4  ELLIPSE
5  PENTAGON
6  HEXAGON
7  HEPTAGON
8  OCTAGON
9  NONAGON
10 DECAGON
11 DODECAGON

CONTROLS
--------------------------------------------------------------------
VERTICAL GRID    0 - 12
HORIZONTAL GRID  0 - 12
RADIAL RAYS      3 - 24
ROTATION SPEED   0 - 100

DRAG SCREEN
--------------------------------------------------------------------
Drag anywhere outside the sliders to rotate the wheels.

====================================================================
*/


// ================================================================
// SETTINGS
// ================================================================

int BG_R = 8;
int BG_G = 12;
int BG_B = 28;


// ================================================================
// GRID VALUES
// ================================================================

int verticalGrid = 4;
int horizontalGrid = 4;

int radialRays = 10;

int speedValue = 20;


// ================================================================
// ROTATION
// ================================================================

float globalRotation = 0;


// ================================================================
// DRAG
// ================================================================

boolean dragging = false;

float previousX = 0;


// ================================================================
// SLIDER
// ================================================================

int selectedSlider = -1;


// ================================================================
// SHAPE NAMES
// ================================================================

String[] shapeNames = {

  "TRIANGLE",
  "SQUARE",
  "RECTANGLE",
  "CIRCLE",
  "ELLIPSE",
  "PENTAGON",
  "HEXAGON",
  "HEPTAGON",
  "OCTAGON",
  "NONAGON",
  "DECAGON",
  "DODECAGON"
};


// ================================================================
// COLORS
// ================================================================

color[] wheelColors = {

  color(255, 50, 80),
  color(255, 150, 30),
  color(255, 230, 30),
  color(40, 255, 160),
  color(30, 220, 255),
  color(70, 120, 255),
  color(170, 70, 255),
  color(255, 60, 220),
  color(255, 70, 150),
  color(80, 255, 80),
  color(255, 120, 40),
  color(190, 255, 50)
};


// ================================================================
// SETUP
// ================================================================

void setup() {

  orientation(LANDSCAPE);

  fullScreen();

  frameRate(60);

  smooth();

  textAlign(CENTER, CENTER);

  rectMode(CORNER);

  ellipseMode(CENTER);
}


// ================================================================
// MAIN DRAW
// ================================================================

void draw() {

  background(
    BG_R,
    BG_G,
    BG_B
  );


  // --------------------------------------------------------------
  // ROTATION
  // --------------------------------------------------------------

  if (speedValue > 0) {

    globalRotation +=
      speedValue * 0.0008;
  }


  // --------------------------------------------------------------
  // HEADER
  // --------------------------------------------------------------

  drawHeader();


  // --------------------------------------------------------------
  // WHEELS
  // --------------------------------------------------------------

  drawAllWheels();


  // --------------------------------------------------------------
  // CONTROL PANEL
  // --------------------------------------------------------------

  drawControls();
}


// ================================================================
// HEADER
// ================================================================

void drawHeader() {

  fill(255, 230, 50);

  textSize(23);

  text(
    "RADIAL WHEEL SNACK CHIP",
    width / 2,
    24
  );


  fill(100, 220, 255);

  textSize(11);

  text(
    "2D VIBRANT GRID LAB",
    width / 2,
    45
  );
}


// ================================================================
// DRAW ALL 12 WHEELS
// ================================================================

void drawAllWheels() {

  int columns = 6;

  float topArea = 62;

  float bottomArea =
    height - 145;


  float availableHeight =
    bottomArea - topArea;


  float cellWidth =
    width / 6.0;


  float cellHeight =
    availableHeight / 2.0;


  float radius =
    min(
      cellWidth * 0.30,
      cellHeight * 0.34
    );


  for (
    int i = 0;
    i < 12;
    i++
  ) {

    int row =
      i / columns;

    int col =
      i % columns;


    float cx =
      cellWidth *
      (col + 0.5);


    float cy =
      topArea +
      cellHeight *
      (row + 0.50);


    drawWheel(
      cx,
      cy,
      radius,
      i
    );
  }
}


// ================================================================
// DRAW ONE WHEEL
// ================================================================

void drawWheel(
  float cx,
  float cy,
  float radius,
  int shape
) {

  int sides =
    getSides(shape);


  float rx = radius;

  float ry = radius;


  // --------------------------------------------------------------
  // RECTANGLE / ELLIPSE
  // --------------------------------------------------------------

  if (shape == 2) {

    rx = radius;
    ry = radius * 0.65;
  }


  if (shape == 4) {

    rx = radius;
    ry = radius * 0.70;
  }


  // --------------------------------------------------------------
  // MAIN COLOR
  // --------------------------------------------------------------

  color mainColor =
    wheelColors[shape];


  // --------------------------------------------------------------
  // DRAW OUTLINE
  // --------------------------------------------------------------

  pushMatrix();

  translate(
    cx,
    cy
  );

  rotate(
    globalRotation +
    shape * 0.03
  );


  noFill();

  stroke(mainColor);

  strokeWeight(3);


  drawShapeOutline(
    shape,
    rx,
    ry,
    sides
  );


  // --------------------------------------------------------------
  // GRID COLOR
  // --------------------------------------------------------------

  stroke(
    80,
    240,
    255
  );

  strokeWeight(1.5);


  // --------------------------------------------------------------
  // VERTICAL GRID
  // --------------------------------------------------------------

  drawVerticalLines(
    rx,
    ry,
    shape
  );


  // --------------------------------------------------------------
  // HORIZONTAL GRID
  // --------------------------------------------------------------

  stroke(
    255,
    80,
    220
  );

  drawHorizontalLines(
    rx,
    ry,
    shape
  );


  // --------------------------------------------------------------
  // RADIAL RAYS
  // --------------------------------------------------------------

  stroke(
    255,
    235,
    70
  );

  strokeWeight(1.8);


  drawRadialLines(
    rx,
    ry,
    shape
  );


  // --------------------------------------------------------------
  // CENTER HOLE
  // --------------------------------------------------------------

  drawHole(
    radius
  );


  popMatrix();


  // --------------------------------------------------------------
  // LABEL
  // --------------------------------------------------------------

  fill(230);

  textSize(
    max(
      8,
      min(
        12,
        radius * 0.13
      )
    )
  );


  text(
    shapeNames[shape],
    cx,
    cy + radius + 17
  );
}


// ================================================================
// SIDES
// ================================================================

int getSides(int shape) {

  if (shape == 0)
    return 3;

  if (shape == 1)
    return 4;

  if (shape == 2)
    return 4;

  if (shape == 3)
    return 40;

  if (shape == 4)
    return 40;

  if (shape == 5)
    return 5;

  if (shape == 6)
    return 6;

  if (shape == 7)
    return 7;

  if (shape == 8)
    return 8;

  if (shape == 9)
    return 9;

  if (shape == 10)
    return 10;

  return 12;
}


// ================================================================
// OUTER SHAPE
// ================================================================

void drawShapeOutline(
  int shape,
  float rx,
  float ry,
  int sides
) {


  // --------------------------------------------------------------
  // CIRCLE
  // --------------------------------------------------------------

  if (shape == 3) {

    ellipse(
      0,
      0,
      rx * 2,
      ry * 2
    );

    return;
  }


  // --------------------------------------------------------------
  // ELLIPSE
  // --------------------------------------------------------------

  if (shape == 4) {

    ellipse(
      0,
      0,
      rx * 2,
      ry * 2
    );

    return;
  }


  // --------------------------------------------------------------
  // RECTANGLE
  // --------------------------------------------------------------

  if (shape == 2) {

    rectMode(CENTER);

    rect(
      0,
      0,
      rx * 2,
      ry * 2
    );

    return;
  }


  // --------------------------------------------------------------
  // POLYGON
  // --------------------------------------------------------------

  beginShape();


  for (
    int i = 0;
    i < sides;
    i++
  ) {

    float a =
      -HALF_PI +
      TWO_PI *
      i /
      sides;


    float x =
      cos(a) *
      rx;


    float y =
      sin(a) *
      ry;


    vertex(
      x,
      y
    );
  }


  endShape(CLOSE);
}


// ================================================================
// VERTICAL GRID
// ================================================================

void drawVerticalLines(
  float rx,
  float ry,
  int shape
) {

  if (
    verticalGrid <= 0
  ) {

    return;
  }


  float hole =
    rx * 0.23;


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
        -0.78,
        0.78
      );


    float x =
      rx * p;


    float limit =
      verticalLimit(
        x,
        rx,
        ry,
        shape
      );


    if (
      limit <=
      hole
    ) {

      continue;
    }


    // TOP
    line(
      x,
      -limit,
      x,
      -hole
    );


    // BOTTOM
    line(
      x,
      hole,
      x,
      limit
    );
  }
}


// ================================================================
// HORIZONTAL GRID
// ================================================================

void drawHorizontalLines(
  float rx,
  float ry,
  int shape
) {

  if (
    horizontalGrid <= 0
  ) {

    return;
  }


  float hole =
    ry * 0.23;


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
        -0.78,
        0.78
      );


    float y =
      ry * p;


    float limit =
      horizontalLimit(
        y,
        rx,
        ry,
        shape
      );


    if (
      limit <=
      hole
    ) {

      continue;
    }


    // LEFT
    line(
      -limit,
      y,
      -hole,
      y
    );


    // RIGHT
    line(
      hole,
      y,
      limit,
      y
    );
  }
}


// ================================================================
// VERTICAL LIMIT
// ================================================================

float verticalLimit(
  float x,
  float rx,
  float ry,
  int shape
) {


  // --------------------------------------------------------------
  // CIRCLE
  // --------------------------------------------------------------

  if (shape == 3) {

    float q =
      1.0 -
      (x * x) /
      (rx * rx);


    if (q <= 0)
      return 0;


    return ry *
      sqrt(q);
  }


  // --------------------------------------------------------------
  // ELLIPSE
  // --------------------------------------------------------------

  if (shape == 4) {

    float q =
      1.0 -
      (x * x) /
      (rx * rx);


    if (q <= 0)
      return 0;


    return ry *
      sqrt(q);
  }


  // --------------------------------------------------------------
  // RECTANGLE
  // --------------------------------------------------------------

  if (shape == 2) {

    return ry;
  }


  // --------------------------------------------------------------
  // POLYGON
  //
  // Simple approximation.
  // The grid remains safely inside the shape.
  // --------------------------------------------------------------

  float normalized =
    abs(x / rx);


  if (normalized > 0.80)
    return ry * 0.20;


  return ry *
    (0.92 -
     normalized * 0.30);
}


// ================================================================
// HORIZONTAL LIMIT
// ================================================================

float horizontalLimit(
  float y,
  float rx,
  float ry,
  int shape
) {


  // --------------------------------------------------------------
  // CIRCLE
  // --------------------------------------------------------------

  if (shape == 3) {

    float q =
      1.0 -
      (y * y) /
      (ry * ry);


    if (q <= 0)
      return 0;


    return rx *
      sqrt(q);
  }


  // --------------------------------------------------------------
  // ELLIPSE
  // --------------------------------------------------------------

  if (shape == 4) {

    float q =
      1.0 -
      (y * y) /
      (ry * ry);


    if (q <= 0)
      return 0;


    return rx *
      sqrt(q);
  }


  // --------------------------------------------------------------
  // RECTANGLE
  // --------------------------------------------------------------

  if (shape == 2) {

    return rx;
  }


  // --------------------------------------------------------------
  // POLYGON
  // --------------------------------------------------------------

  float normalized =
    abs(y / ry);


  if (normalized > 0.80)
    return rx * 0.20;


  return rx *
    (0.92 -
     normalized * 0.30);
}


// ================================================================
// RADIAL LINES
// ================================================================

void drawRadialLines(
  float rx,
  float ry,
  int shape
) {

  if (
    radialRays <= 0
  ) {

    return;
  }


  float hole =
    min(rx, ry) *
    0.25;


  for (
    int i = 0;
    i < radialRays;
    i++
  ) {

    float angle =
      TWO_PI *
      i /
      radialRays;


    float endRadius =
      min(
        rx,
        ry
      ) * 0.90;


    // ----------------------------------------------------------
    // CIRCLE
    // ----------------------------------------------------------

    if (shape == 3) {

      endRadius =
        rx * 0.90;
    }


    // ----------------------------------------------------------
    // ELLIPSE
    // ----------------------------------------------------------

    if (shape == 4) {

      float c =
        cos(angle);

      float s =
        sin(angle);


      float d =
        sqrt(
          (c * c) /
          (rx * rx)
          +
          (s * s) /
          (ry * ry)
        );


      if (d > 0.0001) {

        endRadius =
          1.0 / d;

        endRadius *= 0.90;
      }
    }


    // ----------------------------------------------------------
    // RECTANGLE
    // ----------------------------------------------------------

    if (shape == 2) {

      float c =
        abs(cos(angle));

      float s =
        abs(sin(angle));


      float a =
        rx /
        max(
          c,
          0.001
        );


      float b =
        ry /
        max(
          s,
          0.001
        );


      endRadius =
        min(a, b) *
        0.90;
    }


    // ----------------------------------------------------------
    // DRAW
    // ----------------------------------------------------------

    if (
      endRadius >
      hole + 5
    ) {

      line(

        cos(angle) *
        hole,

        sin(angle) *
        hole,

        cos(angle) *
        endRadius,

        sin(angle) *
        endRadius
      );
    }
  }
}


// ================================================================
// CENTER HOLE
// ================================================================

void drawHole(
  float radius
) {

  float hole =
    radius * 0.23;


  // --------------------------------------------------------------
  // OUTER GOLD RING
  // --------------------------------------------------------------

  stroke(
    255,
    230,
    50
  );

  strokeWeight(5);

  noFill();


  ellipse(
    0,
    0,
    hole * 2 + 8,
    hole * 2 + 8
  );


  // --------------------------------------------------------------
  // DARK CENTER
  // --------------------------------------------------------------

  noStroke();

  fill(
    BG_R,
    BG_G,
    BG_B
  );


  ellipse(
    0,
    0,
    hole * 2,
    hole * 2
  );


  // --------------------------------------------------------------
  // SMALL CENTER RING
  // --------------------------------------------------------------

  stroke(
    255,
    255,
    255
  );

  strokeWeight(2);

  noFill();


  ellipse(
    0,
    0,
    hole * 1.55,
    hole * 1.55
  );
}


// ================================================================
// CONTROL PANEL
// ================================================================

void drawControls() {

  float panelTop =
    height - 135;


  // --------------------------------------------------------------
  // PANEL
  // --------------------------------------------------------------

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
    width * 0.13;

  float x2 =
    width * 0.38;

  float x3 =
    width * 0.63;

  float x4 =
    width * 0.88;


  // --------------------------------------------------------------
  // SLIDER 1
  // --------------------------------------------------------------

  drawSlider(
    x1,
    y,
    verticalGrid,
    0,
    12,
    "VERTICAL GRID"
  );


  // --------------------------------------------------------------
  // SLIDER 2
  // --------------------------------------------------------------

  drawSlider(
    x2,
    y,
    horizontalGrid,
    0,
    12,
    "HORIZONTAL GRID"
  );


  // --------------------------------------------------------------
  // SLIDER 3
  // --------------------------------------------------------------

  drawSlider(
    x3,
    y,
    radialRays,
    3,
    24,
    "RADIAL RAYS"
  );


  // --------------------------------------------------------------
  // SLIDER 4
  // --------------------------------------------------------------

  drawSlider(
    x4,
    y,
    speedValue,
    0,
    100,
    "ROTATION SPEED"
  );


  // --------------------------------------------------------------
  // BOTTOM TEXT
  // --------------------------------------------------------------

  fill(
    180,
    220,
    255
  );

  textSize(10);


  if (speedValue > 0) {

    text(
      "AUTO ROTATION ON  •  DRAG SCREEN TO ROTATE",
      width / 2,
      height - 17
    );

  } else {

    text(
      "AUTO ROTATION OFF  •  DRAG SCREEN TO ROTATE",
      width / 2,
      height - 17
    );
  }
}


// ================================================================
// DRAW SLIDER
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
      180,
      width * 0.18
    );


  float left =
    cx -
    sliderWidth / 2;


  float right =
    cx +
    sliderWidth / 2;


  // --------------------------------------------------------------
  // TITLE
  // --------------------------------------------------------------

  fill(255);

  textSize(10);


  text(
    title +
    "  " +
    value,
    cx,
    y - 24
  );


  // --------------------------------------------------------------
  // TRACK
  // --------------------------------------------------------------

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


  // --------------------------------------------------------------
  // POSITION
  // --------------------------------------------------------------

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


  // --------------------------------------------------------------
  // ACTIVE LINE
  // --------------------------------------------------------------

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


  // --------------------------------------------------------------
  // KNOB
  // --------------------------------------------------------------

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
// MOUSE / TOUCH PRESSED
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
// MOUSE / TOUCH DRAGGED
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
      mouseX -
      previousX;


    globalRotation +=
      dx * 0.01;


    previousX =
      mouseX;
  }
}


// ================================================================
// MOUSE / TOUCH RELEASED
// ================================================================

void mouseReleased() {

  selectedSlider = -1;

  dragging = false;
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
    abs(
      y - sliderY
    ) > 38
  ) {

    return -1;
  }


  float x1 =
    width * 0.13;

  float x2 =
    width * 0.38;

  float x3 =
    width * 0.63;

  float x4 =
    width * 0.88;


  float hit =
    min(
      100,
      width * 0.12
    );


  if (
    abs(x - x1) < hit
  ) {

    return 0;
  }


  if (
    abs(x - x2) < hit
  ) {

    return 1;
  }


  if (
    abs(x - x3) < hit
  ) {

    return 2;
  }


  if (
    abs(x - x4) < hit
  ) {

    return 3;
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


  // --------------------------------------------------------------
  // SELECT CENTER
  // --------------------------------------------------------------

  if (id == 0) {

    cx =
      width * 0.13;

  } else if (id == 1) {

    cx =
      width * 0.38;

  } else if (id == 2) {

    cx =
      width * 0.63;

  } else {

    cx =
      width * 0.88;
  }


  float sliderWidth =
    min(
      180,
      width * 0.18
    );


  float left =
    cx -
    sliderWidth / 2;


  float right =
    cx +
    sliderWidth / 2;


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


  // --------------------------------------------------------------
  // VERTICAL GRID
  // --------------------------------------------------------------

  if (id == 0) {

    verticalGrid =
      round(
        lerp(
          0,
          12,
          amount
        )
      );

    return;
  }


  // --------------------------------------------------------------
  // HORIZONTAL GRID
  // --------------------------------------------------------------

  if (id == 1) {

    horizontalGrid =
      round(
        lerp(
          0,
          12,
          amount
        )
      );

    return;
  }


  // --------------------------------------------------------------
  // RADIAL RAYS
  // --------------------------------------------------------------

  if (id == 2) {

    radialRays =
      round(
        lerp(
          3,
          24,
          amount
        )
      );

    return;
  }


  // --------------------------------------------------------------
  // SPEED
  // --------------------------------------------------------------

  if (id == 3) {

    speedValue =
      round(
        lerp(
          0,
          100,
          amount
        )
      );

    return;
  }
}
