/*
====================================================================
              RADIAL / WHEEL SNACK CHIP 3D
              APDE / PROCESSING ANDROID
              TRUE HOLLOW P3D VERSION
====================================================================

FEATURES
--------------------------------------------------------------------
• TRUE HOLLOW P3D EXTRUDED CHIP
• Outer rims, inner hubs, and struts are drawn as 3D structures
• Empty space between the grids is fully transparent/hollow
• 12 SHAPES
• AUTO ROTATION & DRAG ROTATION
• EXACT GRID CLIPPING

====================================================================
*/

// ================================================================
// GLOBAL SETTINGS
// ================================================================

int BG_R = 7;
int BG_G = 11;
int BG_B = 25;

// ================================================================
// GRID VALUES
// ================================================================

int verticalGrid   = 4;
int horizontalGrid = 4;
int radialRays = 10;
int speedValue = 20;

// ================================================================
// ROTATION & DRAG
// ================================================================

float globalRotation = 0.0;
boolean dragging = false;
float previousX = 0;
int selectedSlider = -1;

// ================================================================
// SHAPE NAMES & COLORS
// ================================================================

String[] shapeNames = {
  "TRIANGLE", "SQUARE", "RECTANGLE", "CIRCLE",
  "ELLIPSE", "PENTAGON", "HEXAGON", "HEPTAGON",
  "OCTAGON", "NONAGON", "DECAGON", "DODECAGON"
};

color[] chipColors = {
  color(255, 145, 28), color(255, 157, 30), color(255, 170, 28),
  color(255, 151, 22), color(255, 166, 28), color(255, 143, 20),
  color(255, 161, 24), color(255, 149, 18), color(255, 170, 32),
  color(255, 155, 22), color(255, 164, 25), color(255, 150, 18)
};

// ================================================================
// 3D GEOMETRY SETTINGS
// ================================================================

final float CHIP_DEPTH = 12.0;         // Thickness of the snack
final float TOP_Z = CHIP_DEPTH * 0.5;
final float BOTTOM_Z = -CHIP_DEPTH * 0.5;

// We recess the internal grid slightly to give the rim a realistic pop
final float STRUT_TOP_Z = TOP_Z - 0.8; 
final float STRUT_BOT_Z = BOTTOM_Z + 0.8;

final float STRUT_WIDTH = 5.0; // Width of the grid lines/spokes
final float RIM_WIDTH = 8.0;   // Width of the outer crust

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
  ambientLight(90, 90, 90);
  directionalLight(255, 220, 180, -0.4, -0.6, -0.8);
  pointLight(255, 180, 100, width * 0.5, height * 0.35, 400);

  // --------------------------------------------------------------
  // AUTO ROTATION
  // --------------------------------------------------------------
  if (speedValue > 0) {
    globalRotation += speedValue * 0.0008;
  }

  drawHeader();
  drawAllWheels();
  drawControls();
}

// ================================================================
// HEADER
// ================================================================

void drawHeader() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  fill(255, 225, 45);
  textSize(23);
  text("TRUE HOLLOW 3D SNACK CHIP", width * 0.5, 23);

  fill(90, 220, 255);
  textSize(11);
  text("REALISTIC STRUCTURAL GRID • PROCEDURAL MESH", width * 0.5, 44);

  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// DRAW ALL 12 WHEELS
// ================================================================

void drawAllWheels() {
  int columns = 6;
  float topArea = 60;
  float bottomArea = height - 145;
  float availableHeight = bottomArea - topArea;
  
  float cellWidth = width / 6.0;
  float cellHeight = availableHeight / 2.0;
  float radius = min(cellWidth * 0.30, cellHeight * 0.34);

  for (int i = 0; i < 12; i++) {
    int row = i / columns;
    int col = i % columns;

    float cx = cellWidth * (col + 0.5);
    float cy = topArea + cellHeight * (row + 0.50);

    drawWheel(cx, cy, radius, i);
  }
}

// ================================================================
// DRAW ONE 3D WHEEL
// ================================================================

void drawWheel(float cx, float cy, float radius, int shape) {
  float rx = radius;
  float ry = radius;

  // Custom Proportions
  if (shape == 2) { rx = radius; ry = radius * 0.65; } // RECTANGLE
  if (shape == 4) { rx = radius; ry = radius * 0.70; } // ELLIPSE

  int sides = getSides(shape);
  color baseColor = chipColors[shape];

  pushMatrix();
  translate(cx, cy, 0);

  // Tilt to reveal the hollow 3D nature
  rotateX(-0.55); 
  rotateZ(globalRotation + shape * 0.03);

  // Draw the cohesive 3D structure
  drawOuterRim3D(rx, ry, shape, sides, baseColor);
  drawCenterHub3D(rx, ry, baseColor);
  
  drawVerticalGrid3D(rx, ry, shape, sides, baseColor);
  drawHorizontalGrid3D(rx, ry, shape, sides, baseColor);
  drawRadialGrid3D(rx, ry, shape, sides, baseColor);

  popMatrix();

  // Label
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  fill(235);
  textSize(max(8, min(12, radius * 0.13)));
  text(shapeNames[shape], cx, cy + radius + 22);
  hint(ENABLE_DEPTH_TEST);
}

// ================================================================
// GEOMETRY HELPERS
// ================================================================

int getSides(int shape) {
  if (shape == 0) return 3;
  if (shape == 1 || shape == 2) return 4;
  if (shape == 3 || shape == 4) return 40; // Circle/Ellipse approximation
  if (shape == 5) return 5;
  if (shape == 6) return 6;
  if (shape == 7) return 7;
  if (shape == 8) return 8;
  if (shape == 9) return 9;
  if (shape == 10) return 10;
  return 12;
}

float getVertexAngle(int i, int sides) {
  return -HALF_PI + TWO_PI * i / sides;
}

// ================================================================
// HOLLOW 3D MESH GENERATION
// ================================================================

void drawOuterRim3D(float rx, float ry, int shape, int sides, color c) {
  for (int i = 0; i < sides; i++) {
    float a1 = getVertexAngle(i, sides);
    float a2 = getVertexAngle((i + 1) % sides, sides);

    float ox1 = cos(a1) * rx; float oy1 = sin(a1) * ry;
    float ox2 = cos(a2) * rx; float oy2 = sin(a2) * ry;

    float irx = max(1, rx - RIM_WIDTH);
    float iry = max(1, ry - RIM_WIDTH);

    float ix1 = cos(a1) * irx; float iy1 = sin(a1) * iry;
    float ix2 = cos(a2) * irx; float iy2 = sin(a2) * iry;

    noStroke();

    // TOP FACE
    fill(c);
    beginShape(QUADS);
    vertex(ox1, oy1, TOP_Z); vertex(ox2, oy2, TOP_Z);
    vertex(ix2, iy2, TOP_Z); vertex(ix1, iy1, TOP_Z);
    endShape();

    // BOTTOM FACE
    fill(red(c)*0.55, green(c)*0.55, blue(c)*0.55);
    beginShape(QUADS);
    vertex(ox1, oy1, BOTTOM_Z); vertex(ix1, iy1, BOTTOM_Z);
    vertex(ix2, iy2, BOTTOM_Z); vertex(ox2, oy2, BOTTOM_Z);
    endShape();

    // OUTER WALL
    fill(red(c)*0.75, green(c)*0.75, blue(c)*0.75);
    beginShape(QUADS);
    vertex(ox1, oy1, TOP_Z); vertex(ox1, oy1, BOTTOM_Z);
    vertex(ox2, oy2, BOTTOM_Z); vertex(ox2, oy2, TOP_Z);
    endShape();

    // INNER WALL
    fill(red(c)*0.65, green(c)*0.65, blue(c)*0.65);
    beginShape(QUADS);
    vertex(ix1, iy1, TOP_Z); vertex(ix2, iy2, TOP_Z);
    vertex(ix2, iy2, BOTTOM_Z); vertex(ix1, iy1, BOTTOM_Z);
    endShape();
  }
}

void drawCenterHub3D(float rx, float ry, color c) {
  if (verticalGrid <= 0 && horizontalGrid <= 0 && radialRays <= 0) return;

  float holeOuter = min(rx, ry) * 0.25;
  float holeInner = holeOuter - (RIM_WIDTH * 0.8);
  if (holeInner < 1) return;

  int segs = 24;
  noStroke();
  
  for (int i = 0; i < segs; i++) {
    float a1 = TWO_PI * i / segs;
    float a2 = TWO_PI * (i + 1) / segs;

    float ox1 = cos(a1) * holeOuter; float oy1 = sin(a1) * holeOuter;
    float ox2 = cos(a2) * holeOuter; float oy2 = sin(a2) * holeOuter;

    float ix1 = cos(a1) * holeInner; float iy1 = sin(a1) * holeInner;
    float ix2 = cos(a2) * holeInner; float iy2 = sin(a2) * holeInner;

    // TOP FACE
    fill(c);
    beginShape(QUADS);
    vertex(ox1, oy1, TOP_Z); vertex(ox2, oy2, TOP_Z);
    vertex(ix2, iy2, TOP_Z); vertex(ix1, iy1, TOP_Z);
    endShape();

    // BOTTOM FACE
    fill(red(c)*0.55, green(c)*0.55, blue(c)*0.55);
    beginShape(QUADS);
    vertex(ox1, oy1, BOTTOM_Z); vertex(ix1, iy1, BOTTOM_Z);
    vertex(ix2, iy2, BOTTOM_Z); vertex(ox2, oy2, BOTTOM_Z);
    endShape();

    // OUTER WALL
    fill(red(c)*0.75, green(c)*0.75, blue(c)*0.75);
    beginShape(QUADS);
    vertex(ox1, oy1, TOP_Z); vertex(ox1, oy1, BOTTOM_Z);
    vertex(ox2, oy2, BOTTOM_Z); vertex(ox2, oy2, TOP_Z);
    endShape();

    // INNER WALL
    fill(red(c)*0.65, green(c)*0.65, blue(c)*0.65);
    beginShape(QUADS);
    vertex(ix1, iy1, TOP_Z); vertex(ix2, iy2, TOP_Z);
    vertex(ix2, iy2, BOTTOM_Z); vertex(ix1, iy1, BOTTOM_Z);
    endShape();
  }
}

// ================================================================
// DRAWING 3D STRUTS (GRID LINES)
// ================================================================

void draw3DStrut(float x1, float y1, float x2, float y2, color c) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float len = sqrt(dx * dx + dy * dy);
  
  if (len < 0.001) return;

  // Calculate perpendicular normal for width
  float nx = -dy / len * (STRUT_WIDTH * 0.5);
  float ny = dx / len * (STRUT_WIDTH * 0.5);

  float cx1 = x1 + nx; float cy1 = y1 + ny;
  float cx2 = x1 - nx; float cy2 = y1 - ny;
  float cx3 = x2 - nx; float cy3 = y2 - ny;
  float cx4 = x2 + nx; float cy4 = y2 + ny;

  noStroke();

  // TOP
  fill(c);
  beginShape(QUADS);
  vertex(cx1, cy1, STRUT_TOP_Z); vertex(cx2, cy2, STRUT_TOP_Z);
  vertex(cx3, cy3, STRUT_TOP_Z); vertex(cx4, cy4, STRUT_TOP_Z);
  endShape();

  // BOTTOM
  fill(red(c)*0.55, green(c)*0.55, blue(c)*0.55);
  beginShape(QUADS);
  vertex(cx1, cy1, STRUT_BOT_Z); vertex(cx4, cy4, STRUT_BOT_Z);
  vertex(cx3, cy3, STRUT_BOT_Z); vertex(cx2, cy2, STRUT_BOT_Z);
  endShape();

  // SIDES
  fill(red(c)*0.75, green(c)*0.75, blue(c)*0.75);
  beginShape(QUADS);
  // Left Side
  vertex(cx1, cy1, STRUT_TOP_Z); vertex(cx1, cy1, STRUT_BOT_Z);
  vertex(cx2, cy2, STRUT_BOT_Z); vertex(cx2, cy2, STRUT_TOP_Z);
  // End Cap (often hidden)
  vertex(cx2, cy2, STRUT_TOP_Z); vertex(cx2, cy2, STRUT_BOT_Z);
  vertex(cx3, cy3, STRUT_BOT_Z); vertex(cx3, cy3, STRUT_TOP_Z);
  // Right Side
  vertex(cx3, cy3, STRUT_TOP_Z); vertex(cx3, cy3, STRUT_BOT_Z);
  vertex(cx4, cy4, STRUT_BOT_Z); vertex(cx4, cy4, STRUT_TOP_Z);
  // Start Cap (often hidden)
  vertex(cx4, cy4, STRUT_TOP_Z); vertex(cx4, cy4, STRUT_BOT_Z);
  vertex(cx1, cy1, STRUT_BOT_Z); vertex(cx1, cy1, STRUT_TOP_Z);
  endShape();
}

// ================================================================
// 3D GRIDS 
// ================================================================

void drawVerticalGrid3D(float rx, float ry, int shape, int sides, color c) {
  if (verticalGrid <= 0) return;
  float hole = min(rx, ry) * 0.25;

  for (int i = 1; i <= verticalGrid; i++) {
    float p = map(i, 1, verticalGrid + 1, -0.78, 0.78);
    float x = rx * p;
    float[] range = verticalIntersection(x, rx, ry, shape, sides);
    if (range == null) continue;

    float topY = range[0];
    float bottomY = range[1];

    if (abs(x) < hole) {
      if (topY < -hole) draw3DStrut(x, topY, x, -hole, c);
      if (bottomY > hole) draw3DStrut(x, hole, x, bottomY, c);
    } else {
      draw3DStrut(x, topY, x, bottomY, c);
    }
  }
}

void drawHorizontalGrid3D(float rx, float ry, int shape, int sides, color c) {
  if (horizontalGrid <= 0) return;
  float hole = min(rx, ry) * 0.25;

  for (int i = 1; i <= horizontalGrid; i++) {
    float p = map(i, 1, horizontalGrid + 1, -0.78, 0.78);
    float y = ry * p;
    float[] range = horizontalIntersection(y, rx, ry, shape, sides);
    if (range == null) continue;

    float leftX = range[0];
    float rightX = range[1];

    if (abs(y) < hole) {
      if (leftX < -hole) draw3DStrut(leftX, y, -hole, y, c);
      if (rightX > hole) draw3DStrut(hole, y, rightX, y, c);
    } else {
      draw3DStrut(leftX, y, rightX, y, c);
    }
  }
}

void drawRadialGrid3D(float rx, float ry, int shape, int sides, color c) {
  if (radialRays <= 0) return;
  float hole = min(rx, ry) * 0.25;

  for (int i = 0; i < radialRays; i++) {
    float angle = TWO_PI * i / radialRays;
    float outer = rayBoundaryRadius(angle, rx, ry, shape, sides);

    if (outer > hole + 1) {
      float x1 = cos(angle) * hole; 
      float y1 = sin(angle) * hole;
      float x2 = cos(angle) * outer; 
      float y2 = sin(angle) * outer;
      draw3DStrut(x1, y1, x2, y2, c);
    }
  }
}

// ================================================================
// EXACT INTERSECTION MATH (Preserved from Original)
// ================================================================

float[] verticalIntersection(float x, float rx, float ry, int shape, int sides) {
  if (shape == 3 || shape == 4) {
    float q = 1.0 - (x * x) / (rx * rx);
    if (q <= 0) return null;
    float y = ry * sqrt(q);
    return new float[] { -y, y };
  }
  if (shape == 2) return new float[] { -ry, ry };

  float minY = 999999;
  float maxY = -999999;
  boolean found = false;

  for (int i = 0; i < sides; i++) {
    float a1 = getVertexAngle(i, sides);
    float a2 = getVertexAngle((i + 1) % sides, sides);
    float x1 = cos(a1) * rx; float y1 = sin(a1) * ry;
    float x2 = cos(a2) * rx; float y2 = sin(a2) * ry;

    float dx = x2 - x1;
    if (abs(dx) < 0.00001) continue;

    float t = (x - x1) / dx;
    if (t >= 0 && t <= 1) {
      float y = y1 + (y2 - y1) * t;
      minY = min(minY, y);
      maxY = max(maxY, y);
      found = true;
    }
  }
  if (!found) return null;
  return new float[] { minY, maxY };
}

float[] horizontalIntersection(float y, float rx, float ry, int shape, int sides) {
  if (shape == 3 || shape == 4) {
    float q = 1.0 - (y * y) / (ry * ry);
    if (q <= 0) return null;
    float x = rx * sqrt(q);
    return new float[] { -x, x };
  }
  if (shape == 2) return new float[] { -rx, rx };

  float minX = 999999;
  float maxX = -999999;
  boolean found = false;

  for (int i = 0; i < sides; i++) {
    float a1 = getVertexAngle(i, sides);
    float a2 = getVertexAngle((i + 1) % sides, sides);
    float x1 = cos(a1) * rx; float y1 = sin(a1) * ry;
    float x2 = cos(a2) * rx; float y2 = sin(a2) * ry;

    float dy = y2 - y1;
    if (abs(dy) < 0.00001) continue;

    float t = (y - y1) / dy;
    if (t >= 0 && t <= 1) {
      float x = x1 + (x2 - x1) * t;
      minX = min(minX, x);
      maxX = max(maxX, x);
      found = true;
    }
  }
  if (!found) return null;
  return new float[] { minX, maxX };
}

float rayBoundaryRadius(float angle, float rx, float ry, int shape, int sides) {
  float c = cos(angle);
  float s = sin(angle);
  if (shape == 3) return rx;
  if (shape == 4) {
    float d = sqrt((c * c) / (rx * rx) + (s * s) / (ry * ry));
    if (d <= 0.000001) return 0;
    return 1.0 / d;
  }
  if (shape == 2) {
    float tx = 999999; float ty = 999999;
    if (abs(c) > 0.000001) tx = rx / abs(c);
    if (abs(s) > 0.000001) ty = ry / abs(s);
    return min(tx, ty);
  }

  float best = 999999;
  for (int i = 0; i < sides; i++) {
    float a1 = getVertexAngle(i, sides);
    float a2 = getVertexAngle((i + 1) % sides, sides);
    float x1 = cos(a1) * rx; float y1 = sin(a1) * ry;
    float x2 = cos(a2) * rx; float y2 = sin(a2) * ry;

    float ex = x2 - x1; float ey = y2 - y1;
    float denominator = c * ey - s * ex;
    if (abs(denominator) < 0.000001) continue;

    float t = (x1 * ey - y1 * ex) / denominator;
    float u = (x1 * s - y1 * c) / denominator;
    if (t >= 0 && u >= 0 && u <= 1) best = min(best, t);
  }

  if (best == 999999) {
    float sector = TWO_PI / sides;
    float apothem = rx * cos(sector * 0.5);
    return apothem / max(0.001, cos(abs(angle + HALF_PI - round((angle + HALF_PI) / sector) * sector)));
  }
  return best;
}

// ================================================================
// CONTROL PANEL
// ================================================================

void drawControls() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();

  float panelTop = height - 135;
  noStroke();
  fill(18, 23, 45);
  rect(0, panelTop, width, 135);

  float y = height - 76;
  float x1 = width * 0.13; float x2 = width * 0.38;
  float x3 = width * 0.63; float x4 = width * 0.88;

  drawSlider(x1, y, verticalGrid, 0, 12, "VERTICAL GRID");
  drawSlider(x2, y, horizontalGrid, 0, 12, "HORIZONTAL GRID");
  drawSlider(x3, y, radialRays, 0, 24, "RADIAL RAYS");
  drawSlider(x4, y, speedValue, 0, 100, "ROTATION SPEED");

  fill(180, 220, 255);
  textSize(10);
  if (speedValue > 0) text("AUTO ROTATION ON  •  DRAG SCREEN TO ROTATE", width * 0.5, height - 17);
  else text("AUTO ROTATION OFF  •  DRAG SCREEN TO ROTATE", width * 0.5, height - 17);

  hint(ENABLE_DEPTH_TEST);
}

void drawSlider(float cx, float y, int value, int minimum, int maximum, String title) {
  float sliderWidth = min(180, width * 0.18);
  float left = cx - sliderWidth * 0.5;
  float right = cx + sliderWidth * 0.5;

  fill(255);
  textSize(10);
  text(title + "  " + value, cx, y - 24);

  stroke(70, 80, 110);
  strokeWeight(8);
  line(left, y, right, y);

  float amount = map(value, minimum, maximum, 0, 1);
  amount = constrain(amount, 0, 1);
  float knobX = lerp(left, right, amount);

  stroke(255, 60, 190);
  strokeWeight(8);
  line(left, y, knobX, y);

  noStroke();
  fill(255, 225, 40);
  ellipse(knobX, y, 24, 24);
  fill(255, 70, 170);
  ellipse(knobX, y, 10, 10);
}

// ================================================================
// TOUCH / DRAG CONTROLS
// ================================================================

void mousePressed() {
  selectedSlider = findSlider(mouseX, mouseY);
  if (selectedSlider >= 0) {
    updateSlider(selectedSlider, mouseX);
    dragging = false;
    return;
  }
  dragging = true;
  previousX = mouseX;
}

void mouseDragged() {
  if (selectedSlider >= 0) {
    updateSlider(selectedSlider, mouseX);
    return;
  }
  if (dragging) {
    float dx = mouseX - previousX;
    globalRotation += dx * 0.01;
    previousX = mouseX;
  }
}

void mouseReleased() {
  selectedSlider = -1;
  dragging = false;
}

int findSlider(float x, float y) {
  float sliderY = height - 76;
  if (abs(y - sliderY) > 38) return -1;

  float hit = min(100, width * 0.12);
  if (abs(x - width * 0.13) < hit) return 0;
  if (abs(x - width * 0.38) < hit) return 1;
  if (abs(x - width * 0.63) < hit) return 2;
  if (abs(x - width * 0.88) < hit) return 3;
  return -1;
}

void updateSlider(int id, float x) {
  float cx;
  if (id == 0) cx = width * 0.13;
  else if (id == 1) cx = width * 0.38;
  else if (id == 2) cx = width * 0.63;
  else cx = width * 0.88;

  float sliderWidth = min(180, width * 0.18);
  float left = cx - sliderWidth * 0.5;
  float right = cx + sliderWidth * 0.5;
  
  float p = constrain(x, left, right);
  float amount = map(p, left, right, 0, 1);

  if (id == 0) verticalGrid = round(lerp(0, 12, amount));
  else if (id == 1) horizontalGrid = round(lerp(0, 12, amount));
  else if (id == 2) radialRays = round(lerp(0, 24, amount));
  else if (id == 3) speedValue = round(lerp(0, 100, amount));
}
