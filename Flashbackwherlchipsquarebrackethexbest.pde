/*
====================================================================
     RADIAL / WHEEL TYPE SNACK CHIPS
     TRUE HOLLOW CENTER VERSION
     APDE / PROCESSING ANDROID / JAVA / P3D

     DESIGN
     ---------------------------------------------------------------
              OUTER POLYGON
           __________________
          / \  |  |  |  /   \
         /   \ |  |  | /     \
        |----- \  |  / -------|
        |       (     )       |
        |-------/  |  \-------|
         \     /   |   \     /
          \___/____|____\___/

             ↑
        TRUE HOLLOW CENTER

     The center is EMPTY.
     No filled circle is drawn inside it.

     SHAPES
     ---------------------------------------------------------------
     0   TRIANGLE
     1   SQUARE
     2   RECTANGLE
     3   CIRCLE
     4   ELLIPSE
     5   PENTAGON
     6   HEXAGON
     7   HEPTAGON
     8   OCTAGON
     9   NONAGON
     10  DECAGON
     11  CUSTOM POLYGON

     FEATURES
     ---------------------------------------------------------------
     • Large square-style banner composition
     • 12 wheel-type chips
     • Left-to-right array
     • Two rows
     • True hollow circular center
     • 3D hollow center ring
     • Radial rays
     • Open spaces between rays
     • Rays stop before hollow center
     • Correct polygon boundary
     • Golden fried snack appearance
     • 3D thickness
     • Labels
     • Touch rotation
====================================================================
*/


// ================================================================
// BANNER
// ================================================================

float bannerScale = 0.78;


// ================================================================
// CHIP
// ================================================================

float chipRadius = 115;

float chipDepth = 14;


// ================================================================
// RADIAL DESIGN
// ================================================================

int rayCount = 10;

float hubRadius = 28;

float hubRingWidth = 11;

float rayThickness = 13;

float outerInset = 8;


// ================================================================
// ROTATION
// ================================================================

float rotationX = -0.25;

float rotationY = 0.15;

float rotationZ = 0.0;


// ================================================================
// TOUCH
// ================================================================

float oldTouchX;

float oldTouchY;

boolean rotating = false;


// ================================================================
// SETTINGS
// ================================================================

void settings() {

  fullScreen(P3D);
}


// ================================================================
// SETUP
// ================================================================

void setup() {

  orientation(LANDSCAPE);

  smooth(8);

  textAlign(
    CENTER,
    CENTER
  );

  sphereDetail(24);
}


// ================================================================
// DRAW
// ================================================================

void draw() {

  background(
    245,
    239,
    220
  );


  // --------------------------------------------------------------
  // LIGHTING
  // --------------------------------------------------------------

  ambientLight(
    125,
    110,
    90
  );


  directionalLight(
    255,
    235,
    195,
    -0.5,
    -0.8,
    -1.0
  );


  directionalLight(
    150,
    105,
    55,
    0.7,
    0.4,
    -0.5
  );


  // --------------------------------------------------------------
  // HEADER
  // --------------------------------------------------------------

  drawBannerHeader();


  // --------------------------------------------------------------
  // CHIP ARRAY
  // --------------------------------------------------------------

  pushMatrix();


  translate(
    width * 0.50,
    height * 0.49,
    0
  );


  scale(
    bannerScale
  );


  rotateX(
    rotationX
  );

  rotateY(
    rotationY
  );

  rotateZ(
    rotationZ
  );


  drawAllWheelChips();


  popMatrix();


  // --------------------------------------------------------------
  // FOOTER
  // --------------------------------------------------------------

  drawFooter();
}


// ================================================================
// HEADER
// ================================================================

void drawBannerHeader() {

  hint(DISABLE_DEPTH_TEST);


  fill(
    30,
    25,
    20
  );


  textSize(31);


  text(
    "RADIAL WHEEL TYPE SNACK CHIPS",
    width / 2,
    38
  );


  fill(
    105,
    75,
    40
  );


  textSize(15);


  text(
    "HOLLOW CENTER + RADIAL RAYS EXTENDING TOWARD THE EDGE",
    width / 2,
    68
  );


  hint(ENABLE_DEPTH_TEST);
}


// ================================================================
// FOOTER
// ================================================================

void drawFooter() {

  hint(DISABLE_DEPTH_TEST);


  fill(
    65,
    50,
    35
  );


  textSize(14);


  text(
    "TRIANGLE   SQUARE   RECTANGLE   CIRCLE   ELLIPSE   " +
    "PENTAGON   HEXAGON   HEPTAGON",
    width / 2,
    height - 38
  );


  text(
    "OCTAGON   NONAGON   DECAGON   CUSTOM POLYGON",
    width / 2,
    height - 18
  );


  hint(ENABLE_DEPTH_TEST);
}


// ================================================================
// ALL WHEEL CHIPS
// ================================================================

void drawAllWheelChips() {

  int columns = 6;

  int rows = 2;


  float spacingX = 230;

  float spacingY = 275;


  for (
    int i = 0;
    i < 12;
    i++
  ) {


    int row =
      i / columns;


    int col =
      i % columns;


    float x =
      (col - 2.5) *
      spacingX;


    float y =
      (row - 0.5) *
      spacingY;


    pushMatrix();


    translate(
      x,
      y,
      0
    );


    // Very small natural rotation

    rotateZ(
      sin(
        i * 1.73
      ) * 0.035
    );


    drawWheelChip(
      i
    );


    popMatrix();
  }
}


// ================================================================
// WHEEL CHIP
// ================================================================

void drawWheelChip(
  int shape
) {

  int sides =
    getShapeSides(
      shape
    );


  float rx =
    chipRadius;


  float ry =
    chipRadius;


  // --------------------------------------------------------------
  // RECTANGLE
  // --------------------------------------------------------------

  if (
    shape == 2
  ) {

    ry =
      chipRadius * 0.70;
  }


  // --------------------------------------------------------------
  // ELLIPSE
  // --------------------------------------------------------------

  if (
    shape == 4
  ) {

    ry =
      chipRadius * 0.70;
  }


  // --------------------------------------------------------------
  // OUTER BOUNDARY
  // --------------------------------------------------------------

  drawOuterBoundary(
    rx,
    ry,
    chipDepth,
    shape,
    sides
  );


  // --------------------------------------------------------------
  // RADIAL RAYS
  // --------------------------------------------------------------

  drawRadialRays(
    rx,
    ry,
    chipDepth,
    shape,
    sides
  );


  // --------------------------------------------------------------
  // TRUE HOLLOW CENTER RING
  // --------------------------------------------------------------

  drawHollowCenterRing(
    chipDepth
  );


  // --------------------------------------------------------------
  // LABEL
  // --------------------------------------------------------------

  drawChipLabel(
    shape
  );
}


// ================================================================
// SHAPE SIDES
// ================================================================

int getShapeSides(
  int shape
) {

  if (shape == 0)
    return 3;

  if (shape == 1)
    return 4;

  if (shape == 2)
    return 4;

  if (shape == 3)
    return 64;

  if (shape == 4)
    return 64;

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
// OUTER BOUNDARY
// ================================================================

void drawOuterBoundary(
  float rx,
  float ry,
  float depth,
  int shape,
  int sides
) {

  if (
    shape == 2
  ) {

    drawRectangleBoundary(
      rx,
      ry,
      depth
    );

    return;
  }


  if (
    shape == 3
  ) {

    drawEllipseBoundary(
      rx,
      rx,
      depth,
      64
    );

    return;
  }


  if (
    shape == 4
  ) {

    drawEllipseBoundary(
      rx,
      ry,
      depth,
      64
    );

    return;
  }


  drawPolygonBoundary(
    rx,
    ry,
    depth,
    sides
  );
}


// ================================================================
// POLYGON BOUNDARY
// ================================================================

void drawPolygonBoundary(
  float rx,
  float ry,
  float depth,
  int sides
) {

  float frame = 11;

  float startAngle =
    -HALF_PI;


  for (
    int i = 0;
    i < sides;
    i++
  ) {

    float a1 =
      startAngle +
      TWO_PI * i / sides;


    float a2 =
      startAngle +
      TWO_PI * (i + 1) / sides;


    float x1 =
      cos(a1) * rx;

    float y1 =
      sin(a1) * ry;


    float x2 =
      cos(a2) * rx;

    float y2 =
      sin(a2) * ry;


    float cx =
      (x1 + x2) * 0.5;

    float cy =
      (y1 + y2) * 0.5;


    float len =
      dist(
        x1,
        y1,
        x2,
        y2
      );


    float angle =
      atan2(
        y2 - y1,
        x2 - x1
      );


    pushMatrix();


    translate(
      cx,
      cy,
      0
    );


    rotateZ(
      angle
    );


    drawGoldenBar(
      len,
      frame,
      depth
    );


    popMatrix();
  }
}


// ================================================================
// RECTANGLE BOUNDARY
// ================================================================

void drawRectangleBoundary(
  float rx,
  float ry,
  float depth
) {

  float frame = 11;


  // TOP

  pushMatrix();

  translate(
    0,
    -ry + frame * 0.5,
    0
  );


  drawGoldenBar(
    rx * 2,
    frame,
    depth
  );


  popMatrix();


  // BOTTOM

  pushMatrix();

  translate(
    0,
    ry - frame * 0.5,
    0
  );


  drawGoldenBar(
    rx * 2,
    frame,
    depth
  );


  popMatrix();


  // LEFT

  pushMatrix();

  translate(
    -rx + frame * 0.5,
    0,
    0
  );


  drawGoldenBar(
    frame,
    ry * 2 - frame * 2,
    depth
  );


  popMatrix();


  // RIGHT

  pushMatrix();

  translate(
    rx - frame * 0.5,
    0,
    0
  );


  drawGoldenBar(
    frame,
    ry * 2 - frame * 2,
    depth
  );


  popMatrix();
}


// ================================================================
// ELLIPSE BOUNDARY
// ================================================================

void drawEllipseBoundary(
  float rx,
  float ry,
  float depth,
  int segments
) {

  float frame = 11;


  for (
    int i = 0;
    i < segments;
    i++
  ) {

    float a1 =
      TWO_PI * i / segments;


    float a2 =
      TWO_PI * (i + 1) / segments;


    float x1 =
      cos(a1) * rx;

    float y1 =
      sin(a1) * ry;


    float x2 =
      cos(a2) * rx;

    float y2 =
      sin(a2) * ry;


    float cx =
      (x1 + x2) * 0.5;

    float cy =
      (y1 + y2) * 0.5;


    float len =
      dist(
        x1,
        y1,
        x2,
        y2
      );


    float angle =
      atan2(
        y2 - y1,
        x2 - x1
      );


    pushMatrix();


    translate(
      cx,
      cy,
      0
    );


    rotateZ(
      angle
    );


    drawGoldenBar(
      len,
      frame,
      depth
    );


    popMatrix();
  }
}


// ================================================================
// RADIAL RAYS
// ================================================================

void drawRadialRays(
  float rx,
  float ry,
  float depth,
  int shape,
  int sides
) {

  /*
      IMPORTANT:

      The ray begins OUTSIDE the hollow hole.

      Therefore the center remains completely empty.
  */


  float startRadius =
    hubRadius +
    hubRingWidth +
    4;


  for (
    int i = 0;
    i < rayCount;
    i++
  ) {

    float angle =
      TWO_PI * i /
      rayCount;


    // ------------------------------------------------------------
    // RAY START
    // ------------------------------------------------------------

    float startX =
      cos(angle) *
      startRadius;


    float startY =
      sin(angle) *
      startRadius;


    // ------------------------------------------------------------
    // RAY END
    // ------------------------------------------------------------

    float endRadius =
      getBoundaryRadius(
        angle,
        rx,
        ry,
        shape,
        sides
      );


    endRadius -=
      outerInset;


    float endX =
      cos(angle) *
      endRadius;


    float endY =
      sin(angle) *
      endRadius;


    // ------------------------------------------------------------
    // BAR CENTER
    // ------------------------------------------------------------

    float cx =
      (startX + endX) *
      0.5;


    float cy =
      (startY + endY) *
      0.5;


    float len =
      dist(
        startX,
        startY,
        endX,
        endY
      );


    pushMatrix();


    translate(
      cx,
      cy,
      1
    );


    rotateZ(
      angle
    );


    drawGoldenBar(
      len,
      rayThickness,
      depth
    );


    popMatrix();
  }
}


// ================================================================
// BOUNDARY RADIUS
// ================================================================

float getBoundaryRadius(
  float angle,
  float rx,
  float ry,
  int shape,
  int sides
) {

  // CIRCLE

  if (
    shape == 3
  ) {

    return rx;
  }


  // ELLIPSE

  if (
    shape == 4
  ) {

    float c =
      cos(angle);

    float s =
      sin(angle);


    float denominator =
      sqrt(
        (c * c) /
        (rx * rx)
        +
        (s * s) /
        (ry * ry)
      );


    return 1.0 /
      denominator;
  }


  // RECTANGLE

  if (
    shape == 2
  ) {

    float c =
      abs(
        cos(angle)
      );


    float s =
      abs(
        sin(angle)
      );


    float dx =
      rx /
      max(
        c,
        0.0001
      );


    float dy =
      ry /
      max(
        s,
        0.0001
      );


    return min(
      dx,
      dy
    );
  }


  // POLYGON

  return polygonBoundaryRadius(
    angle,
    rx,
    sides
  );
}


// ================================================================
// POLYGON BOUNDARY RADIUS
// ================================================================

float polygonBoundaryRadius(
  float rayAngle,
  float radius,
  int sides
) {

  float startAngle =
    -HALF_PI;


  float sector =
    TWO_PI /
    sides;


  float local =
    rayAngle -
    startAngle;


  local =
    local -
    floor(
      local / sector
    ) *
    sector;


  float sideAngle =
    local -
    sector * 0.5;


  float apothem =
    radius *
    cos(
      PI / sides
    );


  float denominator =
    cos(
      sideAngle
    );


  if (
    abs(
      denominator
    ) < 0.0001
  ) {

    denominator =
      0.0001;
  }


  return apothem /
    denominator;
}


// ================================================================
// TRUE HOLLOW CENTER RING
// ================================================================
//
// THIS IS THE IMPORTANT CORRECTION.
//
// There is NO filled circle here.
//
// The inside radius remains empty.
//
// The function creates:
//   • front annular surface
//   • back annular surface
//   • outer cylindrical wall
//   • inner cylindrical wall
//
// Therefore the center is a REAL 3D HOLE.
// ================================================================

void drawHollowCenterRing(
  float depth
) {

  int segments = 64;


  float innerRadius =
    hubRadius;


  float outerRadius =
    hubRadius +
    hubRingWidth;


  float frontZ =
    depth * 0.55;


  float backZ =
    -depth * 0.55;


  // --------------------------------------------------------------
  // FRONT ANNULUS
  // --------------------------------------------------------------

  beginShape(QUADS);


  for (
    int i = 0;
    i < segments;
    i++
  ) {

    float a1 =
      TWO_PI *
      i /
      segments;


    float a2 =
      TWO_PI *
      (i + 1) /
      segments;


    float ox1 =
      cos(a1) *
      outerRadius;


    float oy1 =
      sin(a1) *
      outerRadius;


    float ox2 =
      cos(a2) *
      outerRadius;


    float oy2 =
      sin(a2) *
      outerRadius;


    float ix1 =
      cos(a1) *
      innerRadius;


    float iy1 =
      sin(a1) *
      innerRadius;


    float ix2 =
      cos(a2) *
      innerRadius;


    float iy2 =
      sin(a2) *
      innerRadius;


    fill(
      238,
      166,
      62
    );


    stroke(
      165,
      90,
      22
    );


    vertex(
      ox1,
      oy1,
      frontZ
    );


    vertex(
      ox2,
      oy2,
      frontZ
    );


    vertex(
      ix2,
      iy2,
      frontZ
    );


    vertex(
      ix1,
      iy1,
      frontZ
    );
  }


  endShape();


  // --------------------------------------------------------------
  // BACK ANNULUS
  // --------------------------------------------------------------

  beginShape(QUADS);


  for (
    int i = 0;
    i < segments;
    i++
  ) {

    float a1 =
      TWO_PI *
      i /
      segments;


    float a2 =
      TWO_PI *
      (i + 1) /
      segments;


    float ox1 =
      cos(a1) *
      outerRadius;


    float oy1 =
      sin(a1) *
      outerRadius;


    float ox2 =
      cos(a2) *
      outerRadius;


    float oy2 =
      sin(a2) *
      outerRadius;


    float ix1 =
      cos(a1) *
      innerRadius;


    float iy1 =
      sin(a1) *
      innerRadius;


    float ix2 =
      cos(a2) *
      innerRadius;


    float iy2 =
      sin(a2) *
      innerRadius;


    fill(
      180,
      92,
      25
    );


    stroke(
      145,
      70,
      18
    );


    vertex(
      ox2,
      oy2,
      backZ
    );


    vertex(
      ox1,
      oy1,
      backZ
    );


    vertex(
      ix1,
      iy1,
      backZ
    );


    vertex(
      ix2,
      iy2,
      backZ
    );
  }


  endShape();


  // --------------------------------------------------------------
  // OUTER WALL
  // --------------------------------------------------------------

  beginShape(QUADS);


  for (
    int i = 0;
    i < segments;
    i++
  ) {

    float a1 =
      TWO_PI *
      i /
      segments;


    float a2 =
      TWO_PI *
      (i + 1) /
      segments;


    float ox1 =
      cos(a1) *
      outerRadius;


    float oy1 =
      sin(a1) *
      outerRadius;


    float ox2 =
      cos(a2) *
      outerRadius;


    float oy2 =
      sin(a2) *
      outerRadius;


    fill(
      195,
      105,
      28
    );


    stroke(
      150,
      75,
      18
    );


    vertex(
      ox1,
      oy1,
      backZ
    );


    vertex(
      ox2,
      oy2,
      backZ
    );


    vertex(
      ox2,
      oy2,
      frontZ
    );


    vertex(
      ox1,
      oy1,
      frontZ
    );
  }


  endShape();


  // --------------------------------------------------------------
  // INNER WALL
  // --------------------------------------------------------------
  //
  // This is the wall of the actual hole.
  //
  // Looking through the center reveals the background.
  // --------------------------------------------------------------

  beginShape(QUADS);


  for (
    int i = 0;
    i < segments;
    i++
  ) {

    float a1 =
      TWO_PI *
      i /
      segments;


    float a2 =
      TWO_PI *
      (i + 1) /
      segments;


    float ix1 =
      cos(a1) *
      innerRadius;


    float iy1 =
      sin(a1) *
      innerRadius;


    float ix2 =
      cos(a2) *
      innerRadius;


    float iy2 =
      sin(a2) *
      innerRadius;


    fill(
      145,
      70,
      20
    );


    stroke(
      125,
      60,
      16
    );


    vertex(
      ix2,
      iy2,
      backZ
    );


    vertex(
      ix1,
      iy1,
      backZ
    );


    vertex(
      ix1,
      iy1,
      frontZ
    );


    vertex(
      ix2,
      iy2,
      frontZ
    );
  }


  endShape();
}


// ================================================================
// GOLDEN 3D BAR
// ================================================================

void drawGoldenBar(
  float w,
  float h,
  float d
) {

  pushMatrix();


  // MAIN BODY

  fill(
    218,
    143,
    42
  );


  stroke(
    158,
    86,
    22
  );


  strokeWeight(
    1.4
  );


  box(
    max(
      2,
      w
    ),
    max(
      2,
      h
    ),
    max(
      2,
      d
    )
  );


  // FRONT CRISP HIGHLIGHT

  pushMatrix();


  translate(
    0,
    0,
    d * 0.54
  );


  noStroke();


  fill(
    247,
    181,
    76
  );


  box(
    max(
      1,
      w * 0.82
    ),
    max(
      1,
      h * 0.72
    ),
    2
  );


  popMatrix();


  // DARK BACK

  pushMatrix();


  translate(
    0,
    0,
    -d * 0.54
  );


  noStroke();


  fill(
    166,
    87,
    24
  );


  box(
    max(
      1,
      w * 0.82
    ),
    max(
      1,
      h * 0.72
    ),
    2
  );


  popMatrix();


  popMatrix();
}


// ================================================================
// CHIP LABEL
// ================================================================

void drawChipLabel(
  int shape
) {

  hint(
    DISABLE_DEPTH_TEST
  );


  pushMatrix();


  translate(
    0,
    chipRadius + 30,
    30
  );


  fill(
    45,
    35,
    25
  );


  textSize(
    15
  );


  text(
    getShapeName(
      shape
    ),
    0,
    0
  );


  popMatrix();


  hint(
    ENABLE_DEPTH_TEST
  );
}


// ================================================================
// SHAPE NAME
// ================================================================

String getShapeName(
  int shape
) {

  if (shape == 0)
    return "TRIANGLE";


  if (shape == 1)
    return "SQUARE";


  if (shape == 2)
    return "RECTANGLE";


  if (shape == 3)
    return "CIRCLE";


  if (shape == 4)
    return "ELLIPSE";


  if (shape == 5)
    return "PENTAGON";


  if (shape == 6)
    return "HEXAGON";


  if (shape == 7)
    return "HEPTAGON";


  if (shape == 8)
    return "OCTAGON";


  if (shape == 9)
    return "NONAGON";


  if (shape == 10)
    return "DECAGON";


  return "CUSTOM POLYGON";
}


// ================================================================
// TOUCH STARTED
// ================================================================

void touchStarted() {

  oldTouchX =
    mouseX;


  oldTouchY =
    mouseY;


  rotating =
    true;
}


// ================================================================
// TOUCH MOVED
// ================================================================

void touchMoved() {

  if (
    rotating
  ) {

    float dx =
      mouseX -
      oldTouchX;


    float dy =
      mouseY -
      oldTouchY;


    rotationY +=
      dx * 0.008;


    rotationX +=
      dy * 0.008;


    rotationX =
      constrain(
        rotationX,
        -1.35,
        1.35
      );


    oldTouchX =
      mouseX;


    oldTouchY =
      mouseY;
  }
}


// ================================================================
// TOUCH ENDED
// ================================================================

void touchEnded() {

  rotating =
    false;
}
