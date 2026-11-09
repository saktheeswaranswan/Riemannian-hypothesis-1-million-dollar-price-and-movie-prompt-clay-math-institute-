/* ================================================================
RIEMANN ZETA - DUAL ZERO DISCOVERY LABORATORY
ANDROID APDE - PROCESSING JAVA MODE
================================================================
PERMANENT LANDSCAPE DASHBOARD

FAMILY 1: TRIVIAL ZEROS
zeta(-2n) = 0
-2, -4, -6, -8, -10, ...

FAMILY 2: NON-TRIVIAL ZERO CANDIDATES
s = 1/2 + i*t
Critical strip: 0 < Re(s) < 1
Critical line: Re(s) = 0.5

NEW FEATURES:
- Accumulated Points Complex Plane Plot (Z-Plane)
- Conformal Mapping Plane Plot (W-Plane via W = Z^1/2)
- Parametric Critical Line (Hyperbola in W-Plane)
- Infinite Vertical Panning (Touch & Drag)
================================================================ */

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.math.BigInteger;
import java.util.ArrayList;

//================================================================
// 1. PRECISION & CONSTANTS
//================================================================
final int PREC = 40;
final MathContext MC = new MathContext(PREC, RoundingMode.HALF_EVEN);

final BigDecimal ZERO = BigDecimal.ZERO;
final BigDecimal ONE = BigDecimal.ONE;
final BigDecimal TWO = new BigDecimal("2");
final BigDecimal HALF = new BigDecimal("0.5");
final BigDecimal TEN = BigDecimal.TEN;
final BigDecimal EPS = ONE.scaleByPowerOfTen(-32);
final BigDecimal ROOT_TOL = ONE.scaleByPowerOfTen(-15);

final BigDecimal PI = new BigDecimal("3.141592653589793238462643383279502884197");
final BigDecimal LN2 = new BigDecimal("0.693147180559945309417232121458176568076");
final BigDecimal LOG2PI = new BigDecimal("1.837877066409345483560659472811235279723");

//================================================================
// 2. BIGDECIMAL SQUARE ROOT
//================================================================
BigDecimal sqrtBD(BigDecimal x) {
  if(x.signum() < 0) throw new ArithmeticException("Negative square root");
  if(x.signum() == 0) return ZERO;

  int exponent = x.precision() - x.scale();
  BigDecimal guess = ONE.scaleByPowerOfTen(exponent / 2);
  if(guess.signum() == 0) guess = ONE;

  for(int k = 0; k < PREC+15; k++) {
    BigDecimal next = guess.add(x.divide(guess, MC), MC).divide(TWO, MC);
    if(next.compareTo(guess) == 0) {
      guess = next;
      break;
    }
    guess = next;
  }
  return guess.round(MC);
}

//================================================================
// 3. COMPLEX NUMBER
//================================================================
class CX {
  BigDecimal r;
  BigDecimal i;

  CX(BigDecimal a, BigDecimal b) {
    r = a;
    i = b;
  }

  CX add(CX b) {
    return new CX(r.add(b.r, MC), i.add(b.i, MC));
  }

  CX sub(CX b) {
    return new CX(r.subtract(b.r, MC), i.subtract(b.i, MC));
  }

  CX mul(CX b) {
    return new CX(
      r.multiply(b.r, MC).subtract(i.multiply(b.i, MC), MC),
      r.multiply(b.i, MC).add(i.multiply(b.r, MC), MC)
    );
  }

  CX scale(BigDecimal b) {
    return new CX(r.multiply(b, MC), i.multiply(b, MC));
  }

  CX div(CX b) {
    BigDecimal d = b.r.multiply(b.r, MC).add(b.i.multiply(b.i, MC), MC);
    if(d.signum() == 0) throw new ArithmeticException("Complex division by zero");
    return new CX(
      r.multiply(b.r, MC).add(i.multiply(b.i, MC), MC).divide(d, MC),
      i.multiply(b.r, MC).subtract(r.multiply(b.i, MC), MC).divide(d, MC)
    );
  }
}

CX cx(BigDecimal x) {
  return new CX(x, ZERO);
}

//================================================================
// 4. NATURAL LOGARITHM
//================================================================
BigDecimal lnBD(BigDecimal x) {
  if(x.signum() <= 0) throw new ArithmeticException("Log domain error");
  int e = 0;
  BigDecimal upper = new BigDecimal("1.25");
  BigDecimal lower = new BigDecimal("0.8");

  while(x.compareTo(upper) > 0) {
    x = x.divide(TWO, MC);
    e++;
  }
  while(x.compareTo(lower) < 0) {
    x = x.multiply(TWO, MC);
    e--;
  }

  BigDecimal y = x.subtract(ONE, MC).divide(x.add(ONE, MC), MC);
  BigDecimal y2 = y.multiply(y, MC);
  BigDecimal term = y;
  BigDecimal sum = y;

  for(int n = 3; n < 500; n += 2) {
    term = term.multiply(y2, MC);
    BigDecimal add = term.divide(BigDecimal.valueOf(n), MC);
    sum = sum.add(add, MC);
    if(add.abs().compareTo(EPS) < 0) break;
  }
  return sum.multiply(TWO, MC).add(LN2.multiply(BigDecimal.valueOf(e), MC), MC);
}

//================================================================
// 5. TRIGONOMETRY
//================================================================
BigDecimal mod2pi(BigDecimal x) {
  BigDecimal twopi = PI.multiply(TWO, MC);
  BigDecimal q = x.divideToIntegralValue(twopi);
  x = x.subtract(q.multiply(twopi), MC);
  if(x.compareTo(PI) > 0) x = x.subtract(twopi, MC);
  if(x.compareTo(PI.negate()) < 0) x = x.add(twopi, MC);
  return x;
}

BigDecimal sinBD(BigDecimal x) {
  x = mod2pi(x);
  BigDecimal term = x;
  BigDecimal sum = x;
  BigDecimal xx = x.multiply(x, MC).negate();
  for(int n = 1; n < 150; n++) {
    term = term.multiply(xx, MC).divide(BigDecimal.valueOf((2L*n)*(2L*n+1)), MC);
    sum = sum.add(term, MC);
    if(term.abs().compareTo(EPS) < 0) break;
  }
  return sum;
}

BigDecimal cosBD(BigDecimal x) {
  x = mod2pi(x);
  BigDecimal term = ONE;
  BigDecimal sum = ONE;
  BigDecimal xx = x.multiply(x, MC).negate();
  for(int n = 1; n < 150; n++) {
    term = term.multiply(xx, MC).divide(BigDecimal.valueOf((2L*n-1)*(2L*n)), MC);
    sum = sum.add(term, MC);
    if(term.abs().compareTo(EPS) < 0) break;
  }
  return sum;
}

//================================================================
// 6. ARCTANGENT
//================================================================
BigDecimal atanBD(BigDecimal x) {
  if(x.signum() < 0) return atanBD(x.negate()).negate();
  if(x.compareTo(ONE) > 0) return PI.divide(TWO, MC).subtract(atanBD(ONE.divide(x, MC)), MC);
  
  if(x.compareTo(new BigDecimal("0.25")) > 0) {
    BigDecimal y = x.divide(ONE.add(sqrtBD(ONE.add(x.multiply(x, MC))), MC), MC);
    return atanBD(y).multiply(TWO, MC);
  }

  BigDecimal term = x;
  BigDecimal sum = x;
  BigDecimal xx = x.multiply(x, MC).negate();

  for(int n = 3; n < 500; n += 2) {
    term = term.multiply(xx, MC);
    BigDecimal add = term.divide(BigDecimal.valueOf(n), MC);
    sum = sum.add(add, MC);
    if(add.abs().compareTo(EPS) < 0) break;
  }
  return sum;
}

BigDecimal atan2BD(BigDecimal y, BigDecimal x) {
  if(x.signum() > 0) return atanBD(y.divide(x, MC));
  if(x.signum() < 0) {
    if(y.signum() >= 0) return atanBD(y.divide(x, MC)).add(PI, MC);
    return atanBD(y.divide(x, MC)).subtract(PI, MC);
  }
  if(y.signum() > 0) return PI.divide(TWO, MC);
  if(y.signum() < 0) return PI.divide(TWO, MC).negate();
  return ZERO;
}

//================================================================
// 7. COMPLEX LOGARITHM
//================================================================
CX clog(CX z) {
  BigDecimal radius = sqrtBD(z.r.multiply(z.r, MC).add(z.i.multiply(z.i, MC), MC));
  return new CX(lnBD(radius), atan2BD(z.i, z.r));
}

//================================================================
// 8. COMPLEX POWER ON CRITICAL LINE
//================================================================
CX powN(int n, BigDecimal t, int shift) {
  BigDecimal bn = BigDecimal.valueOf(n);
  BigDecimal amplitude = ONE.divide(sqrtBD(bn), MC);
  if(shift != 0) amplitude = amplitude.divide(bn.pow(shift, MC), MC);
  BigDecimal phase = t.multiply(lnBD(bn), MC).negate();
  return new CX(amplitude.multiply(cosBD(phase), MC), amplitude.multiply(sinBD(phase), MC));
}

//================================================================
// 9. RATIONAL NUMBERS
//================================================================
class Rat {
  BigInteger n;
  BigInteger d;

  Rat(long a, long b) {
    this(BigInteger.valueOf(a), BigInteger.valueOf(b));
  }

  Rat(BigInteger a, BigInteger b) {
    if(b.signum() == 0) throw new ArithmeticException("Zero denominator");
    if(b.signum() < 0) {
      a = a.negate();
      b = b.negate();
    }
    BigInteger g = a.gcd(b);
    n = a.divide(g);
    d = b.divide(g);
  }

  Rat add(Rat b) {
    return new Rat(n.multiply(b.d).add(b.n.multiply(d)), d.multiply(b.d));
  }

  Rat sub(Rat b) {
    return new Rat(n.multiply(b.d).subtract(b.n.multiply(d)), d.multiply(b.d));
  }

  Rat mul(Rat b) {
    return new Rat(n.multiply(b.n), d.multiply(b.d));
  }

  BigDecimal bd() {
    return new BigDecimal(n).divide(new BigDecimal(d), MC);
  }
}

//================================================================
// 10. BERNOULLI COEFFICIENTS
//================================================================
BigDecimal[] coeffs;

void initCoeffs() {
  int K = 16;
  Rat[] a = new Rat[2*K+1];
  Rat[] bern = new Rat[2*K+1];

  for(int m = 0; m <= 2*K; m++) {
    a[m] = new Rat(1, m+1);
    for(int j = m; j >= 1; j--) {
      a[j-1] = a[j-1].sub(a[j]);
      a[j-1] = a[j-1].mul(new Rat(j, 1));
    }
    bern[m] = a[0];
  }

  coeffs = new BigDecimal[K];
  BigInteger factorial = BigInteger.ONE;
  for(int k = 1; k <= 2*K; k++) {
    factorial = factorial.multiply(BigInteger.valueOf(k));
    if(k % 2 == 0) {
      coeffs[k/2-1] = bern[k].bd().divide(new BigDecimal(factorial), MC);
    }
  }
}

//================================================================
// 11. RIEMANN ZETA ON CRITICAL LINE
//================================================================
CX zeta(BigDecimal t) {
  int N = Math.max(80, (int)Math.ceil(t.doubleValue()*2.0)+40);
  if(N > 12000) throw new ArithmeticException("Device computation limit");

  CX sum = cx(ZERO);
  for(int n = 1; n < N; n++) {
    sum = sum.add(powN(n, t, 0));
  }

  BigDecimal logN = lnBD(BigDecimal.valueOf(N));
  BigDecimal mag = sqrtBD(BigDecimal.valueOf(N));
  BigDecimal phase = t.multiply(logN, MC).negate();
  CX numerator = new CX(mag.multiply(cosBD(phase), MC), mag.multiply(sinBD(phase), MC));

  sum = sum.add(numerator.div(new CX(new BigDecimal("-0.5"), t)));
  sum = sum.add(powN(N, t, 0).scale(HALF));

  for(int k = 1; k <= coeffs.length; k++) {
    CX rising = cx(ONE);
    for(int j = 0; j < 2*k-1; j++) {
      rising = rising.mul(new CX(HALF.add(BigDecimal.valueOf(j)), t));
    }
    CX term = rising.mul(powN(N, t, 2*k-1)).scale(coeffs[k-1]);
    sum = sum.add(term);
    if(k > 7 && term.r.abs().add(term.i.abs()).compareTo(EPS) < 0) break;
  }
  return sum;
}

//================================================================
// 12. COMPLEX LOG GAMMA
//================================================================
CX logGamma(CX z) {
  CX w = z;
  CX shift = cx(ZERO);
  for(int j = 0; j < 80; j++) {
    shift = shift.add(clog(w));
    w = w.add(cx(ONE));
  }

  CX a = w.sub(cx(HALF)).mul(clog(w)).sub(w).add(cx(LOG2PI.divide(TWO, MC)));
  CX inv = cx(ONE).div(w);
  CX power = inv;

  for(int k = 1; k <= coeffs.length; k++) {
    BigDecimal fac = ONE;
    for(int j = 2; j <= 2*k-2; j++) fac = fac.multiply(BigDecimal.valueOf(j), MC);
    CX term = power.scale(coeffs[k-1].multiply(fac, MC));
    a = a.add(term);
    power = power.mul(inv).mul(inv);
    if(k > 7 && term.r.abs().add(term.i.abs()).compareTo(EPS) < 0) break;
  }
  return a.sub(shift);
}

//================================================================
// 13. HARDY Z FUNCTION
//================================================================
BigDecimal hardy(BigDecimal t) {
  CX lg = logGamma(new CX(new BigDecimal("0.25"), t.divide(TWO, MC)));
  BigDecimal theta = lg.i.subtract(t.multiply(lnBD(PI), MC).divide(TWO, MC), MC);
  CX z = zeta(t);
  return z.r.multiply(cosBD(theta), MC).subtract(z.i.multiply(sinBD(theta), MC), MC);
}

//================================================================
// 14. TRIVIAL ZERO FAMILY
//================================================================
final int TRIVIAL_ZERO_COUNT = 100;
ArrayList<BigDecimal> trivialZeros = new ArrayList<BigDecimal>();

void initializeTrivialZeros() {
  trivialZeros.clear();
  for(int n = 1; n <= TRIVIAL_ZERO_COUNT; n++) {
    BigDecimal root = BigDecimal.valueOf(-2L*n);
    trivialZeros.add(root);
  }
}

//================================================================
// 15. NON-TRIVIAL ROOT SEARCH STATE
//================================================================
final int SEARCHING = 0;
final int REFINING = 1;

int phase = SEARCHING;
boolean running = true;
boolean ready = false;

BigDecimal scanT = new BigDecimal("14");
BigDecimal prevZ = ZERO;
BigDecimal left = ZERO;
BigDecimal right = ZERO;
BigDecimal leftZ = ZERO;
BigDecimal rightZ = ZERO;
BigDecimal midpoint = ZERO;
BigDecimal midpointZ = ZERO;
BigDecimal currentT = ZERO;
BigDecimal currentZ = ZERO;
BigDecimal step = new BigDecimal("0.05");
BigDecimal convergenceWidth = ZERO;
BigDecimal initialLeft = ZERO;
BigDecimal initialRight = ZERO;

int scanCount = 0;
int refineCount = 0;
int estimatedDigits = 0;
String status = "INITIALIZING";
String direction = "NOT DETECTED";

ArrayList<BigDecimal> nonTrivialZeros = new ArrayList<BigDecimal>();

//================================================================
// 16. UI & PANNING STATE
//================================================================
int screenMode = 0; // 0=Dashboard, 1=Complex Z-Plane, 2=Conformal W-Plane

float viewMinIm = -10;
float viewMaxIm = 60;
boolean userPan = false;

//================================================================
// 17. HARDY GRAPH DATA
//================================================================
final int GRAPH_SAMPLES = 25;
BigDecimal[] plotT = new BigDecimal[GRAPH_SAMPLES];
BigDecimal[] plotZ = new BigDecimal[GRAPH_SAMPLES];
boolean plotInitialized = false;
BigDecimal plotMinT = ZERO;
BigDecimal plotMaxT = ZERO;

//================================================================
// 18. FORMATTING
//================================================================
String root15(BigDecimal x) { return x.setScale(15, RoundingMode.HALF_UP).toPlainString(); }
String shortBD(BigDecimal x) { return x.setScale(8, RoundingMode.HALF_UP).toPlainString(); }
String scientific(BigDecimal x) { return x.round(new MathContext(6)).toEngineeringString(); }
String signText(BigDecimal x) {
  if(x.signum() > 0) return "+";
  if(x.signum() < 0) return "-";
  return "0";
}
int signColor(BigDecimal x) {
  if(x.signum() > 0) return color(30, 225, 140);
  if(x.signum() < 0) return color(255, 75, 105);
  return color(255, 220, 70);
}
boolean oppositeSigns(BigDecimal a, BigDecimal b) {
  return a.signum() != 0 && b.signum() != 0 && a.signum() != b.signum();
}

//================================================================
// 19. DECIMAL DIGIT ESTIMATION
//================================================================
int estimateDigits(BigDecimal width) {
  if(width.signum() <= 0) return 100;
  int digits = 0;
  BigDecimal threshold = new BigDecimal("0.1");
  while(digits < 100 && width.compareTo(threshold) < 0) {
    digits++;
    threshold = threshold.divide(TEN, MC);
  }
  return digits;
}

//================================================================
// 20. INITIALIZE HARDY GRAPH
//================================================================
void initializeGraph() {
  plotInitialized = false;
  plotMinT = initialLeft;
  plotMaxT = initialRight;
  BigDecimal span = plotMaxT.subtract(plotMinT, MC);
  for(int i = 0; i < GRAPH_SAMPLES; i++) {
    BigDecimal fraction = BigDecimal.valueOf(i).divide(BigDecimal.valueOf(GRAPH_SAMPLES-1), MC);
    plotT[i] = plotMinT.add(span.multiply(fraction, MC), MC);
    plotZ[i] = hardy(plotT[i]);
  }
  plotInitialized = true;
}

//================================================================
// 21. RESET LABORATORY
//================================================================
void resetLab() {
  nonTrivialZeros.clear();
  scanCount = 0;
  refineCount = 0;
  scanT = new BigDecimal("14");
  currentT = scanT;
  left = ZERO; right = ZERO; leftZ = ZERO; rightZ = ZERO;
  midpoint = ZERO; midpointZ = ZERO;
  convergenceWidth = ZERO;
  phase = SEARCHING;
  running = true;
  ready = false;
  plotInitialized = false;
  userPan = false;
  status = "INITIALIZING";

  try {
    prevZ = hardy(scanT);
    currentZ = prevZ;
    ready = true;
    status = "SEARCHING FOR NON-TRIVIAL ZEROS";
  } catch(Exception ex) {
    running = false;
    status = "ERROR: "+ex.getMessage();
  }
}

//================================================================
// 22. START REFINEMENT
//================================================================
void startRefinement() {
  phase = REFINING;
  initialLeft = left;
  initialRight = right;
  convergenceWidth = right.subtract(left, MC).abs();
  midpoint = left.add(right, MC).divide(TWO, MC);
  midpointZ = ZERO;
  direction = signText(leftZ)+" TO "+signText(rightZ);
  refineCount = 0;
  estimatedDigits = estimateDigits(convergenceWidth);
  status = "NON-TRIVIAL CANDIDATE - BISECTION ACTIVE";
  initializeGraph();
}

//================================================================
// 23. COMPLETE NON-TRIVIAL ROOT
//================================================================
void completeRoot() {
  BigDecimal root;
  if(left.compareTo(right) == 0) root = left;
  else root = left.add(right, MC).divide(TWO, MC);
  
  nonTrivialZeros.add(root);
  currentT = root;
  currentZ = ZERO;

  if(left.compareTo(right) == 0) {
    scanT = root.add(step, MC);
    prevZ = hardy(scanT);
  } else {
    scanT = right;
    prevZ = rightZ;
  }
  
  phase = SEARCHING;
  status = "NON-TRIVIAL CANDIDATE "+nonTrivialZeros.size()+" RECORDED";
}

//================================================================
// 24. SEARCH AND BISECTION
//================================================================
void numericalStep() {
  if(!running || !ready) return;
  try {
    if(phase == SEARCHING) {
      BigDecimal next = scanT.add(step, MC);
      BigDecimal nextZ = hardy(next);
      scanCount++;
      currentT = next;
      currentZ = nextZ;
      if(oppositeSigns(prevZ, nextZ)) {
        left = scanT; right = next; leftZ = prevZ; rightZ = nextZ;
        startRefinement();
      } else {
        scanT = next; prevZ = nextZ;
        status = "SEARCHING FOR SIGN CHANGE";
      }
      return;
    }
    if(phase == REFINING) {
      midpoint = left.add(right, MC).divide(TWO, MC);
      if(midpoint.compareTo(left) == 0 || midpoint.compareTo(right) == 0) {
        status = "PRECISION LIMIT REACHED";
        completeRoot();
        return;
      }
      midpointZ = hardy(midpoint);
      refineCount++;
      currentT = midpoint;
      currentZ = midpointZ;
      
      if(midpointZ.signum() == 0) {
        left = midpoint; right = midpoint; leftZ = ZERO; rightZ = ZERO;
        completeRoot();
        return;
      }
      if(midpointZ.signum() == leftZ.signum()) {
        left = midpoint; leftZ = midpointZ;
      } else {
        right = midpoint; rightZ = midpointZ;
      }
      if(!oppositeSigns(leftZ, rightZ)) throw new ArithmeticException("Bracket lost");
      
      convergenceWidth = right.subtract(left, MC).abs();
      estimatedDigits = estimateDigits(convergenceWidth);
      if(convergenceWidth.compareTo(ROOT_TOL) <= 0 && root15(left).equals(root15(right))) {
        completeRoot();
        return;
      }
      status = "BISECTION STEP "+refineCount;
    }
  } catch(Exception ex) {
    running = false;
    status = "NUMERICAL ERROR: "+ex.getMessage();
  }
}

//================================================================
// 25. BUTTON
//================================================================
void drawButton(String label, float x, float y, float w, float h, int c) {
  fill(c);
  noStroke();
  rect(x, y, w, h, 8);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(12);
  text(label, x+w/2.0f, y+h/2.0f);
  textAlign(LEFT, TOP);
}

//================================================================
// 26. PANEL
//================================================================
void panel(float x, float y, float w, float h, int c) {
  fill(c);
  noStroke();
  rect(x, y, w, h, 10);
}

//================================================================
// 27-32. DASHBOARD PANELS
//================================================================
void drawCriticalStrip(float x, float y, float w, float h) {
  panel(x, y, w, h, color(12, 28, 55));
  fill(255, 220, 90);
  textSize(13);
  text("A. CRITICAL STRIP AND NON-TRIVIAL ZEROS", x+10, y+8);
  
  float gx = x+40, gy = y+42, gw = w-55, gh = h-85;
  noStroke(); fill(18, 42, 72); rect(gx, gy, gw, gh);
  
  // FIXED: Using Java's Math.max instead of Processing's max for doubles
  float tMax = max(40.0f, (float)Math.max(scanT.doubleValue(), currentT.doubleValue())+5.0f);
  if(nonTrivialZeros.size() > 0) tMax = max(tMax, nonTrivialZeros.get(nonTrivialZeros.size()-1).floatValue()+5.0f);

  stroke(65, 105, 145); strokeWeight(1);
  for(int i=0; i<=10; i++) { float xx = gx+gw*i/10.0f; line(xx, gy, xx, gy+gh); }
  for(int i=0; i<=8; i++) { float yy = gy+gh*i/8.0f; line(gx, yy, gx+gw, yy); }
  stroke(255, 100, 110); strokeWeight(2); line(gx, gy, gx, gy+gh); line(gx+gw, gy, gx+gw, gy+gh);
  float criticalX = gx+gw*0.5f;
  stroke(0, 255, 190); strokeWeight(3); line(criticalX, gy, criticalX, gy+gh);
  
  noStroke(); fill(255); textSize(9);
  text("Re(s)=0", gx-10, gy-14); text("Re(s)=0.5", criticalX-28, gy-14); text("Re(s)=1", gx+gw-40, gy-14);
  text("Im(s)", gx-35, gy-30);

  for(int i=0; i<nonTrivialZeros.size(); i++) {
    float yy = gy+gh - nonTrivialZeros.get(i).floatValue()/tMax*gh;
    if(yy >= gy && yy <= gy+gh) {
      fill(255, 220, 70); ellipse(criticalX, yy, 11, 11);
      fill(255); textSize(9); text("N"+(i+1), criticalX+9, yy-5);
    }
  }

  float currentY = constrain(gy+gh - currentT.floatValue()/tMax*gh, gy, gy+gh);
  stroke(255, 120, 50); strokeWeight(2); line(criticalX-9, currentY, criticalX+9, currentY);
  noStroke(); fill(255, 120, 50); ellipse(criticalX, currentY, 8, 8);
}

void drawHardyGraph(float x, float y, float w, float h) {
  panel(x, y, w, h, color(12, 27, 49));
  fill(255, 220, 90); textSize(13); text("B. HARDY Z(t) GRAPH", x+10, y+8);
  float gx = x+38, gy = y+35, gw = w-55, gh = h-65;
  if(!plotInitialized) { fill(180, 210, 240); textSize(11); text("Waiting for sign-change bracket...", gx+5, gy+20); return; }

  double maxAbs = 1e-20;
  for(int i=0; i<GRAPH_SAMPLES; i++) maxAbs = Math.max(maxAbs, Math.abs(plotZ[i].doubleValue()));
  float zeroY = gy+gh/2.0f;
  noStroke(); fill(15, 80, 55, 110); rect(gx, gy, gw, gh/2.0f);
  fill(95, 20, 42, 110); rect(gx, zeroY, gw, gh/2.0f);
  stroke(230); line(gx, zeroY, gx+gw, zeroY);

  for(int i=0; i<GRAPH_SAMPLES-1; i++) {
    float x1 = gx+gw*i/(float)(GRAPH_SAMPLES-1), x2 = gx+gw*(i+1)/(float)(GRAPH_SAMPLES-1);
    float z1 = (float)(plotZ[i].doubleValue()/maxAbs), z2 = (float)(plotZ[i+1].doubleValue()/maxAbs);
    stroke(plotZ[i].signum() >= 0 ? color(30, 230, 140) : color(255, 75, 105)); strokeWeight(2);
    line(x1, zeroY-z1*gh*0.42f, x2, zeroY-z2*gh*0.42f);
  }

  double den = plotMaxT.subtract(plotMinT, MC).doubleValue();
  if(den == 0) return;
  // FIXED: Explicitly specify 0.0 and 1.0 to enforce double precision inside Math.min/Math.max
  double ratio = Math.max(0.0, Math.min(1.0, midpoint.subtract(plotMinT, MC).doubleValue()/den));
  float px = (float)(gx+ratio*gw), pz = constrain((float)(midpointZ.doubleValue()/maxAbs), -1, 1);
  stroke(255, 220, 70); strokeWeight(2); line(px, gy, px, gy+gh);
  noStroke(); fill(255, 220, 70); ellipse(px, zeroY-pz*gh*0.42f, 12, 12);
}

void drawEndpointPanel(float x, float y, float w, float h) {
  panel(x, y, w, h, color(14, 28, 45)); fill(255, 220, 90); textSize(13); text("C. SIGN-CHANGE ENDPOINTS", x+10, y+8);
  float halfW = (w-30)/2.0f;
  panel(x+8, y+34, halfW, h-45, color(12, 55, 42));
  fill(30, 230, 140); textSize(12); text("LEFT", x+18, y+43);
  fill(255); textSize(10); text("tL = "+shortBD(left), x+18, y+70);
  fill(signColor(leftZ)); textSize(25); text(signText(leftZ), x+18, y+93);
  fill(220); textSize(9); text("Z(tL)="+scientific(leftZ), x+18, y+130);

  float rx = x+20+halfW; panel(rx, y+34, halfW, h-45, color(65, 22, 38));
  fill(255, 95, 120); textSize(12); text("RIGHT", rx+10, y+43);
  fill(255); textSize(10); text("tR = "+shortBD(right), rx+10, y+70);
  fill(signColor(rightZ)); textSize(25); text(signText(rightZ), rx+10, y+93);
  fill(220); textSize(9); text("Z(tR)="+scientific(rightZ), rx+10, y+130);
}

void drawConvergencePanel(float x, float y, float w, float h) {
  panel(x, y, w, h, color(18, 29, 54)); fill(255, 220, 90); textSize(13); text("D. BISECTION CONVERGENCE", x+10, y+8);
  fill(180, 215, 245); textSize(10); text("MIDPOINT", x+12, y+34);
  fill(255); textSize(17); text(root15(midpoint), x+12, y+53);
  fill(0, 255, 190); textSize(10); text("Z(m)="+scientific(midpointZ), x+12, y+81);
  fill(255, 220, 90); text("INTERVAL WIDTH", x+12, y+108); fill(255); textSize(12); text(convergenceWidth.toEngineeringString(), x+12, y+128);
  fill(180, 215, 245); textSize(10); text("DECIMAL DIGITS: "+estimatedDigits, x+12, y+169); text("STEPS: "+refineCount, x+12, y+187);
}

void drawTrivialZeroPlot(float x, float y, float w, float h) {
  panel(x, y, w, h, color(35, 20, 48)); fill(255, 220, 90); textSize(13); text("E. TRIVIAL ZEROS", x+10, y+8);
  float gx = x+35, gy = y+42, gw = w-55, gh = h-75;
  fill(20, 32, 60); noStroke(); rect(gx, gy, gw, gh);
  float axisY = gy+gh/2.0f; stroke(220); strokeWeight(2); line(gx, axisY, gx+gw, axisY);

  for(int i=0; i<min(20, trivialZeros.size()); i++) {
    float px = gx+((-trivialZeros.get(i).floatValue())/40.0f)*gw;
    stroke(255, 110, 110); strokeWeight(1); line(px, axisY-8, px, axisY+8);
    noStroke(); fill(255, 110, 110); ellipse(px, axisY, 9, 9);
    fill(255); textSize(8); text("-"+(2*(i+1)), px-7, axisY+12);
  }
}

void drawNonTrivialHistory(float x, float y, float w, float h) {
  panel(x, y, w, h, color(13, 24, 43)); fill(255, 220, 90); textSize(13); text("F. NON-TRIVIAL ZEROS", x+10, y+8);
  fill(180, 215, 245); textSize(10); text("CANDIDATES: "+nonTrivialZeros.size(), x+10, y+30);
  int first = max(0, nonTrivialZeros.size() - max(1, (int)((h-55)/20))); float yy = y+52;
  for(int i=first; i<nonTrivialZeros.size(); i++) {
    fill(30, 225, 140); text("N"+(i+1), x+12, yy);
    fill(255); text("0.5 + "+root15(nonTrivialZeros.get(i))+" i", x+50, yy);
    yy += 20;
  }
}

//================================================================
// 33. MAIN DASHBOARD VIEW (SCREEN 0)
//================================================================
void drawDashboard() {
  background(5, 9, 23);
  fill(100, 215, 255); textSize(18); text("RIEMANN ZETA - DUAL ZERO LABORATORY", 12, 7);
  fill(255, 220, 90); textSize(10); text("TRIVIAL: -2n | NON-TRIVIAL: 0.5 + it | STRIP WIDTH: 1", 12, 31);

  // Updated Navigation Buttons
  drawButton("COMPLEX Z", width-415, 5, 105, 34, color(100, 80, 180));
  drawButton("CONFORMAL W", width-305, 5, 110, 34, color(160, 80, 180));
  drawButton(running ? "STOP" : "RESUME", width-190, 5, 90, 34, running ? color(175, 50, 65) : color(30, 140, 95));
  drawButton("RESTART", width-95, 5, 90, 34, color(35, 100, 165));

  float margin = 10, gap = 8, topY = 48, colW = (width-2*margin-gap)/2.0f, rowH = (height-topY-33-2*gap)/3.0f;
  float x1 = margin, x2 = margin+colW+gap, y1 = topY, y2 = y1+rowH+gap, y3 = y2+rowH+gap;

  drawCriticalStrip(x1, y1, colW, rowH);
  drawHardyGraph(x2, y1, colW, rowH);
  drawEndpointPanel(x1, y2, colW, rowH);
  drawConvergencePanel(x2, y2, colW, rowH);
  drawTrivialZeroPlot(x1, y3, colW, rowH);
  drawNonTrivialHistory(x2, y3, colW, rowH);

  fill(100, 215, 255); textSize(10);
  text("TRIVIAL="+trivialZeros.size()+" | CANDIDATES="+nonTrivialZeros.size()+" | STATUS="+status, 12, height-16);
}

//================================================================
// 34. ACCUMULATED POINTS (COMPLEX Z-PLANE - SCREEN 1)
//================================================================
void drawComplexScreen() {
  background(5, 9, 23);
  fill(100, 215, 255); textSize(18); text("ACCUMULATED ZEROS & QRH BOUNDS - COMPLEX Z-PLANE", 12, 12);
  
  drawButton("BACK", width-115, 5, 100, 34, color(175, 50, 65));
  if(userPan) drawButton("AUTO-TRACK", width-225, 5, 100, 34, color(100, 180, 80));

  float plotX = 60, plotY = 70, plotW = width - 120, plotH = height - 120;

  if (!userPan) {
    float maxT = max(40.0f, currentT.floatValue() + 5.0f);
    if (nonTrivialZeros.size() > 0) maxT = max(maxT, nonTrivialZeros.get(nonTrivialZeros.size()-1).floatValue() + 5.0f);
    viewMaxIm = maxT;
    viewMinIm = max(-10.0f, maxT - 60.0f); 
  }

  float minRe = -30, maxRe = 2;
  float realAxisY = map(0, viewMinIm, viewMaxIm, plotY + plotH, plotY);
  
  clip(plotX, plotY, plotW, plotH);
  
  stroke(60, 80, 110); strokeWeight(1);
  if (realAxisY >= plotY && realAxisY <= plotY + plotH) line(plotX, realAxisY, plotX + plotW, realAxisY);
  float imAxisX = map(0, minRe, maxRe, plotX, plotX + plotW);
  line(imAxisX, plotY, imAxisX, plotY + plotH); 
  
  float critX1 = map(0, minRe, maxRe, plotX, plotX + plotW);
  float critX2 = map(1, minRe, maxRe, plotX, plotX + plotW);
  noStroke(); fill(18, 42, 72, 180); rect(critX1, plotY, critX2 - critX1, plotH);

  float critLineX = map(0.5f, minRe, maxRe, plotX, plotX + plotW);
  stroke(0, 255, 190, 150); strokeWeight(2); line(critLineX, plotY, critLineX, plotY + plotH);

  // QRH Bounds
  float bound78 = map(7.0f/8.0f, minRe, maxRe, plotX, plotX + plotW);
  float bound1112 = map(11.0f/12.0f, minRe, maxRe, plotX, plotX + plotW);
  fill(200, 80, 255, 45); noStroke(); rect(bound78, plotY, bound1112 - bound78, plotH);
  stroke(200, 80, 255, 200); strokeWeight(1.5f);
  line(bound78, plotY, bound78, plotY + plotH); line(bound1112, plotY, bound1112, plotY + plotH);

  float blink = (sin(millis() / 150.0f) + 1.0f) / 2.0f;
  float currentRadius = 6.0f + 8.0f * blink; 

  for (int i = 0; i < trivialZeros.size(); i++) {
    float reVal = trivialZeros.get(i).floatValue();
    float px = map(reVal, minRe, maxRe, plotX, plotX + plotW);
    noStroke(); fill(240, 230, 140, 150 + 105 * blink); ellipse(px, realAxisY, currentRadius, currentRadius);
    if(i % 2 == 0) { fill(200); textSize(9); text(String.format("%.0f", reVal), px - 8, realAxisY + 20); }
  }

  for (int i = 0; i < nonTrivialZeros.size(); i++) {
    float py = map(nonTrivialZeros.get(i).floatValue(), viewMinIm, viewMaxIm, plotY + plotH, plotY);
    noStroke(); fill(255, 100, 80, 150 + 105 * blink); ellipse(critLineX, py, currentRadius, currentRadius);
    fill(255); textSize(10); text("N" + (i+1), critLineX + 12, py - 5);
  }
  
  float currentPy = map(currentT.floatValue(), viewMinIm, viewMaxIm, plotY + plotH, plotY);
  stroke(255, 120, 50); strokeWeight(2); line(critLineX - 10, currentPy, critLineX + 10, currentPy);
  fill(255); textSize(9); text("SEARCHING...", critLineX + 15, currentPy + 10);

  noClip(); 

  fill(255); textSize(10);
  text("Re(s)=0", imAxisX - 15, plotY - 10); text("Re(s)=1/2", critLineX - 25, plotY - 25);
  text("Re(s)=1", critX2 - 10, plotY - 10); text("Real Axis", plotX + plotW - 50, constrain(realAxisY + 15, plotY, plotY+plotH));
  fill(200, 80, 255); text("7/8", bound78 - 10, plotY - 10); text("11/12", bound1112 - 10, plotY - 25);
}

//================================================================
// 35. CONFORMAL MAPPING UTILS (Z to W) W = Z^(1/2)
//================================================================
float[] zToW(float x, float y) {
  float r = sqrt(x*x + y*y);
  float theta = atan2(y, x);
  return new float[] { sqrt(r) * cos(theta/2.0f), sqrt(r) * sin(theta/2.0f) };
}

//================================================================
// 36. CONFORMAL W-PLANE (SCREEN 2)
//================================================================
void drawConformalScreen() {
  background(5, 9, 23);
  fill(100, 215, 255); textSize(18); text("CONFORMAL W-PLANE: Parametric Mapping W = Z^(1/2)", 12, 12);
  
  drawButton("BACK", width-115, 5, 100, 34, color(175, 50, 65));
  if(userPan) drawButton("AUTO-TRACK", width-225, 5, 100, 34, color(100, 180, 80));

  float plotX = 60, plotY = 70, plotW = width - 120, plotH = height - 120;
  float currentT_float = currentT.floatValue();

  if (!userPan) {
    float maxT = max(40.0f, currentT_float + 5.0f);
    if (nonTrivialZeros.size() > 0) maxT = max(maxT, nonTrivialZeros.get(nonTrivialZeros.size()-1).floatValue() + 5.0f);
    viewMaxIm = maxT;
    viewMinIm = max(0.0f, maxT - 60.0f); 
  }

  // Preserve Mathematical Aspect Ratio in W-Plane
  float[] wTop = zToW(0.5f, viewMaxIm);
  float[] wBot = zToW(0.5f, max(0.0f, viewMinIm));

  float vMax = wTop[1] + 1.0f;
  float vMin = wBot[1] - 1.0f;
  if(vMin < -1.0f) vMin = -1.0f; // Keep U-axis origin visible if nearby
  
  float wHeight = vMax - vMin;
  float wWidth = wHeight * (plotW / plotH); // Exact screen ratio scalar
  
  float uMin = -0.5f; 
  float uMax = uMin + wWidth;

  clip(plotX, plotY, plotW, plotH);
  
  // W-Plane Axes
  float originX = map(0, uMin, uMax, plotX, plotX + plotW);
  float originY = map(0, vMin, vMax, plotY + plotH, plotY);
  
  stroke(60, 80, 110); strokeWeight(1);
  if(originY >= plotY && originY <= plotY+plotH) line(plotX, originY, plotX+plotW, originY); // U Axis
  if(originX >= plotX && originX <= plotX+plotW) line(originX, plotY, originX, plotY+plotH); // V Axis
  
  // Parametric Mapping of Critical Strip
  fill(18, 42, 72, 180); noStroke();
  beginShape();
  float stepDraw = max(0.1f, (viewMaxIm - max(0.0f, viewMinIm)) / 100.0f);
  for(float t = max(0.0f, viewMinIm); t <= viewMaxIm; t += stepDraw) {
     float[] w = zToW(1.0f, t);
     vertex(map(w[0], uMin, uMax, plotX, plotX+plotW), map(w[1], vMin, vMax, plotY+plotH, plotY));
  }
  for(float t = viewMaxIm; t >= max(0.0f, viewMinIm); t -= stepDraw) {
     float[] w = zToW(0.0f, t);
     vertex(map(w[0], uMin, uMax, plotX, plotX+plotW), map(w[1], vMin, vMax, plotY+plotH, plotY));
  }
  endShape(CLOSE);
  
  // Parametric Critical Line Hyperbola Re(z)=0.5
  stroke(0, 255, 190, 200); strokeWeight(2); noFill();
  beginShape();
  for(float t = max(0.0f, viewMinIm); t <= viewMaxIm; t += stepDraw) {
     float[] w = zToW(0.5f, t);
     vertex(map(w[0], uMin, uMax, plotX, plotX+plotW), map(w[1], vMin, vMax, plotY+plotH, plotY));
  }
  endShape();
  
  // Blinking points logic
  float blink = (sin(millis() / 150.0f) + 1.0f) / 2.0f;
  float currentRadius = 6.0f + 8.0f * blink;
  
  // Mapped Trivial Zeros (Maps elegantly to the V Imaginary Axis)
  for(int i = 0; i < trivialZeros.size(); i++) {
     float[] w = zToW(trivialZeros.get(i).floatValue(), 0); 
     float px = map(w[0], uMin, uMax, plotX, plotX+plotW);
     float py = map(w[1], vMin, vMax, plotY+plotH, plotY);
     if(py >= plotY && py <= plotY+plotH) {
         noStroke(); fill(240, 230, 140, 150 + 105*blink);
         ellipse(px, py, currentRadius, currentRadius);
     }
  }
  
  // Mapped Non-Trivial Zeros (Blinking on the Hyperbola)
  for (int i = 0; i < nonTrivialZeros.size(); i++) {
    float[] w = zToW(0.5f, nonTrivialZeros.get(i).floatValue());
    float px = map(w[0], uMin, uMax, plotX, plotX+plotW);
    float py = map(w[1], vMin, vMax, plotY+plotH, plotY);
    
    noStroke(); fill(255, 100, 80, 150 + 105 * blink); ellipse(px, py, currentRadius, currentRadius);
    fill(255); textSize(10); text("N" + (i+1), px + 12, py - 5);
  }
  
  // Active searching curve location
  float[] wSearch = zToW(0.5f, currentT_float);
  float sx = map(wSearch[0], uMin, uMax, plotX, plotX+plotW);
  float sy = map(wSearch[1], vMin, vMax, plotY+plotH, plotY);
  stroke(255, 120, 50); strokeWeight(2);
  line(sx-10, sy, sx+10, sy); line(sx, sy-10, sx, sy+10);
  
  noClip();
  
  fill(255); textSize(10);
  text("U Axis (Real)", originX + 15, plotY + plotH - 10);
  text("V Axis (Imaginary)", plotX + 10, originY - 10);
  fill(0, 255, 190); text("Hyperbola: Re(z)=0.5 Mapped", plotX + 10, plotY - 15);
  fill(150, 180, 210); textSize(12);
  text("Critical strip maps to radial parabolic band. Trivial zeros map natively to V-axis.", plotX, plotY + plotH + 20);
}

//================================================================
// 37. SETUP
//================================================================
void setup() {
  orientation(LANDSCAPE);
  fullScreen(P2D);
  textAlign(LEFT, TOP);
  smooth(2);
  initCoeffs();
  initializeTrivialZeros();
  resetLab();
}

//================================================================
// 38. DRAW LOOP (ROUTES ACTIVE SCREENS)
//================================================================
void draw() {
  if (running && ready) numericalStep();

  if (screenMode == 0) drawDashboard();
  else if (screenMode == 1) drawComplexScreen();
  else if (screenMode == 2) drawConformalScreen();
}

//================================================================
// 39. TOUCH DRAGGING & PANNING 
//================================================================
void mouseDragged() {
  if (screenMode == 1 || screenMode == 2) {
    float plotH = height - 120;
    float imUnitsPerPixel = (viewMaxIm - viewMinIm) / plotH;
    float deltaIm = (pmouseY - mouseY) * imUnitsPerPixel;
    
    viewMinIm -= deltaIm;
    viewMaxIm -= deltaIm;
    userPan = true; 
  }
}

//================================================================
// 40. TOUCH CONTROLS (BUTTON ROUTING)
//================================================================
void mousePressed() {
  if(screenMode == 0) {
    // COMPLEX Z
    if(mouseY >= 5 && mouseY <= 45 && mouseX >= width-415 && mouseX <= width-310) {
      screenMode = 1; return;
    }
    // CONFORMAL W
    if(mouseY >= 5 && mouseY <= 45 && mouseX >= width-305 && mouseX <= width-195) {
      screenMode = 2; return;
    }
    // STOP / RESUME
    if(mouseY >= 5 && mouseY <= 45 && mouseX >= width-190 && mouseX <= width-100) {
      running = !running;
      status = running ? "SEARCH RESUMED" : "SEARCH PAUSED";
      return;
    }
    // RESTART
    if(mouseY >= 5 && mouseY <= 45 && mouseX >= width-95 && mouseX <= width-5) {
      initializeTrivialZeros();
      resetLab();
      return;
    }
  } else if(screenMode == 1 || screenMode == 2) {
    // BACK TO DASHBOARD
    if(mouseY >= 5 && mouseY <= 45 && mouseX >= width-120 && mouseX <= width-5) {
      screenMode = 0; return;
    }
    // AUTO-TRACK RE-ENGAGE
    if(userPan && mouseY >= 5 && mouseY <= 45 && mouseX >= width-225 && mouseX <= width-125) {
      userPan = false; return;
    }
  }
}
//================================================================
// 41. END
//================================================================
