/*
================================================================
 RIEMANN ZETA EXPLORER — APDE / PROCESSING ANDROID
 FULL COMPLEX PLANE + CRITICAL STRIP + 7/8 BOUNDARY
 BIDIRECTIONAL EXPLORATORY HARDY-Z SIGNAL SCANNER
 RUBY CANDIDATE MARKERS + LOGISTIC MAP + 20-STEP COBWEB
================================================================

SCIENTIFIC STATUS:
- Critical strip: 0 < Re(s) < 1.
- Critical line: Re(s) = 1/2.
- The 7/8 line visualizes a zero-free half-plane claim.
- Classical Riemann Hypothesis remains unproved.
- The 7/8 line is NOT the critical line.
- Exterior dots are random complex-plane samples, not zeros.
- hardyZLeadingApprox() is a leading approximation only.
- Its sign changes are exploratory candidates, NOT certified
  Riemann-zeta zeros.
- Logistic-map dynamics are unrelated to RH.

APDE NOTE:
If fullScreen() orientation is incorrect, configure Landscape
in APDE settings. Do not call orientation() after fullScreen().
================================================================
*/

import java.util.Random;
import java.util.Locale;

// ------------------------- RANDOM ------------------------------
Random rng = new Random();

// ------------------------- COLOURS -----------------------------
color BG, PANEL, GRID, GOLD, GREEN, BLUE, RED, PURPLE, WHITE;
color RUBY, RUBY_LIGHT, CYAN, LEFT_COLOR, RIGHT_COLOR, ORANGE;

// ------------------------- COMPLEX PLANE -----------------------
double SIGMA_MIN = -0.5;
double SIGMA_MAX = 1.5;

final double SEVEN_EIGHTHS = 7.0 / 8.0;
boolean showSevenEighthsBoundary = true;

float planeMinT = 0;
float planeMaxT = 245;

// ------------------------- LAYOUT -------------------------------
float lx, ly, lw, lh, rx, ry, rw, rh;

// ------------------------- SEARCH -------------------------------
final double MIN_T = 10.0;
final double MAX_T = 240.0;

final int POINTS_PER_DIRECTION = 5000;

final double SEARCH_STEP =
  (MAX_T-MIN_T)/POINTS_PER_DIRECTION;

final int MAX_RESULTS = 1000;

double[] results = new double[MAX_RESULTS];
double[] residuals = new double[MAX_RESULTS];

int resultCount = 0;
int accepted = 0;
int rejected = 0;

boolean searching = false;
boolean paused = false;

String statusText = "READY";

// ------------------------- RANDOM START -------------------------
double randomPointT = 0;

int randomPointCount = 0;

boolean randomPointReady = false;

// ------------------------- EXTERIOR POINTS ----------------------
final int EXTERIOR_COUNT = 50;

double[] leftSigma = new double[EXTERIOR_COUNT];
double[] leftT = new double[EXTERIOR_COUNT];

double[] rightSigma = new double[EXTERIOR_COUNT];
double[] rightT = new double[EXTERIOR_COUNT];

int leftPointCount = 0;
int rightPointCount = 0;

boolean exteriorPointsReady = false;

// ------------------------- SEARCH STATE -------------------------
double previousT = 0;
double previousZ = 0;

double bracketA = 0;
double bracketB = 0;

double bracketFA = 0;
double bracketFB = 0;

int scanIndex = 0;
int sampleCount = 0;

boolean downwardPhase = false;

double candidateT = 0;
double candidateResidual = 0;

boolean candidateVisible = false;
boolean candidateAccepted = false;

int candidateDisplayFrames = 0;
int bisectionIterations = 0;

// ------------------------- LOGISTIC MAP -------------------------
double logisticR = 4.0;

double logisticX0 = 0.37123456789;
double logisticX = 0.37123456789;

long logisticN = 0;

final int HISTORY_SIZE = 500;

double[] logisticHistory =
  new double[HISTORY_SIZE];

int historyCount = 0;
int historyWrite = 0;

// ------------------------- COBWEB -------------------------------
final int COBWEB_ITERATIONS = 20;

final int COBWEB_ARRAY_SIZE =
  COBWEB_ITERATIONS+1;

double[] cobX =
  new double[COBWEB_ARRAY_SIZE];

double[] cobY =
  new double[COBWEB_ARRAY_SIZE];

int cobCount = 0;

int cobAnimationFrame = 0;
int cobAnimationSpeed = 9;

boolean cobwebActive = false;

double cobwebSeed = 0.37123456789;
double cobwebCandidateT = 0;

int cobwebEventNumber = 0;

String cobwebStatus =
  "WAITING FOR CANDIDATE";

// ------------------------- REFERENCE ZEROS ---------------------
double[] knownZeros = {

14.134725141735,21.022039638772,
25.010857580146,30.424876125860,
32.935061587739,37.586178158826,
40.918719012148,43.327073280915,
48.005150881167,49.773832477672,

52.970321477714,56.446247697063,
59.347044002602,60.831778524610,
65.112544048082,67.079810529494,
69.546401711174,72.067157674482,
75.704690699084,77.144840068875,

79.337375020249,82.910380854086,
84.735492980517,87.425274613125,
88.809111207634,92.491899270558,
94.651344040520,95.870634228245,
98.831194218194,101.317851005731,

103.725538040478,105.446623052326,
107.168611184276,111.029535543170,
111.874659176993,114.320220915453,
116.226680320858,118.790782865976,
121.370125002421,122.946829293553,

124.256818554346,127.516683879596,
129.578704199956,131.087688530933,
133.497737202998,134.756509753374,
138.116042054533,139.736208952121,
141.123707404021,143.111845807621,

146.000982486766,147.422765342560,
150.053520420785,150.925257612241,
153.024693811199,156.112909294238,
157.597591817594,158.849988171421,
161.188964137596,163.030709687182,

165.537069187900,167.184439978175,
169.094515415569,169.911976479412,
173.411536519592,174.754191523366,
176.441434297710,178.377407776100,
179.916484020257,182.207078484366,

184.874467848387,185.598783677707,
187.228922583502,189.416158656017,
192.026656360714,193.079726603846,
195.265396679529,196.876481840958,
198.015309676252,201.264751943704,

202.493594514141,204.189671803105,
205.394697202163,207.906258887806,
209.576509716856,211.690862595365,
213.347919359713,214.547044783491,
216.169538508264,219.067596349021,

220.714918839314,221.430705554693,
224.007000254604,224.983324669582,
227.421444279679,229.337413305525,
231.250188700499,231.987235253180,
233.693404178908,236.524229665816
};

// ------------------------- SETTINGS / SETUP --------------------
void settings() {
  fullScreen();
}

void setup() {

  smooth(4);
  frameRate(60);

  BG = color(3,7,19);
  PANEL = color(13,25,45);
  GRID = color(60,88,120);

  GOLD = color(255,210,65);
  GREEN = color(45,255,115);
  BLUE = color(55,175,255);
  RED = color(255,65,80);
  PURPLE = color(195,100,255);
  WHITE = color(240);

  RUBY = color(220,0,45);
  RUBY_LIGHT = color(255,65,100);

  CYAN = color(50,240,255);

  LEFT_COLOR = color(255,100,80);
  RIGHT_COLOR = color(80,190,255);

  ORANGE = color(255,145,55);

  textFont(createFont("SansSerif",14));

  calculateLayout();

  generateExteriorPoints();

  resetLogistic();
  resetCobweb();
}

// ------------------------- LAYOUT / MAPPING ---------------------
void calculateLayout() {

  lx = width*0.025f;
  ly = height*0.145f;
  lw = width*0.625f;
  lh = height*0.695f;

  rx = width*0.67f;
  ry = height*0.145f;
  rw = width*0.305f;
  rh = height*0.695f;
}

float mapF(
  float v,
  float a,
  float b,
  float c,
  float d
) {

  if (a==b) return c;

  return c+(v-a)*(d-c)/(b-a);
}

float sigmaToScreen(double sigma) {

  float px = lx+lw*0.105f;
  float pw = lw*0.86f;

  return mapF(
    (float)sigma,
    (float)SIGMA_MIN,
    (float)SIGMA_MAX,
    px,
    px+pw
  );
}

float tToScreen(double t) {

  float py = ly+47;
  float ph = lh-100;

  return mapF(
    (float)t,
    planeMinT,
    planeMaxT,
    py+ph,
    py
  );
}

String f9(double v) {

  return String.format(
    Locale.US,
    "%.9f",
    v
  );
}

// ------------------------- MAIN DRAW ----------------------------
void draw() {

  background(BG);

  calculateLayout();

  for (int i=0;i<4;i++) {
    stepLogistic();
  }

  updateCobwebAnimation();

  if (searching && !paused) {

    if (candidateVisible && candidateAccepted) {
      updateCandidateDisplay();
    } else {
      updateSearch();
    }
  }

  drawHeader();

  drawCriticalStrip();

  drawRightDashboard();

  drawControls();
}

// ------------------------- HEADER -------------------------------
void drawHeader() {

  fill(GOLD);

  textAlign(CENTER,CENTER);
  textSize(20);

  text(
    "RIEMANN ZETA EXPLORER",
    width/2,
    height*0.045f
  );

  fill(160,205,240);
  textSize(9);

  text(
    "FULL COMPLEX PLANE | CRITICAL STRIP | 7/8 ZERO-FREE CLAIM",
    width/2,
    height*0.095f
  );
}

// ------------------------- COMPLEX PLANE ------------------------
void drawCriticalStrip() {

  noStroke();
  fill(PANEL);

  rect(lx,ly,lw,lh,12);

  float px = lx+lw*0.105f;
  float py = ly+47;

  float pw = lw*0.86f;
  float ph = lh-100;

  float x0 = sigmaToScreen(0);
  float x1 = sigmaToScreen(1);
  float xHalf = sigmaToScreen(0.5);
  float xSeven = sigmaToScreen(SEVEN_EIGHTHS);

  // LEFT EXTERIOR
  fill(48,19,28);
  rect(px,py,x0-px,ph);

  // CRITICAL STRIP
  fill(12,48,70);
  rect(x0,py,x1-x0,ph);

  // RIGHT EXTERIOR
  fill(24,31,56);
  rect(x1,py,px+pw-x1,ph);

  // VERTICAL GRID
  for (int i=0;i<=8;i++) {

    double sig =
      SIGMA_MIN+
      (SIGMA_MAX-SIGMA_MIN)*i/8.0;

    float xx = sigmaToScreen(sig);

    stroke(GRID,110);
    strokeWeight(0.8f);

    line(xx,py,xx,py+ph);

    noStroke();
    fill(190,210,230);

    textAlign(CENTER,CENTER);
    textSize(8);

    text(
      String.format(Locale.US,"%.2f",sig),
      xx,
      py+ph+15
    );
  }

  // HORIZONTAL GRID
  for (int i=0;i<=10;i++) {

    float tv = i*24.5f;
    float yy = tToScreen(tv);

    stroke(GRID,120);
    strokeWeight(0.8f);

    line(px,yy,px+pw,yy);

    noStroke();
    fill(200,215,235);

    textAlign(RIGHT,CENTER);
    textSize(8);

    text(nf(tv,1,1),px-5,yy);
  }

  // CRITICAL STRIP BOUNDARIES
  stroke(CYAN);
  strokeWeight(2);

  line(x0,py,x0,py+ph);
  line(x1,py,x1,py+ph);

  // CRITICAL LINE Re(s)=1/2
  for (int k=8;k>=1;k--) {

    stroke(255,210,65,12);
    strokeWeight(k*2);

    line(xHalf,py,xHalf,py+ph);
  }

  stroke(GOLD);
  strokeWeight(2.8f);

  line(xHalf,py,xHalf,py+ph);

  // ------------------------------------------------------------
  // 7/8 ZERO-FREE BOUNDARY CLAIM — NOT THE CRITICAL LINE
  // ------------------------------------------------------------

  if (showSevenEighthsBoundary) {

    stroke(ORANGE);
    strokeWeight(2);

    for (float yy=py;yy<py+ph;yy+=10) {

      line(
        xSeven,
        yy,
        xSeven,
        Math.min(yy+5,py+ph)
      );
    }

    noStroke();
    fill(ORANGE);

    textAlign(CENTER,BOTTOM);
    textSize(9);

    text(
      "7/8 BOUNDARY",
      xSeven,
      py-5
    );

    textAlign(CENTER,TOP);
    textSize(7);

    text(
      "CLAIMED ZERO-FREE HALF-PLANE",
      (xSeven+sigmaToScreen(SIGMA_MAX))/2,
      py+24
    );
  }

  // REGION LABELS
  noStroke();
  textAlign(CENTER,TOP);
  textSize(8);

  fill(255,135,115);

  text(
    "LEFT EXTERIOR",
    (px+x0)/2,
    py+5
  );

  fill(CYAN);

  text(
    "CRITICAL STRIP",
    (x0+x1)/2,
    py+5
  );

  fill(RIGHT_COLOR);

  text(
    "RIGHT EXTERIOR",
    (x1+px+pw)/2,
    py+5
  );

  // CRITICAL LINE LABEL
  fill(GOLD);

  textAlign(CENTER,BOTTOM);
  textSize(9);

  text(
    "CRITICAL LINE: Re(s) = 0.5",
    xHalf,
    py-5
  );

  // RANDOM EXTERIOR POINTS
  if (exteriorPointsReady) {

    for (int i=0;i<leftPointCount;i++) {

      drawComplexPoint(
        leftSigma[i],
        leftT[i],
        LEFT_COLOR,
        4
      );
    }

    for (int i=0;i<rightPointCount;i++) {

      drawComplexPoint(
        rightSigma[i],
        rightT[i],
        RIGHT_COLOR,
        4
      );
    }
  }

  // REFERENCE NON-TRIVIAL ZERO ORDINATES
  for (int i=0;i<knownZeros.length;i++) {

    drawComplexPoint(
      0.5,
      knownZeros[i],
      GOLD,
      5
    );
  }

  // EXPLORATORY CANDIDATES
  for (int i=0;i<resultCount;i++) {

    drawRubyDiamond(
      0.5,
      results[i],
      7,
      false
    );
  }

  // RANDOM SEARCH START
  if (randomPointReady) {

    drawComplexPoint(
      0.5,
      randomPointT,
      PURPLE,
      9
    );
  }

  // ACTIVE CANDIDATE
  if (candidateVisible) {

    drawRubyDiamond(
      0.5,
      candidateT,
      17,
      true
    );
  }

  // FOOTER
  textAlign(LEFT,CENTER);
  textSize(8);

  fill(LEFT_COLOR);
  text(
    "LEFT SAMPLES: "+leftPointCount,
    lx+10,
    ly+lh-16
  );

  fill(RIGHT_COLOR);
  text(
    "RIGHT SAMPLES: "+rightPointCount,
    lx+lw*0.24f,
    ly+lh-16
  );

  fill(GOLD);
  text(
    "REFERENCE: "+knownZeros.length,
    lx+lw*0.48f,
    ly+lh-16
  );

  fill(GREEN);
  text(
    "APPROX CANDIDATES: "+resultCount,
    lx+lw*0.72f,
    ly+lh-16
  );
}

// ------------------------- EXTERIOR POINT GENERATION ------------
void generateExteriorPoints() {

  leftPointCount = EXTERIOR_COUNT;
  rightPointCount = EXTERIOR_COUNT;

  for (int i=0;i<EXTERIOR_COUNT;i++) {

    leftSigma[i] =
      -0.5+rng.nextDouble()*0.49;

    leftT[i] =
      rng.nextDouble()*245.0;

    rightSigma[i] =
      1.01+rng.nextDouble()*0.49;

    rightT[i] =
      rng.nextDouble()*245.0;
  }

  exteriorPointsReady = true;
}

// ------------------------- DRAW COMPLEX POINT -------------------
void drawComplexPoint(
  double sigma,
  double t,
  color c,
  float size
) {

  if (sigma<SIGMA_MIN ||
      sigma>SIGMA_MAX ||
      t<planeMinT ||
      t>planeMaxT) return;

  float xx = sigmaToScreen(sigma);
  float yy = tToScreen(t);

  noStroke();

  fill(
    red(c),
    green(c),
    blue(c),
    55
  );

  ellipse(xx,yy,size*3,size*3);

  fill(c);

  ellipse(xx,yy,size,size);
}

// ------------------------- RUBY DIAMOND -------------------------
void drawRubyDiamond(
  double sigma,
  double t,
  float size,
  boolean large
) {

  float xx = sigmaToScreen(sigma);
  float yy = tToScreen(t);

  float pulse =
    0.5f+0.5f*sin(frameCount*0.22f);

  noStroke();

  fill(255,0,55,35+pulse*70);

  ellipse(
    xx,yy,
    size*(1.8f+pulse)*2,
    size*(1.8f+pulse)*2
  );

  fill(160,0,35,100);

  ellipse(
    xx,yy,
    size*1.9f,
    size*1.9f
  );

  fill(RUBY);

  beginShape();
  vertex(xx,yy-size);
  vertex(xx+size,yy);
  vertex(xx,yy+size);
  vertex(xx-size,yy);
  endShape(CLOSE);

  fill(RUBY_LIGHT);

  beginShape();
  vertex(xx,yy-size);
  vertex(xx+size*0.45f,yy);
  vertex(xx,yy+size*0.25f);
  vertex(xx-size*0.45f,yy);
  endShape(CLOSE);

  stroke(255,190,205,220);
  strokeWeight(1);
  noFill();

  beginShape();
  vertex(xx,yy-size);
  vertex(xx+size,yy);
  vertex(xx,yy+size);
  vertex(xx-size,yy);
  endShape(CLOSE);

  if (large) {

    fill(255,100,130);
    noStroke();

    textAlign(LEFT,CENTER);
    textSize(9);

    text(
      "APPROX CANDIDATE",
      xx+size+6,
      yy
    );
  }
}

// ------------------------- RIGHT DASHBOARD ----------------------
void drawRightDashboard() {

  noStroke();
  fill(PANEL);

  rect(rx,ry,rw,rh,12);

  float x = rx+10;

  fill(BLUE);
  textAlign(LEFT,TOP);
  textSize(12);

  text("LOGISTIC MAP LAB",x,ry+8);

  fill(WHITE);
  textSize(8);

  text(
    "x(n+1) = r x(n)[1-x(n)]",
    x,ry+25
  );

  text(
    "r = 4.0 | Independent system",
    x,ry+39
  );

  float top = ry+56;
  float gap = 7;

  float graphW = (rw-25)/2.0f;
  float graphH = rh*0.34f;

  drawLogisticGraph(
    x,top,graphW,graphH
  );

  drawCobweb(
    x+graphW+gap,
    top,
    graphW,
    graphH
  );

  float yy = top+graphH+9;

  fill(GOLD);
  textSize(9);

  text(
    "COMPLEX PLANE / RESEARCH NOTES",
    x,yy
  );

  yy+=15;

  fill(LEFT_COLOR);
  textSize(8);

  text("Left exterior: Re(s) < 0",x,yy);

  yy+=13;

  fill(RIGHT_COLOR);
  text("Right exterior: Re(s) > 1",x,yy);

  yy+=13;

  fill(ORANGE);
  text("Claimed zero-free: Re(s) > 7/8",x,yy);

  yy+=13;

  fill(GOLD);
  text("Critical line: Re(s) = 1/2",x,yy);

  yy+=15;

  fill(PURPLE);
  text(
    "Start: s = 0.5 + i("+f9(randomPointT)+")",
    x,yy
  );

  yy+=14;

  fill(WHITE);
  text("Samples: "+sampleCount,x,yy);

  yy+=14;

  fill(GREEN);
  text(
    "Approx candidates: "+accepted+" | Rejected: "+rejected,
    x,yy
  );

  yy+=14;

  fill(RUBY_LIGHT);
  text("Cobweb: "+cobCount+"/20",x,yy);

  yy+=14;

  fill(GOLD);
  text("STATUS: "+statusText,x,yy);

  yy+=14;

  fill(WHITE);
  textSize(7);

  text(cobwebStatus,x,yy);
}

// ------------------------- LOGISTIC TIME SERIES -----------------
void drawLogisticGraph(
  float gx,
  float gy,
  float gw,
  float gh
) {

  noStroke();
  fill(3,9,22);

  rect(gx,gy,gw,gh,5);

  stroke(GRID);
  strokeWeight(1);

  line(
    gx+3,
    gy+gh*0.5f,
    gx+gw-3,
    gy+gh*0.5f
  );

  noFill();
  stroke(BLUE);
  strokeWeight(1.4f);

  beginShape();

  for (int i=0;i<historyCount;i++) {

    int index =
      (historyWrite-historyCount+i+HISTORY_SIZE)
      %HISTORY_SIZE;

    float xx = mapF(
      i,
      0,
      Math.max(1,historyCount-1),
      gx+3,
      gx+gw-3
    );

    float yy = mapF(
      (float)logisticHistory[index],
      0,
      1,
      gy+gh-3,
      gy+3
    );

    vertex(xx,yy);
  }

  endShape();

  noStroke();
  fill(WHITE);

  textAlign(LEFT,TOP);
  textSize(7);

  text("ITERATION HISTORY",gx+4,gy+3);
  text("n="+logisticN,gx+4,gy+12);
}

// ------------------------- COBWEB DIAGRAM -----------------------
void drawCobweb(
  float gx,
  float gy,
  float gw,
  float gh
) {

  noStroke();
  fill(3,9,22);

  rect(gx,gy,gw,gh,5);

  float margin = 10;

  float x0 = gx+margin;
  float y0 = gy+gh-margin;

  float plotW = gw-2*margin;
  float plotH = gh-2*margin;

  stroke(GRID);
  strokeWeight(1);

  line(x0,y0-plotH,x0,y0);
  line(x0,y0,x0+plotW,y0);

  // y=x diagonal
  stroke(115,145,175);

  line(
    x0,y0,
    x0+plotW,y0-plotH
  );

  // Logistic curve
  noFill();
  stroke(BLUE);
  strokeWeight(1.5f);

  beginShape();

  for (int i=0;i<=100;i++) {

    float v = i/100.0f;

    float next =
      (float)(logisticR*v*(1.0-v));

    vertex(
      x0+v*plotW,
      y0-next*plotH
    );
  }

  endShape();

  // Cobweb iterations
  for (int i=0;i<cobCount;i++) {

    float ax = x0+(float)cobX[i]*plotW;
    float ay = y0-(float)cobY[i]*plotH;

    float bx = x0+(float)cobX[i+1]*plotW;
    float by = y0-(float)cobY[i]*plotH;

    stroke(RUBY_LIGHT);
    strokeWeight(1.4f);

    line(
      ax,
      y0-(float)cobX[i]*plotH,
      ax,
      ay
    );

    line(ax,ay,bx,by);

    noStroke();
    fill(GOLD);

    ellipse(bx,by,3.5f,3.5f);
  }

  noStroke();
  fill(CYAN);

  ellipse(
    x0+(float)cobX[0]*plotW,
    y0-(float)cobX[0]*plotH,
    6,6
  );

  fill(WHITE);
  textAlign(LEFT,TOP);
  textSize(7);

  text("LIVE COBWEB",gx+4,gy+3);

  fill(RUBY_LIGHT);

  text(
    "n="+cobCount,
    gx+gw-28,
    gy+3
  );
}

// ------------------------- COBWEB RESET ------------------------
void resetCobweb() {

  cobCount = 0;
  cobAnimationFrame = 0;
  cobwebActive = false;

  cobwebSeed = logisticX0;
  cobwebCandidateT = 0;
  cobwebEventNumber = 0;

  cobwebStatus = "WAITING FOR CANDIDATE";

  cobX[0] = cobwebSeed;

  cobY[0] =
    logisticR*cobwebSeed*(1.0-cobwebSeed);

  for (int i=1;i<COBWEB_ARRAY_SIZE;i++) {

    cobX[i] = 0;
    cobY[i] = 0;
  }
}

// ------------------------- START COBWEB EVENT -------------------
void startCobwebForCandidate(double t) {

  cobwebEventNumber++;
  cobwebCandidateT = t;

  double fractional =
    Math.abs(t*0.6180339887498948);

  fractional -= Math.floor(fractional);

  cobwebSeed = 0.1+0.8*fractional;

  cobCount = 0;
  cobAnimationFrame = 0;
  cobwebActive = true;

  cobX[0] = cobwebSeed;

  cobY[0] =
    logisticR*cobwebSeed*(1.0-cobwebSeed);

  for (int i=1;i<COBWEB_ARRAY_SIZE;i++) {

    cobX[i] = 0;
    cobY[i] = 0;
  }

  cobwebStatus = "NEW APPROX CANDIDATE - STARTING";
}

// ------------------------- UPDATE COBWEB -----------------------
void updateCobwebAnimation() {

  if (!cobwebActive) return;

  cobAnimationFrame++;

  if (cobAnimationFrame<cobAnimationSpeed) return;

  cobAnimationFrame = 0;

  if (cobCount>=COBWEB_ITERATIONS) {

    cobwebActive = false;
    cobwebStatus = "20 ITERATIONS COMPLETE";

    return;
  }

  double xn = cobX[cobCount];

  double next =
    logisticR*xn*(1.0-xn);

  cobCount++;

  cobX[cobCount] = next;

  cobY[cobCount] =
    logisticR*next*(1.0-next);

  if (cobCount>=COBWEB_ITERATIONS) {

    cobwebActive = false;
    cobwebStatus = "20 ITERATIONS COMPLETE";

  } else {

    cobwebStatus = "ITERATING x"+cobCount;
  }
}

// ------------------------- LOGISTIC FUNCTION --------------------
double logisticFunction(double x) {

  return logisticR*x*(1.0-x);
}

// ------------------------- LOGISTIC UPDATE -----------------------
void stepLogistic() {

  logisticX = logisticFunction(logisticX);

  logisticN++;

  if (!validNumber(logisticX) ||
      logisticX<0 ||
      logisticX>1) {

    logisticX = logisticX0;
  }

  logisticHistory[historyWrite] = logisticX;

  historyWrite =
    (historyWrite+1)%HISTORY_SIZE;

  if (historyCount<HISTORY_SIZE) {
    historyCount++;
  }
}

// ------------------------- RESET LOGISTIC ------------------------
void resetLogistic() {

  logisticX = logisticX0;

  logisticN = 0;
  historyCount = 0;
  historyWrite = 0;

  for (int i=0;i<HISTORY_SIZE;i++) {
    logisticHistory[i] = 0;
  }
}

// ------------------------- RANDOM CRITICAL-LINE T ----------------
double chooseRandomPoint() {

  double t =
    MIN_T+(MAX_T-MIN_T)*rng.nextDouble();

  return Math.round(t*1000000000.0)
    /1000000000.0;
}

// ------------------------- BEGIN NEW SEARCH ----------------------
void beginNewRandomSearch() {

  if (!searching) return;

  if (resultCount>=MAX_RESULTS) {

    searching = false;
    statusText = "STORAGE FULL";

    return;
  }

  randomPointCount++;

  randomPointT = chooseRandomPoint();
  randomPointReady = true;

  candidateVisible = false;
  candidateAccepted = false;
  candidateDisplayFrames = 0;

  candidateT = randomPointT;
  candidateResidual = 0;

  scanIndex = 0;
  sampleCount = 0;
  downwardPhase = false;

  previousT = randomPointT;
  previousZ = hardyZLeadingApprox(previousT);

  bracketA = 0;
  bracketB = 0;
  bracketFA = 0;
  bracketFB = 0;

  bisectionIterations = 0;

  statusText = "SEARCHING UPWARD (APPROX)";
}

// ------------------------- NEXT SCAN T ---------------------------
double getNextScanT() {

  if (!downwardPhase) {

    return randomPointT+
      (scanIndex+1)*SEARCH_STEP;
  }

  return randomPointT-
    (scanIndex+1)*SEARCH_STEP;
}

// ------------------------- BIDIRECTIONAL SEARCH ------------------
void updateSearch() {

  if (!searching || paused) return;

  int batch = 25;

  for (int q=0;q<batch;q++) {

    double t = getNextScanT();

    if (!downwardPhase && t>MAX_T) {

      downwardPhase = true;
      scanIndex = 0;

      previousT = randomPointT;
      previousZ = hardyZLeadingApprox(previousT);

      statusText = "SEARCHING DOWNWARD (APPROX)";

      continue;
    }

    if (downwardPhase && t<MIN_T) {

      statusText = "RANGE SCANNED - NEW RANDOM START";

      beginNewRandomSearch();

      return;
    }

    scanIndex++;
    sampleCount++;

    double z = hardyZLeadingApprox(t);

    if (validNumber(previousZ) &&
        validNumber(z) &&
        previousZ*z<0.0) {

      bracketA = Math.min(previousT,t);
      bracketB = Math.max(previousT,t);

      if (previousT<t) {

        bracketFA = previousZ;
        bracketFB = z;

      } else {

        bracketFA = z;
        bracketFB = previousZ;
      }

      previousT = t;
      previousZ = z;

      statusText = "APPROX SIGN CHANGE - REFINING";

      refineCandidate();

      return;
    }

    previousT = t;
    previousZ = z;
  }
}

// ------------------------- BISECTION / CANDIDATES ----------------
void refineCandidate() {

  double a = bracketA;
  double b = bracketB;

  double fa = bracketFA;

  boolean converged = false;

  double mid = 0;

  bisectionIterations = 0;

  for (int i=0;i<70;i++) {

    mid = (a+b)*0.5;

    double fm = hardyZLeadingApprox(mid);

    bisectionIterations++;

    if (!validNumber(fm)) break;

    if (Math.abs(fm)<1.0e-8) {

      converged = true;
      break;
    }

    if (fa*fm<0.0) {

      b = mid;

    } else {

      a = mid;
      fa = fm;
    }

    if (Math.abs(b-a)<1.0e-10) {

      converged = true;
      break;
    }
  }

  candidateT = (a+b)*0.5;

  candidateResidual =
    Math.abs(hardyZLeadingApprox(candidateT));

  candidateVisible = true;

  if (converged &&
      validNumber(candidateResidual) &&
      candidateResidual<0.001) {

    recordApproxCandidate(candidateT);

  } else {

    rejected++;

    candidateVisible = false;
    candidateAccepted = false;

    statusText = "APPROX RESIDUAL SCREEN FAILED";
  }
}

// ------------------------- REFERENCE ZERO CHECK ------------------
boolean isKnownZero(double t) {

  for (int i=0;i<knownZeros.length;i++) {

    if (Math.abs(knownZeros[i]-t)<0.02) {
      return true;
    }
  }

  return false;
}

// ------------------------- DUPLICATE CHECK -----------------------
boolean isDuplicate(double t) {

  for (int i=0;i<resultCount;i++) {

    if (Math.abs(results[i]-t)<0.02) {
      return true;
    }
  }

  return false;
}

// ------------------------- RECORD APPROX CANDIDATE ---------------
void recordApproxCandidate(double t) {

  if (isKnownZero(t)) {

    rejected++;

    candidateVisible = false;
    candidateAccepted = false;

    statusText = "NEAR REFERENCE ZERO - NOT NEW";

    return;
  }

  if (isDuplicate(t)) {

    rejected++;

    candidateVisible = false;
    candidateAccepted = false;

    statusText = "DUPLICATE APPROX CANDIDATE";

    return;
  }

  if (resultCount>=MAX_RESULTS) {

    searching = false;
    statusText = "STORAGE FULL";

    return;
  }

  results[resultCount] = t;
  residuals[resultCount] = candidateResidual;

  resultCount++;
  accepted++;

  candidateAccepted = true;
  candidateVisible = true;

  candidateDisplayFrames = 120;

  startCobwebForCandidate(t);

  statusText = "APPROX CANDIDATE RECORDED - NOT CERTIFIED";
}

// ------------------------- CANDIDATE DISPLAY TIMER ---------------
void updateCandidateDisplay() {

  if (!candidateVisible || !candidateAccepted) return;

  candidateDisplayFrames--;

  if (candidateDisplayFrames<=0) {

    candidateVisible = false;
    candidateAccepted = false;

    statusText = downwardPhase ?
      "CONTINUING DOWNWARD" :
      "CONTINUING UPWARD";
  }
}

// ------------------------- HARDY-Z APPROXIMATION -----------------
// Leading approximation only. Not a complete Riemann-Siegel
// evaluator. This routine cannot certify any zeta zero.
double hardyZLeadingApprox(double t) {

  if (t<10 || !validNumber(t)) {
    return Double.NaN;
  }

  double theta = riemannSiegelThetaApprox(t);

  int nMax = (int)Math.floor(
    Math.sqrt(t/(2.0*Math.PI))
  );

  if (nMax<1) nMax = 1;

  double sum = 0;

  for (int n=1;n<=nMax;n++) {

    double angle =
      theta-t*Math.log(n);

    sum += Math.cos(angle)/Math.sqrt(n);
  }

  return 2.0*sum;
}

// ------------------------- THETA APPROXIMATION -------------------
double riemannSiegelThetaApprox(double t) {

  Complex z = new Complex(
    0.25,
    t/2.0
  );

  Complex lg = logGammaStirling(z);

  return lg.im-
    t*Math.log(Math.PI)/2.0;
}

// ------------------------- COMPLEX ARITHMETIC --------------------
class Complex {

  double re;
  double im;

  Complex(double a,double b) {
    re = a;
    im = b;
  }

  Complex add(Complex z) {
    return new Complex(re+z.re,im+z.im);
  }

  Complex sub(Complex z) {
    return new Complex(re-z.re,im-z.im);
  }

  Complex mul(Complex z) {

    return new Complex(
      re*z.re-im*z.im,
      re*z.im+im*z.re
    );
  }

  Complex scale(double a) {
    return new Complex(re*a,im*a);
  }

  Complex div(Complex z) {

    double den =
      z.re*z.re+z.im*z.im;

    if (den==0) {
      return new Complex(Double.NaN,Double.NaN);
    }

    return new Complex(
      (re*z.re+im*z.im)/den,
      (im*z.re-re*z.im)/den
    );
  }

  double abs() {
    return Math.hypot(re,im);
  }

  Complex log() {

    return new Complex(
      Math.log(abs()),
      Math.atan2(im,re)
    );
  }

  Complex reciprocal() {
    return new Complex(1,0).div(this);
  }
}

// ------------------------- STIRLING LOG GAMMA --------------------
Complex logGammaStirling(Complex z) {

  Complex zm = z.sub(
    new Complex(0.5,0)
  );

  Complex result =
    zm.mul(z.log()).sub(z);

  result = result.add(
    new Complex(0.9189385332046727,0)
  );

  Complex inv = z.reciprocal();

  Complex inv2 = inv.mul(inv);
  Complex inv3 = inv2.mul(inv);

  Complex inv5 = inv3.mul(inv2);
  Complex inv7 = inv5.mul(inv2);
  Complex inv9 = inv7.mul(inv2);

  result = result.add(
    inv.scale(1.0/12.0)
  );

  result = result.sub(
    inv3.scale(1.0/360.0)
  );

  result = result.add(
    inv5.scale(1.0/1260.0)
  );

  result = result.sub(
    inv7.scale(1.0/1680.0)
  );

  result = result.add(
    inv9.scale(1.0/1188.0)
  );

  return result;
}

// ------------------------- VALIDATION ----------------------------
boolean validNumber(double x) {

  return !Double.isNaN(x) &&
         !Double.isInfinite(x);
}

// ------------------------- CONTROLS ------------------------------
void drawControls() {

  float y = height*0.865f;
  float h = height*0.085f;

  float gap = width*0.012f;
  float x = width*0.035f;
  float w = width*0.17f;

  drawButton(
    "START",
    x,y,w,h,
    color(20,125,65)
  );

  drawButton(
    paused ? "RESUME":"PAUSE",
    x+(w+gap),y,w,h,
    color(40,65,105)
  );

  drawButton(
    "NEXT RANDOM",
    x+2*(w+gap),y,w,h,
    color(30,85,130)
  );

  drawButton(
    "RESET",
    x+3*(w+gap),y,w,h,
    color(110,40,70)
  );

  drawButton(
    "NEW POINTS",
    x+4*(w+gap),y,w,h,
    color(65,75,130)
  );
}

// ------------------------- BUTTON -------------------------------
void drawButton(
  String label,
  float x,
  float y,
  float w,
  float h,
  color c
) {

  fill(c);

  stroke(150,190,220);
  strokeWeight(1);

  rect(x,y,w,h,8);

  noStroke();
  fill(255);

  textAlign(CENTER,CENTER);
  textSize(10);

  text(label,x+w/2,y+h/2);
}

// ------------------------- TOUCH ---------------------------------
void mousePressed() {

  handleTouch(mouseX,mouseY);
}

// ------------------------- TOUCH HANDLER -------------------------
void handleTouch(float x,float y) {

  float by = height*0.865f;
  float bh = height*0.085f;

  float gap = width*0.012f;
  float bx = width*0.035f;
  float bw = width*0.17f;

  if (y<by || y>by+bh) return;

  // START
  if (x>=bx && x<bx+bw) {

    if (!searching) {

      searching = true;
      paused = false;

      beginNewRandomSearch();

    } else {

      paused = false;
      statusText = "SEARCH RUNNING (APPROXIMATION)";
    }

    return;
  }

  // PAUSE / RESUME
  if (x<bx+2*(bw+gap)) {

    if (searching) {

      paused = !paused;

      statusText =
        paused ? "PAUSED":"SEARCH RUNNING";
    }

    return;
  }

  // NEXT RANDOM
  if (x<bx+3*(bw+gap)) {

    if (searching) {

      paused = false;

      beginNewRandomSearch();
    }

    return;
  }

  // RESET
  if (x<bx+4*(bw+gap)) {

    resetAll();

    return;
  }

  // NEW EXTERIOR POINTS
  if (x<bx+5*(bw+gap)) {

    generateExteriorPoints();

    statusText = "NEW RANDOM COMPLEX-PLANE SAMPLES";

    return;
  }
}

// ------------------------- RESET ALL -----------------------------
void resetAll() {

  searching = false;
  paused = false;

  accepted = 0;
  rejected = 0;
  resultCount = 0;

  randomPointCount = 0;
  randomPointT = 0;
  randomPointReady = false;

  candidateT = 0;
  candidateResidual = 0;

  candidateVisible = false;
  candidateAccepted = false;
  candidateDisplayFrames = 0;

  scanIndex = 0;
  sampleCount = 0;
  downwardPhase = false;

  previousT = 0;
  previousZ = 0;

  bracketA = 0;
  bracketB = 0;
  bracketFA = 0;
  bracketFB = 0;

  bisectionIterations = 0;

  SIGMA_MIN = -0.5;
  SIGMA_MAX = 1.5;

  planeMinT = 0;
  planeMaxT = 245;

  generateExteriorPoints();

  resetLogistic();
  resetCobweb();

  statusText = "RESET - READY";
}

// ======================== END OF SKETCH ==========================
