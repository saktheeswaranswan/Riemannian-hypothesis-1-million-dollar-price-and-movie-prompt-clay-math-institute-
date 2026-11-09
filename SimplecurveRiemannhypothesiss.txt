// ==========================================
// APDE Graphing Calculator 
// 1. Black Graph Background & Red Laser Traces
// 2. Yellow Glowing Laser Curve (Connect All toggle)
// 3. Pinch to Zoom graph in/out (1500+ point scale)
// 4. Smoothly scroll table up and down (Viewport Culling)
// 5. Tap table rows to jump the cube to that point
// 6. Bottom 4-Button Toggle Bar (Fast Auto / Slow Plot / Step / Connect)
// 7. Projection lines and "x=, y=" text for active point
// 8. NEW: SLOW PLOT Mode dynamically animates projection lines from axes
// ==========================================

import java.util.ArrayList;

int currentFunction = 0;
String[] options = {
  "Straight Line (y = x)",
  "Parabola (y = x²)",
  "Cubic Polynomial (y = x³ - 2x)",
  "Sine Curve (y = sin(x))",
  "Cosine Curve (y = cos(x))",
  "Asymptote (y = 1/x)"
};

// Layout Variables
float topBarH, bottomBarH;
float gX, gY, gW, gH; 
float pX, pY, pW, pH; 
float cx, cy;

// Zoom Variables
float baseUnit, unit;
float zoomScale = 1.0;
float pinchStartDist = 0;
float zoomStartScale = 1.0;

// Slider Variables
float sliderX, sliderY, sliderW, sliderH;
float sliderVal = 0.5; 
float currentStep;
boolean isDraggingSlider = false;

// Table Scroll Variable
float tableOffsetY = 0;

// Animation & Visual Variables
float animLimitX;
int playMode = 0; // 0 = FAST AUTO, 1 = SLOW PLOT, 2 = MANUAL STEP
boolean isPlaying = true;
boolean showCurve = false; // Toggles the Yellow Laser Curve
float animSpeed = 0.04;
float slowTimer = 0; // Controls the projection line animation speed

void setup() {
  fullScreen();
  updateLayout();
  animLimitX = -(gW / 2.0) / unit; 
}

void draw() {
  updateLayout();
  
  // ----------------------------------------
  // Handle Multi-Touch Pinch to Zoom
  // ----------------------------------------
  if (touches != null && touches.length >= 2) {
    float d = dist(touches[0].x, touches[0].y, touches[1].x, touches[1].y);
    if (pinchStartDist == 0) {
      pinchStartDist = d;
      zoomStartScale = zoomScale;
    } else {
      zoomScale = constrain(zoomStartScale * (d / pinchStartDist), 0.05, 10.0);
    }
  } else {
    pinchStartDist = 0; 
  }
  
  // Calculate mapping step based on slider
  currentStep = map(sliderVal, 0, 1, 0.05, 2.0);
  
  // ----------------------------------------
  // Advanced Animation Handling
  // ----------------------------------------
  if (isPlaying) {
    if (playMode == 0) {
      // FAST AUTO: Smooth continuous rendering
      float maxMathX = (gW / 2.0) / unit;
      animLimitX += (animSpeed / zoomScale); 
      if (animLimitX > maxMathX) {
        animLimitX = maxMathX;
        isPlaying = false; 
      }
    } else if (playMode == 1) {
      // SLOW PLOT: Point-by-point with line drawing animations
      slowTimer += 0.06; // Animation speed of the projection lines
      
      if (slowTimer >= 3.0) { // When animation for current point is done, jump to next point
        slowTimer = 0;
        float minMathX = -(gW / 2.0) / unit;
        float maxMathX = (gW / 2.0) / unit;
        
        // Calculate next exact mathematical point
        int currentIndex = round((animLimitX - minMathX) / currentStep);
        float nextX = minMathX + (currentIndex + 1) * currentStep;
        
        if (nextX <= maxMathX + 0.001) {
          animLimitX = nextX;
        } else {
          animLimitX = maxMathX;
          isPlaying = false;
        }
      }
    }
  }
  
  // Black background for the Graph
  background(0); 
  
  drawGridAndAxes();
  plotFunction();
  
  drawPanel();  
  drawTopBar(); 
  drawBottomBar(); 
}

// ----------------------------------------------------
// 1. LAYOUT & RESPONSIVENESS
// ----------------------------------------------------
void updateLayout() {
  topBarH = height * 0.1;
  bottomBarH = height * 0.1;
  float availH = height - topBarH - bottomBarH; 
  
  if (width > height) { 
    // LANDSCAPE MODE
    gX = 0; gY = topBarH;
    gW = width * 0.65; gH = availH;
    
    pX = gW; pY = topBarH;
    pW = width - gW; pH = availH;
  } else { 
    // PORTRAIT MODE
    gX = 0; gY = topBarH;
    gW = width; gH = availH * 0.55;
    
    pX = 0; pY = gY + gH;
    pW = width; pH = availH - gH;
  }
  
  cx = gX + gW / 2.0;
  cy = gY + gH / 2.0;
  
  baseUnit = min(gW, gH) / 6.0; 
  unit = baseUnit * zoomScale; 
  
  sliderW = pW * 0.8;
  sliderH = pH * (width > height ? 0.05 : 0.08);
  sliderX = pX + (pW - sliderW) / 2.0;
  sliderY = pY + pH * 0.12;
}

// ----------------------------------------------------
// 2. GRAPH DRAWING & ANIMATION
// ----------------------------------------------------
void drawGridAndAxes() {
  stroke(40); // Dark gray grid on black background
  strokeWeight(2);
  
  float startXGrid = gX + ((cx - gX) % unit);
  for (float x = startXGrid; x < gX + gW; x += unit) {
    line(x, gY, x, gY + gH);
  }
  
  float startYGrid = gY + ((cy - gY) % unit);
  for (float y = startYGrid; y < gY + gH; y += unit) {
    line(gX, y, gX + gW, y);
  }
  
  stroke(200); // White axes
  strokeWeight(3);
  line(gX, cy, gX + gW, cy); 
  line(cx, gY, cx, gY + gH); 
  
  fill(180); // Light gray instruction text
  textAlign(LEFT, TOP);
  textSize(min(gW, gH) * 0.035);
  text("Pinch to Zoom\nTap graph to replay\nTap table to jump", gX + 10, gY + 10);
}

void drawCurvePath(float minMathX, float maxMathX) {
  boolean isDrawing = false;
  float previousY = 0;
  
  for (float x = minMathX; x <= maxMathX + 0.001; x += currentStep) {
    if (x <= animLimitX) {
      float y = evaluateFunction(x);
      
      if (Float.isNaN(y) || Float.isInfinite(y) || y > 500 || y < -500) {
        if (isDrawing) { endShape(); isDrawing = false; }
      } else {
        if (currentFunction == 5 && (previousY * y < 0) && abs(y - previousY) > 5) {
          if (isDrawing) { endShape(); isDrawing = false; }
        }
        
        float screenX = cx + x * unit;
        float screenY = cy - y * unit;
        
        if (!isDrawing) {
          beginShape();
          isDrawing = true;
        }
        vertex(screenX, screenY);
        previousY = y;
      }
    }
  }
  if (isDrawing) endShape();
}

void drawCoordinateText(float lSX, float lSY, float lMX, float lMY) {
  fill(0, 255, 255);
  textSize(min(gW, gH) * 0.04);
  textAlign(LEFT, BOTTOM);
  
  float textPosX = lSX + 15;
  float textPosY = lSY - 15;
  
  // Keep text safely on screen if the point goes near the edges
  if (textPosX > gX + gW - 120) textPosX = lSX - 120; 
  if (textPosY < gY + 40) textPosY = lSY + 40; 
  
  String coordinateText = "x = " + nf(lMX, 1, 2) + "\ny = " + nf(lMY, 1, 2);
  text(coordinateText, textPosX, textPosY);
}

void plotFunction() {
  float minMathX = -(gW / 2.0) / unit;
  float maxMathX = (gW / 2.0) / unit;
  
  boolean hasLeadingPoint = false;
  float leadingScreenX = 0;
  float leadingScreenY = 0;
  float leadingMathX = 0;
  float leadingMathY = 0;
  
  // 1. Draw Glowing Yellow Laser Curve (if connected)
  if (showCurve) {
    // Outer Glow
    stroke(255, 255, 0, 80); 
    strokeWeight(12);
    noFill();
    drawCurvePath(minMathX, maxMathX);
    
    // Inner Solid Core
    stroke(255, 255, 150); 
    strokeWeight(4);
    noFill();
    drawCurvePath(minMathX, maxMathX);
  }
  
  // 2. Draw Red Laser Point Traces
  noStroke();
  fill(255, 0, 0); // Vibrant red dots
  for (float x = minMathX; x <= maxMathX + 0.001; x += currentStep) {
    if (x <= animLimitX) {
      float y = evaluateFunction(x);
      if (!Float.isNaN(y) && !Float.isInfinite(y) && y <= 500 && y >= -500) {
        float screenX = cx + x * unit;
        float screenY = cy - y * unit;
        ellipse(screenX, screenY, 6, 6); // Trace dot
        
        leadingScreenX = screenX;
        leadingScreenY = screenY;
        leadingMathX = x;
        leadingMathY = y;
        hasLeadingPoint = true;
      }
    }
  }
  
  // 3. Draw Red Points exactly at X-Axis Intercepts 
  ArrayList<Float> roots = getRoots(minMathX, maxMathX);
  fill(255, 0, 0); 
  stroke(255);       
  strokeWeight(2);
  for (Float r : roots) {
    if (r <= animLimitX) {
      float screenX = cx + r * unit;
      float screenY = cy; 
      ellipse(screenX, screenY, 14, 14);
    }
  }
  
  // 4. Draw Projection Lines and Cube for the Active Leading Point
  if (hasLeadingPoint && leadingScreenX >= gX && leadingScreenX <= gX + gW && leadingScreenY >= gY && leadingScreenY <= gY + gH) {
    
    stroke(0, 255, 255, 180); 
    strokeWeight(2);
    
    if (playMode == 1 && isPlaying) {
      // ANIMATE LINES FROM AXES TO THE POINT (Slow Plot Mode)
      float pXLine = constrain(slowTimer, 0, 1);
      float pYLine = constrain(slowTimer - 1.0, 0, 1);
      
      if (pXLine > 0) {
        float currentY = lerp(cy, leadingScreenY, pXLine);
        line(leadingScreenX, cy, leadingScreenX, currentY); // Line grows from X-axis to point
      }
      if (pYLine > 0) {
        float currentX = lerp(cx, leadingScreenX, pYLine);
        line(cx, leadingScreenY, currentX, leadingScreenY); // Line grows from Y-axis to point
      }
      
      if (slowTimer >= 2.0) {
        drawCoordinateText(leadingScreenX, leadingScreenY, leadingMathX, leadingMathY);
      }
    } else {
      // DRAW LINES INSTANTLY (Fast Auto & Manual Mode)
      line(leadingScreenX, cy, leadingScreenX, leadingScreenY); 
      line(cx, leadingScreenY, leadingScreenX, leadingScreenY); 
      drawCoordinateText(leadingScreenX, leadingScreenY, leadingMathX, leadingMathY);
    }
    
    // Draw the moving red cube
    rectMode(CENTER);
    fill(255, 50, 50); 
    stroke(255);
    strokeWeight(2);
    rect(leadingScreenX, leadingScreenY, 16, 16); 
    rectMode(CORNER);
  }
}

ArrayList<Float> getRoots(float minX, float maxX) {
  ArrayList<Float> roots = new ArrayList<Float>();
  
  if (currentFunction == 0 || currentFunction == 1) { 
    if (0 >= minX && 0 <= maxX) roots.add(0.0f);
  } 
  else if (currentFunction == 2) { 
    if (0 >= minX && 0 <= maxX) roots.add(0.0f);
    if (sqrt(2) >= minX && sqrt(2) <= maxX) roots.add(sqrt(2));
    if (-sqrt(2) >= minX && -sqrt(2) <= maxX) roots.add(-sqrt(2));
  } 
  else if (currentFunction == 3) { 
    int minK = ceil(minX / PI);
    int maxK = floor(maxX / PI);
    for (int k = minK; k <= maxK; k++) roots.add(k * PI);
  } 
  else if (currentFunction == 4) { 
    int minK = ceil((minX - HALF_PI) / PI);
    int maxK = floor((maxX - HALF_PI) / PI);
    for (int k = minK; k <= maxK; k++) roots.add(HALF_PI + k * PI);
  }
  return roots;
}

float evaluateFunction(float x) {
  if (currentFunction == 0) return x;
  else if (currentFunction == 1) return x * x;
  else if (currentFunction == 2) return (x * x * x) - (2 * x);
  else if (currentFunction == 3) return sin(x);
  else if (currentFunction == 4) return cos(x);
  else if (currentFunction == 5) {
    if (abs(x) > 0.0001) return 1.0 / x;
    else return Float.NaN;
  }
  return 0;
}

// ----------------------------------------------------
// 3. UI PANELS
// ----------------------------------------------------
void drawTopBar() {
  fill(235, 235, 235, 245);
  noStroke();
  rect(0, 0, width, topBarH);
  
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(min(width, height) * 0.04);
  text("Tap here to change function", width / 2.0, topBarH * 0.3);
  
  fill(0, 100, 200);
  textSize(min(width, height) * 0.05);
  text(options[currentFunction], width / 2.0, topBarH * 0.7);
}

void drawBottomBar() {
  fill(230, 230, 230);
  noStroke();
  rect(0, height - bottomBarH, width, bottomBarH);
  
  stroke(180);
  strokeWeight(2);
  line(0, height - bottomBarH, width, height - bottomBarH);
  
  // Draw 4 columns
  float colW = width / 4.0;
  line(colW, height - bottomBarH + 10, colW, height - 10);
  line(colW * 2, height - bottomBarH + 10, colW * 2, height - 10);
  line(colW * 3, height - bottomBarH + 10, colW * 3, height - 10);
  
  textAlign(CENTER, CENTER);
  textSize(min(width, height) * 0.032);
  
  // 1. FAST AUTO Button
  fill((playMode == 0 && isPlaying) ? color(0, 150, 0) : color(100));
  text("FAST AUTO", colW * 0.5, height - bottomBarH/2.0);
  
  // 2. SLOW PLOT Button
  fill((playMode == 1 && isPlaying) ? color(0, 150, 0) : color(100));
  text("SLOW PLOT", colW * 1.5, height - bottomBarH/2.0);
  
  // 3. NEXT POINT Button (Manual Step)
  fill(color(0, 100, 200));
  text("NEXT POINT ➡", colW * 2.5, height - bottomBarH/2.0);
  
  // 4. Connect All Button 
  fill(showCurve ? color(200, 150, 0) : color(100));
  text(showCurve ? "CURVE: ON" : "CONNECT ALL", colW * 3.5, height - bottomBarH/2.0);
}

void drawPanel() {
  fill(245);
  noStroke();
  rect(pX, pY, pW, pH);
  
  drawTableRows();
  drawSliderAndTableHeader();
}

void drawTableRows() {
  float rowH = pH * 0.12;
  float headerY = sliderY + sliderH + pH * 0.1;
  float headerBottom = headerY + rowH * 0.5; 
  
  float minMathX = -(gW / 2.0) / unit;
  float maxMathX = (gW / 2.0) / unit;
  
  // VIEWPORT CULLING OPTIMIZATION
  int totalRows = floor((maxMathX - minMathX) / currentStep) + 1;
  float totalContentHeight = totalRows * rowH;
  float availableViewHeight = (pY + pH) - headerBottom;
  
  float minOffset = min(0, availableViewHeight - totalContentHeight - rowH); 
  tableOffsetY = constrain(tableOffsetY, minOffset, 0); 
  float listStartY = headerBottom + rowH/2 + tableOffsetY;
  
  int startIdx = floor((pY - listStartY) / rowH);
  startIdx = max(0, startIdx); 
  
  int endIdx = ceil(((pY + pH) - listStartY) / rowH);
  endIdx = min(totalRows - 1, endIdx); 
  
  for (int i = startIdx; i <= endIdx; i++) {
    float x = minMathX + (i * currentStep);
    float currentYPos = listStartY + (i * rowH);
    
    if (currentYPos > pY && currentYPos < pY + pH + rowH) {
      float y = evaluateFunction(x);
      
      String xStr = nf(x, 1, 2);
      String yStr = (Float.isNaN(y) || Float.isInfinite(y)) ? "Undef" : nf(y, 1, 2);
      if (xStr.equals("-0.00")) xStr = "0.00";
      if (yStr.equals("-0.00")) yStr = "0.00";
      
      if (abs(animLimitX - x) < (currentStep / 2.0)) {
        fill(255, 200, 200);
        noStroke();
        rect(pX, currentYPos - rowH*0.4, pW, rowH*0.8);
        fill(255, 0, 0); 
      } else {
        fill(0);
      }
      
      textAlign(CENTER, CENTER);
      textSize(min(pW, pH) * 0.08);
      text(xStr, pX + pW * 0.25, currentYPos);
      text(yStr, pX + pW * 0.75, currentYPos);
    }
  }
}

void drawSliderAndTableHeader() {
  float rowH = pH * 0.12;
  float headerY = sliderY + sliderH + pH * 0.1;
  float headerBottom = headerY + rowH * 0.5;
  
  fill(245);
  noStroke();
  rect(pX, pY, pW, headerBottom - pY); 
  
  stroke(200);
  strokeWeight(2);
  if (width > height) line(pX, pY, pX, pY + pH); 
  else line(pX, pY, pX + pW, pY);
  
  fill(220);
  noStroke();
  rect(sliderX, sliderY, sliderW, sliderH, 10);
  
  fill(100, 150, 255);
  float knobX = sliderX + (sliderVal * sliderW);
  rect(knobX - (sliderH/2), sliderY - 5, sliderH, sliderH + 10, 8);
  
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(min(pW, pH) * 0.08);
  text("Step Size: " + nf(currentStep, 1, 2), pX + pW/2.0, sliderY - pH * 0.05);
  
  fill(50);
  text("x points", pX + pW * 0.25, headerY);
  text("y points", pX + pW * 0.75, headerY);
  
  stroke(180);
  strokeWeight(2);
  line(pX + pW*0.1, headerBottom, pX + pW*0.9, headerBottom);
}

// ----------------------------------------------------
// 4. TOUCH CONTROLS
// ----------------------------------------------------
void mousePressed() {
  if (touches != null && touches.length > 1) return; 
  
  // 1. Bottom Menu Bar (4 Columns)
  if (mouseY > height - bottomBarH) {
    if (mouseX < width / 4.0) {
      // FAST AUTO
      playMode = 0;
      isPlaying = true;
      
    } else if (mouseX < width * 2.0 / 4.0) {
      // SLOW PLOT
      playMode = 1;
      isPlaying = true;
      slowTimer = 0;
      
      // Snap to nearest discrete point mathematically
      float minMathX = -(gW / 2.0) / unit;
      int currentIndex = round((animLimitX - minMathX) / currentStep);
      animLimitX = minMathX + currentIndex * currentStep;
      
    } else if (mouseX < width * 3.0 / 4.0) {
      // NEXT POINT (Manual Step)
      playMode = 2;
      isPlaying = false;
      
      float minMathX = -(gW / 2.0) / unit;
      float maxMathX = (gW / 2.0) / unit;
      int currentIndex = floor((animLimitX - minMathX) / currentStep + 0.001);
      float nextX = minMathX + (currentIndex + 1) * currentStep;
      
      if (nextX <= maxMathX + 0.001) animLimitX = nextX;
      else animLimitX = maxMathX;
      
    } else {
      // CONNECT ALL
      showCurve = !showCurve;
    }
    return;
  }
  
  // 2. Top Bar
  if (mouseY < topBarH) {
    currentFunction = (currentFunction + 1) % options.length;
    tableOffsetY = 0; 
    animLimitX = -(gW / 2.0) / unit; 
    isPlaying = true;
    slowTimer = 0;
    return;
  }
  
  // 3. Graph Area
  if (mouseX > gX && mouseX < gX + gW && mouseY > gY && mouseY < gY + gH) {
    animLimitX = -(gW / 2.0) / unit; 
    isPlaying = true;
    slowTimer = 0;
    return;
  }
  
  // 4. Slider Drag
  if (mouseX > sliderX - 20 && mouseX < sliderX + sliderW + 20 &&
      mouseY > sliderY - 20 && mouseY < sliderY + sliderH + 20) {
    isDraggingSlider = true;
    return;
  }
  
  // 5. Table Rows
  float rowH = pH * 0.12;
  float headerY = sliderY + sliderH + pH * 0.1;
  float headerBottom = headerY + rowH * 0.5;
  float listStartY = headerBottom + rowH/2 + tableOffsetY;
  
  if (mouseX > pX && mouseX < pX + pW && mouseY > headerBottom && mouseY < pY + pH) {
    float minMathX = -(gW / 2.0) / unit;
    int rowIndex = round((mouseY - listStartY) / rowH);
    float targetX = minMathX + (rowIndex * currentStep);
    float maxMathX = (gW / 2.0) / unit;
    
    if (targetX >= minMathX - (currentStep/2) && targetX <= maxMathX + (currentStep/2)) {
      animLimitX = targetX; 
      playMode = 2; // Switch to manual so user can examine
      isPlaying = false; 
    }
  }
}

void mouseDragged() {
  if (touches != null && touches.length > 1) return; 
  
  if (isDraggingSlider) {
    sliderVal = constrain((mouseX - sliderX) / sliderW, 0.0, 1.0);
    tableOffsetY = 0; 
    animLimitX = -(gW / 2.0) / unit;
    isPlaying = true;
    slowTimer = 0;
  } 
  else if (mouseX > pX && mouseY > pY + sliderY + sliderH && mouseY < height - bottomBarH) {
    tableOffsetY += (mouseY - pmouseY);
  }
}

void mouseReleased() {
  isDraggingSlider = false;
}
