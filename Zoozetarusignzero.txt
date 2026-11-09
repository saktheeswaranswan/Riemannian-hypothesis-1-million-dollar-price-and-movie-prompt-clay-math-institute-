
/*
================================================================
 RIEMANN ZETA - SINGLE SCREEN ROOT DISCOVERY LABORATORY
 ANDROID APDE - PROCESSING JAVA MODE
================================================================

 ONE PERMANENT DASHBOARD - NO SCREEN SWITCHING

 DISPLAY:
  1. Continuous zero search
  2. Complete Riemann critical strip
  3. Critical line Re(s) = 0.5
  4. Magnified Hardy Z(t) graph
  5. Actual left and right endpoint values
  6. Positive/negative sign indicators
  7. Moving bisection midpoint
  8. Live interval width
  9. 10^-15 interval target
 10. Fifteen-decimal root display
 11. Accumulated root history
 12. Automatic search for the next zero
 13. STOP / RESUME / RESTART

 NUMERICAL EXPERIMENT.
 NOT A MATHEMATICAL CERTIFICATE.
================================================================
*/

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.math.BigInteger;
import java.util.ArrayList;

//================================================================
// 1. PRECISION
//================================================================

final int PREC = 40;

final MathContext MC =
  new MathContext(PREC, RoundingMode.HALF_EVEN);

final BigDecimal ZERO = BigDecimal.ZERO;
final BigDecimal ONE = BigDecimal.ONE;
final BigDecimal TWO = new BigDecimal("2");
final BigDecimal HALF = new BigDecimal("0.5");
final BigDecimal TEN = BigDecimal.TEN;

final BigDecimal EPS =
  ONE.scaleByPowerOfTen(-32);

// Requested interval tolerance: 10^-15.
final BigDecimal ROOT_TOL =
  ONE.scaleByPowerOfTen(-15);

final BigDecimal PI = new BigDecimal(
  "3.141592653589793238462643383279502884197"
);

final BigDecimal LN2 = new BigDecimal(
  "0.693147180559945309417232121458176568076"
);

final BigDecimal LOG2PI = new BigDecimal(
  "1.837877066409345483560659472811235279723"
);

//================================================================
// 2. BIGDECIMAL SQUARE ROOT
//================================================================

BigDecimal sqrtBD(BigDecimal x) {

  if(x.signum() < 0)
    throw new ArithmeticException("Negative square root");

  if(x.signum() == 0)
    return ZERO;

  int exponent = x.precision() - x.scale();

  BigDecimal guess =
    ONE.scaleByPowerOfTen(exponent / 2);

  if(guess.signum() == 0)
    guess = ONE;

  for(int k = 0; k < PREC + 12; k++) {

    BigDecimal next = guess.add(
      x.divide(guess, MC), MC
    ).divide(TWO, MC);

    if(next.equals(guess))
      break;

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
    return new CX(
      r.add(b.r, MC),
      i.add(b.i, MC)
    );
  }

  CX sub(CX b) {
    return new CX(
      r.subtract(b.r, MC),
      i.subtract(b.i, MC)
    );
  }

  CX mul(CX b) {
    return new CX(
      r.multiply(b.r, MC)
       .subtract(i.multiply(b.i, MC), MC),

      r.multiply(b.i, MC)
       .add(i.multiply(b.r, MC), MC)
    );
  }

  CX scale(BigDecimal b) {
    return new CX(
      r.multiply(b, MC),
      i.multiply(b, MC)
    );
  }

  CX div(CX b) {

    BigDecimal d =
      b.r.multiply(b.r, MC)
      .add(b.i.multiply(b.i, MC), MC);

    if(d.signum() == 0)
      throw new ArithmeticException("Complex division by zero");

    return new CX(
      r.multiply(b.r, MC)
       .add(i.multiply(b.i, MC), MC)
       .divide(d, MC),

      i.multiply(b.r, MC)
       .subtract(r.multiply(b.i, MC), MC)
       .divide(d, MC)
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

  if(x.signum() <= 0)
    throw new ArithmeticException("Log domain error");

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

  BigDecimal y = x.subtract(ONE, MC)
    .divide(x.add(ONE, MC), MC);

  BigDecimal y2 = y.multiply(y, MC);

  BigDecimal term = y;
  BigDecimal sum = y;

  for(int n = 3; n < 500; n += 2) {

    term = term.multiply(y2, MC);

    BigDecimal add = term.divide(
      BigDecimal.valueOf(n), MC
    );

    sum = sum.add(add, MC);

    if(add.abs().compareTo(EPS) < 0)
      break;
  }

  return sum.multiply(TWO, MC)
    .add(
      LN2.multiply(BigDecimal.valueOf(e), MC),
      MC
    );
}

//================================================================
// 5. TRIGONOMETRY
//================================================================

BigDecimal mod2pi(BigDecimal x) {

  BigDecimal twopi = PI.multiply(TWO, MC);

  BigDecimal q = x.divideToIntegralValue(twopi);

  x = x.subtract(q.multiply(twopi), MC);

  if(x.compareTo(PI) > 0)
    x = x.subtract(twopi, MC);

  if(x.compareTo(PI.negate()) < 0)
    x = x.add(twopi, MC);

  return x;
}

BigDecimal sinBD(BigDecimal x) {

  x = mod2pi(x);

  BigDecimal term = x;
  BigDecimal sum = x;

  BigDecimal xx = x.multiply(x, MC).negate();

  for(int n = 1; n < 150; n++) {

    term = term.multiply(xx, MC)
      .divide(
        BigDecimal.valueOf((2L*n)*(2L*n+1)),
        MC
      );

    sum = sum.add(term, MC);

    if(term.abs().compareTo(EPS) < 0)
      break;
  }

  return sum;
}

BigDecimal cosBD(BigDecimal x) {

  x = mod2pi(x);

  BigDecimal term = ONE;
  BigDecimal sum = ONE;

  BigDecimal xx = x.multiply(x, MC).negate();

  for(int n = 1; n < 150; n++) {

    term = term.multiply(xx, MC)
      .divide(
        BigDecimal.valueOf((2L*n-1)*(2L*n)),
        MC
      );

    sum = sum.add(term, MC);

    if(term.abs().compareTo(EPS) < 0)
      break;
  }

  return sum;
}

//================================================================
// 6. ARCTANGENT
//================================================================

BigDecimal atanBD(BigDecimal x) {

  if(x.signum() < 0)
    return atanBD(x.negate()).negate();

  if(x.compareTo(ONE) > 0) {

    return PI.divide(TWO, MC)
      .subtract(
        atanBD(ONE.divide(x, MC)),
        MC
      );
  }

  if(x.compareTo(new BigDecimal("0.25")) > 0) {

    BigDecimal y = x.divide(
      ONE.add(
        sqrtBD(ONE.add(x.multiply(x, MC))),
        MC
      ),
      MC
    );

    return atanBD(y).multiply(TWO, MC);
  }

  BigDecimal term = x;
  BigDecimal sum = x;

  BigDecimal xx = x.multiply(x, MC).negate();

  for(int n = 3; n < 500; n += 2) {

    term = term.multiply(xx, MC);

    BigDecimal add = term.divide(
      BigDecimal.valueOf(n), MC
    );

    sum = sum.add(add, MC);

    if(add.abs().compareTo(EPS) < 0)
      break;
  }

  return sum;
}

BigDecimal atan2BD(BigDecimal y, BigDecimal x) {

  if(x.signum() > 0)
    return atanBD(y.divide(x, MC));

  if(x.signum() < 0) {

    if(y.signum() >= 0)
      return atanBD(y.divide(x, MC)).add(PI, MC);

    return atanBD(y.divide(x, MC)).subtract(PI, MC);
  }

  if(y.signum() > 0)
    return PI.divide(TWO, MC);

  if(y.signum() < 0)
    return PI.divide(TWO, MC).negate();

  return ZERO;
}

//================================================================
// 7. COMPLEX LOGARITHM
//================================================================

CX clog(CX z) {

  BigDecimal radius = sqrtBD(
    z.r.multiply(z.r, MC)
    .add(z.i.multiply(z.i, MC), MC)
  );

  return new CX(
    lnBD(radius),
    atan2BD(z.i, z.r)
  );
}

//================================================================
// 8. COMPLEX POWER
//================================================================

CX powN(int n, BigDecimal t, int shift) {

  BigDecimal bn = BigDecimal.valueOf(n);

  BigDecimal amplitude =
    ONE.divide(sqrtBD(bn), MC);

  if(shift != 0) {
    amplitude = amplitude.divide(
      bn.pow(shift, MC),
      MC
    );
  }

  BigDecimal phase =
    t.multiply(lnBD(bn), MC).negate();

  return new CX(
    amplitude.multiply(cosBD(phase), MC),
    amplitude.multiply(sinBD(phase), MC)
  );
}

//================================================================
// 9. RATIONAL NUMBERS
//================================================================

class Rat {

  BigInteger n;
  BigInteger d;

  Rat(long a, long b) {
    this(
      BigInteger.valueOf(a),
      BigInteger.valueOf(b)
    );
  }

  Rat(BigInteger a, BigInteger b) {

    if(b.signum() == 0)
      throw new ArithmeticException("Zero denominator");

    if(b.signum() < 0) {
      a = a.negate();
      b = b.negate();
    }

    BigInteger g = a.gcd(b);

    n = a.divide(g);
    d = b.divide(g);
  }

  Rat add(Rat b) {
    return new Rat(
      n.multiply(b.d).add(b.n.multiply(d)),
      d.multiply(b.d)
    );
  }

  Rat sub(Rat b) {
    return new Rat(
      n.multiply(b.d).subtract(b.n.multiply(d)),
      d.multiply(b.d)
    );
  }

  Rat mul(Rat b) {
    return new Rat(
      n.multiply(b.n),
      d.multiply(b.d)
    );
  }

  BigDecimal bd() {
    return new BigDecimal(n).divide(
      new BigDecimal(d), MC
    );
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

    factorial = factorial.multiply(
      BigInteger.valueOf(k)
    );

    if(k % 2 == 0) {

      coeffs[k/2-1] = bern[k].bd()
        .divide(
          new BigDecimal(factorial),
          MC
        );
    }
  }
}

//================================================================
// 11. RIEMANN ZETA - EULER MACLAURIN
//================================================================

CX zeta(BigDecimal t) {

  int N = Math.max(
    80,
    (int)Math.ceil(t.doubleValue()*2.0)+40
  );

  if(N > 12000)
    throw new ArithmeticException("Device computation limit");

  CX sum = cx(ZERO);

  for(int n = 1; n < N; n++) {
    sum = sum.add(powN(n, t, 0));
  }

  BigDecimal logN =
    lnBD(BigDecimal.valueOf(N));

  BigDecimal mag =
    sqrtBD(BigDecimal.valueOf(N));

  BigDecimal phase =
    t.multiply(logN, MC).negate();

  CX numerator = new CX(
    mag.multiply(cosBD(phase), MC),
    mag.multiply(sinBD(phase), MC)
  );

  sum = sum.add(
    numerator.div(
      new CX(new BigDecimal("-0.5"), t)
    )
  );

  sum = sum.add(
    powN(N, t, 0).scale(HALF)
  );

  CX rising = cx(ONE);

  CX s = new CX(HALF, t);

  for(int k = 1; k <= coeffs.length; k++) {

    if(k == 1) {

      rising = s;

    } else {

      rising = rising.mul(
        new CX(
          HALF.add(BigDecimal.valueOf(2*k-3)),
          t
        )
      );

      rising = rising.mul(
        new CX(
          HALF.add(BigDecimal.valueOf(2*k-2)),
          t
        )
      );
    }

    CX term = rising.mul(
      powN(N, t, 2*k-1)
    ).scale(coeffs[k-1]);

    sum = sum.add(term);

    if(k > 7 &&
       term.r.abs().add(term.i.abs()).compareTo(EPS) < 0) {
      break;
    }
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

  CX a = w.sub(cx(HALF))
    .mul(clog(w))
    .sub(w)
    .add(cx(LOG2PI.divide(TWO, MC)));

  CX inv = cx(ONE).div(w);
  CX power = inv;

  for(int k = 1; k <= coeffs.length; k++) {

    BigDecimal fac = ONE;

    for(int j = 2; j <= 2*k-2; j++) {
      fac = fac.multiply(
        BigDecimal.valueOf(j), MC
      );
    }

    CX term = power.scale(
      coeffs[k-1].multiply(fac, MC)
    );

    a = a.add(term);

    power = power.mul(inv).mul(inv);

    if(k > 7 &&
       term.r.abs().add(term.i.abs()).compareTo(EPS) < 0) {
      break;
    }
  }

  return a.sub(shift);
}

//================================================================
// 13. HARDY Z FUNCTION
//================================================================

BigDecimal hardy(BigDecimal t) {

  CX lg = logGamma(
    new CX(
      new BigDecimal("0.25"),
      t.divide(TWO, MC)
    )
  );

  BigDecimal theta = lg.i.subtract(
    t.multiply(lnBD(PI), MC).divide(TWO, MC),
    MC
  );

  CX z = zeta(t);

  return z.r.multiply(cosBD(theta), MC)
    .subtract(z.i.multiply(sinBD(theta), MC), MC);
}

//================================================================
// 14. ROOT SEARCH STATE
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

// All discovered roots remain visible in history.

ArrayList<BigDecimal> roots =
  new ArrayList<BigDecimal>();

//================================================================
// 15. GRAPH DATA
//================================================================

final int GRAPH_SAMPLES = 25;

BigDecimal[] plotT =
  new BigDecimal[GRAPH_SAMPLES];

BigDecimal[] plotZ =
  new BigDecimal[GRAPH_SAMPLES];

boolean plotInitialized = false;

BigDecimal plotMinT = ZERO;
BigDecimal plotMaxT = ZERO;

//================================================================
// 16. FORMATTING
//================================================================

String root15(BigDecimal x) {

  return x.setScale(
    15,
    RoundingMode.HALF_UP
  ).toPlainString();
}

String shortBD(BigDecimal x) {

  return x.setScale(
    8,
    RoundingMode.HALF_UP
  ).toPlainString();
}

String scientific(BigDecimal x) {

  return x.round(new MathContext(6))
    .toEngineeringString();
}

String signText(BigDecimal x) {

  if(x.signum() > 0) return "+";
  if(x.signum() < 0) return "-";

  return "0";
}

int signColor(BigDecimal x) {

  if(x.signum() > 0)
    return color(30, 225, 140);

  if(x.signum() < 0)
    return color(255, 75, 105);

  return color(255, 220, 70);
}

boolean oppositeSigns(BigDecimal a, BigDecimal b) {

  return a.signum() != 0 &&
         b.signum() != 0 &&
         a.signum() != b.signum();
}

//================================================================
// 17. DECIMAL CONVERGENCE
//================================================================

int estimateDigits(BigDecimal width) {

  if(width.signum() <= 0)
    return 100;

  int digits = 0;

  BigDecimal threshold =
    new BigDecimal("0.1");

  while(
    digits < 100 &&
    width.compareTo(threshold) < 0
  ) {

    digits++;

    threshold = threshold.divide(TEN, MC);
  }

  return digits;
}

//================================================================
// 18. GRAPH INITIALIZATION
//================================================================

void initializeGraph() {

  plotInitialized = false;

  plotMinT = initialLeft;
  plotMaxT = initialRight;

  BigDecimal span =
    plotMaxT.subtract(plotMinT, MC);

  for(int i = 0; i < GRAPH_SAMPLES; i++) {

    BigDecimal fraction =
      BigDecimal.valueOf(i).divide(
        BigDecimal.valueOf(GRAPH_SAMPLES-1),
        MC
      );

    plotT[i] = plotMinT.add(
      span.multiply(fraction, MC),
      MC
    );

    plotZ[i] = hardy(plotT[i]);
  }

  plotInitialized = true;
}

//================================================================
// 19. RESET LABORATORY
//================================================================

void resetLab() {

  roots.clear();

  scanCount = 0;
  refineCount = 0;

  scanT = new BigDecimal("14");

  currentT = scanT;

  phase = SEARCHING;

  running = true;
  ready = false;

  plotInitialized = false;

  status = "INITIALIZING";

  try {

    prevZ = hardy(scanT);

    currentZ = prevZ;

    ready = true;

    status = "SEARCHING FOR FIRST ZERO";

  } catch(Exception ex) {

    running = false;

    status = "ERROR: "+ex.getMessage();
  }
}

//================================================================
// 20. START REFINEMENT WITHOUT CHANGING THE SCREEN
//================================================================

void startRefinement() {

  phase = REFINING;

  initialLeft = left;
  initialRight = right;

  convergenceWidth =
    right.subtract(left, MC).abs();

  midpoint = left.add(right, MC)
    .divide(TWO, MC);

  midpointZ = ZERO;

  direction =
    signText(leftZ)+" TO "+signText(rightZ);

  refineCount = 0;

  estimatedDigits =
    estimateDigits(convergenceWidth);

  status = "ROOT TRAPPED - BISECTION ACTIVE";

  // The graph is initialized for this bracket.
  // The dashboard itself does not change.

  initializeGraph();
}

//================================================================
// 21. COMPLETE ROOT AND CONTINUE SEARCH
//================================================================

void completeRoot() {

  BigDecimal root;

  if(left.compareTo(right) == 0) {
    root = left;
  } else {
    root = left.add(right, MC)
      .divide(TWO, MC);
  }

  roots.add(root);

  currentT = root;

  currentZ = ZERO;

  // Continue beyond the right endpoint.
  // This prevents rediscovering the same bracket.

  if(left.compareTo(right) == 0) {

    scanT = root.add(step, MC);
    prevZ = hardy(scanT);

  } else {

    scanT = right;
    prevZ = rightZ;
  }

  phase = SEARCHING;

  status =
    "ZERO "+roots.size()+" ADDED TO ROOT HISTORY";

  // Keep the latest graph visible until
  // the next zero is trapped.
}

//================================================================
// 22. ONE SEARCH OR BISECTION STEP
//================================================================

void numericalStep() {

  if(!running || !ready)
    return;

  try {

    // ------------------------------------------------------------
    // SEARCH FOR A SIGN CHANGE
    // ------------------------------------------------------------

    if(phase == SEARCHING) {

      BigDecimal next =
        scanT.add(step, MC);

      BigDecimal nextZ = hardy(next);

      scanCount++;

      currentT = next;
      currentZ = nextZ;

      if(oppositeSigns(prevZ, nextZ)) {

        left = scanT;
        right = next;

        leftZ = prevZ;
        rightZ = nextZ;

        startRefinement();

      } else {

        scanT = next;
        prevZ = nextZ;

        status = "SEARCHING - NO BRACKET YET";
      }

      return;
    }

    // ------------------------------------------------------------
    // ROOT REFINEMENT
    // ------------------------------------------------------------

    if(phase == REFINING) {

      midpoint = left.add(right, MC)
        .divide(TWO, MC);

      // BigDecimal precision limit.

      if(
        midpoint.compareTo(left) == 0 ||
        midpoint.compareTo(right) == 0
      ) {

        completeRoot();
        return;
      }

      midpointZ = hardy(midpoint);

      refineCount++;

      currentT = midpoint;
      currentZ = midpointZ;

      // Exact numerical zero.

      if(midpointZ.signum() == 0) {

        left = midpoint;
        right = midpoint;

        leftZ = ZERO;
        rightZ = ZERO;

        completeRoot();
        return;
      }

      // Retain the half interval whose endpoints
      // have opposite signs.

      if(midpointZ.signum() == leftZ.signum()) {

        left = midpoint;
        leftZ = midpointZ;

      } else {

        right = midpoint;
        rightZ = midpointZ;
      }

      if(!oppositeSigns(leftZ, rightZ)) {

        throw new ArithmeticException(
          "Opposite-sign bracket lost"
        );
      }

      convergenceWidth =
        right.subtract(left, MC).abs();

      estimatedDigits =
        estimateDigits(convergenceWidth);

      // Stop only when:
      // 1. Interval width <= 10^-15.
      // 2. Both endpoints round to the same
      //    15-decimal number.

      if(
        convergenceWidth.compareTo(ROOT_TOL) <= 0 &&
        root15(left).equals(root15(right))
      ) {

        completeRoot();
        return;
      }

      status =
        "BISECTION STEP "+refineCount;
    }

  } catch(Exception ex) {

    running = false;

    status = "NUMERICAL ERROR: "+ex.getMessage();
  }
}

//================================================================
// 23. BUTTON
//================================================================

void drawButton(
  String label,
  float x,
  float y,
  float w,
  float h,
  int c
) {

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
// 24. PANEL
//================================================================

void panel(
  float x,
  float y,
  float w,
  float h,
  int c
) {

  fill(c);
  noStroke();

  rect(x, y, w, h, 10);
}

//================================================================
// 25. CRITICAL STRIP PANEL
//================================================================

void drawCriticalStrip(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(12, 28, 55));

  fill(255, 220, 90);
  textSize(13);

  text("A. RIEMANN CRITICAL STRIP", x+10, y+8);

  float gx = x+35;
  float gy = y+35;
  float gw = w-50;
  float gh = h-65;

  fill(25, 65, 105);
  noStroke();

  rect(gx, gy, gw, gh);

  // Real-part grid.

  for(int i = 0; i <= 10; i++) {

    float xx = gx+gw*i/10.0f;

    stroke(65, 105, 145);

    line(xx, gy, xx, gy+gh);
  }

  // Critical line.

  float criticalX = gx+gw*0.5f;

  stroke(0, 255, 190);
  strokeWeight(4);

  line(criticalX, gy, criticalX, gy+gh);

  strokeWeight(1);

  fill(0, 255, 190);
  noStroke();

  textSize(9);

  text("Re(s)=0.5", criticalX+5, gy+4);

  fill(230);

  text("0", gx-12, gy+gh+7);
  text("0.5", criticalX-10, gy+gh+7);
  text("1", gx+gw-5, gy+gh+7);

  fill(190, 215, 240);

  text("0 < Re(s) < 1", gx+5, gy+gh+22);

  if(!plotInitialized)
    return;

  double t0 = plotMinT.doubleValue();
  double t1 = plotMaxT.doubleValue();

  if(t1 <= t0)
    return;

  float yl = (float)(
    gy+gh-
    ((left.doubleValue()-t0)/(t1-t0))*gh
  );

  float yr = (float)(
    gy+gh-
    ((right.doubleValue()-t0)/(t1-t0))*gh
  );

  float ym = (float)(
    gy+gh-
    ((midpoint.doubleValue()-t0)/(t1-t0))*gh
  );

  stroke(255, 220, 80);
  strokeWeight(6);

  line(criticalX, yl, criticalX, yr);

  strokeWeight(1);

  noStroke();

  fill(30, 230, 140);
  ellipse(criticalX, yl, 11, 11);

  fill(255, 75, 105);
  ellipse(criticalX, yr, 11, 11);

  fill(255, 220, 70);
  ellipse(criticalX, ym, 13, 13);
}

//================================================================
// 26. MAGNIFIED HARDY Z GRAPH
//================================================================

void drawHardyGraph(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(12, 27, 49));

  fill(255, 220, 90);
  textSize(13);

  text("B. MAGNIFIED HARDY Z(t) GRAPH", x+10, y+8);

  float gx = x+38;
  float gy = y+35;
  float gw = w-55;
  float gh = h-65;

  if(!plotInitialized)
    return;

  double maxAbs = 1e-20;

  for(int i = 0; i < GRAPH_SAMPLES; i++) {

    maxAbs = Math.max(
      maxAbs,
      Math.abs(plotZ[i].doubleValue())
    );
  }

  float zeroY = gy+gh/2.0f;

  // Positive and negative graph areas.

  noStroke();

  fill(15, 80, 55, 110);
  rect(gx, gy, gw, gh/2.0f);

  fill(95, 20, 42, 110);
  rect(gx, zeroY, gw, gh/2.0f);

  // Zero line.

  stroke(230);

  line(gx, zeroY, gx+gw, zeroY);

  // Graph samples.

  for(int i = 0; i < GRAPH_SAMPLES-1; i++) {

    float x1 = gx+
      gw*i/(float)(GRAPH_SAMPLES-1);

    float x2 = gx+
      gw*(i+1)/(float)(GRAPH_SAMPLES-1);

    float z1 = (float)(
      plotZ[i].doubleValue()/maxAbs
    );

    float z2 = (float)(
      plotZ[i+1].doubleValue()/maxAbs
    );

    float yy1 = zeroY-z1*gh*0.42f;
    float yy2 = zeroY-z2*gh*0.42f;

    stroke(
      plotZ[i].signum() >= 0
      ? color(30, 230, 140)
      : color(255, 75, 105)
    );

    strokeWeight(2);

    line(x1, yy1, x2, yy2);
  }

  strokeWeight(1);

  // Current midpoint.

  double denominator =
    plotMaxT.subtract(plotMinT, MC).doubleValue();

  if(denominator == 0)
    return;

  double ratio =
    midpoint.subtract(plotMinT, MC).doubleValue()
    / denominator;

  ratio = Math.max(0.0, Math.min(1.0, ratio));

  float px = (float)(gx+ratio*gw);

  float pz = (float)(
    midpointZ.doubleValue()/maxAbs
  );

  pz = (float)Math.max(-1.0, Math.min(1.0, pz));

  float py = (float)(
    zeroY-pz*gh*0.42f
  );

  // Midpoint line.

  stroke(255, 220, 70);
  strokeWeight(2);

  line(px, gy, px, gy+gh);

  strokeWeight(1);
  noStroke();

  fill(255, 220, 70);

  ellipse(px, py, 12, 12);

  fill(255);
  textSize(10);

  text("Z(t)=0", gx+5, zeroY-16);

  text("t LEFT", gx, gy+gh+7);

  text("t RIGHT", gx+gw-45, gy+gh+7);

  text(
    "MIDPOINT: "+shortBD(midpoint),
    gx+5, gy+gh+21
  );
}

//================================================================
// 27. LEFT AND RIGHT ENDPOINT PANEL
//================================================================

void drawEndpointPanel(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(14, 28, 45));

  fill(255, 220, 90);
  textSize(13);

  text("C. SIGN-CHANGE ENDPOINTS", x+10, y+8);

  float halfW = (w-30)/2.0f;

  // Left endpoint.

  panel(
    x+8, y+34,
    halfW, h-45,
    color(12, 55, 42)
  );

  fill(30, 230, 140);
  textSize(13);

  text("LEFT ENDPOINT", x+18, y+43);

  fill(255);
  textSize(11);

  text("tL = "+shortBD(left), x+18, y+70);

  fill(signColor(leftZ));
  textSize(27);

  text(signText(leftZ), x+18, y+93);

  fill(220);

  textSize(10);

  text(
    "Z(tL) = "+scientific(leftZ),
    x+18, y+130
  );

  // Right endpoint.

  float rx = x+20+halfW;

  panel(
    rx, y+34,
    halfW, h-45,
    color(65, 22, 38)
  );

  fill(255, 95, 120);
  textSize(13);

  text("RIGHT ENDPOINT", rx+10, y+43);

  fill(255);
  textSize(11);

  text(
    "tR = "+shortBD(right),
    rx+10, y+70
  );

  fill(signColor(rightZ));
  textSize(27);

  text(signText(rightZ), rx+10, y+93);

  fill(220);
  textSize(10);

  text(
    "Z(tR) = "+scientific(rightZ),
    rx+10, y+130
  );
}

//================================================================
// 28. MIDPOINT AND CONVERGENCE PANEL
//================================================================

void drawConvergencePanel(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(18, 29, 54));

  fill(255, 220, 90);
  textSize(13);

  text("D. LIVE ROOT CONVERGENCE", x+10, y+8);

  fill(180, 215, 245);
  textSize(10);

  text("CURRENT MIDPOINT", x+12, y+34);

  fill(255);
  textSize(20);

  text(
    root15(midpoint),
    x+12, y+53
  );

  fill(0, 255, 190);
  textSize(11);

  text(
    "Z(midpoint) = "+scientific(midpointZ),
    x+12, y+83
  );

  fill(255, 220, 90);

  text("INTERVAL WIDTH", x+12, y+111);

  fill(255);
  textSize(13);

  text(
    convergenceWidth.toEngineeringString(),
    x+12, y+131
  );

  fill(180, 215, 245);
  textSize(10);

  text(
    "TARGET WIDTH: 1.0E-15",
    x+12, y+157
  );

  text(
    "ESTIMATED DECIMAL DIGITS: "+estimatedDigits,
    x+12, y+176
  );

  text(
    "BISECTION STEPS: "+refineCount,
    x+12, y+195
  );

  fill(
    oppositeSigns(leftZ, rightZ)
    ? color(30, 230, 140)
    : color(255, 80, 100)
  );

  textSize(11);

  text(
    oppositeSigns(leftZ, rightZ)
    ? "OPPOSITE SIGNS CONFIRMED"
    : "BRACKET NOT CONFIRMED",
    x+12, y+220
  );

  fill(255, 220, 90);

  text(
    "DIRECTION: "+direction,
    x+12, y+240
  );
}

//================================================================
// 29. ROOT HISTORY PANEL
//================================================================

void drawRootHistory(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(13, 24, 43));

  fill(255, 220, 90);
  textSize(13);

  text("E. DISCOVERED ZEROS - 15 DECIMAL PLACES", x+10, y+8);

  fill(180, 215, 245);
  textSize(10);

  text(
    "ROOT COUNT: "+roots.size(),
    x+10, y+30
  );

  int maxRows = 7;

  int first = Math.max(
    0,
    roots.size()-maxRows
  );

  float yy = y+52;

  for(int i = first; i < roots.size(); i++) {

    fill(30, 225, 140);
    textSize(10);

    text(
      "ZERO "+(i+1),
      x+12, yy
    );

    fill(255);
    textSize(12);

    text(
      root15(roots.get(i)),
      x+90, yy
    );

    yy += 24;
  }

  if(roots.size() == 0) {

    fill(160, 190, 220);
    textSize(11);

    text(
      "Waiting for the first detected zero...",
      x+12, yy
    );
  }
}

//================================================================
// 30. SEARCH STATUS PANEL
//================================================================

void drawSearchStatus(
  float x,
  float y,
  float w,
  float h
) {

  panel(x, y, w, h, color(10, 25, 42));

  fill(100, 215, 255);
  textSize(13);

  text("F. CONTINUOUS SEARCH STATUS", x+10, y+8);

  fill(255);
  textSize(11);

  text(
    "CURRENT t: "+shortBD(currentT),
    x+12, y+35
  );

  text(
    "HARDY Z(t): "+scientific(currentZ),
    x+12, y+57
  );

  text(
    "SCAN COUNT: "+scanCount,
    x+12, y+79
  );

  text(
    "ROOTS FOUND: "+roots.size(),
    x+12, y+101
  );

  fill(
    running
    ? color(30, 230, 140)
    : color(255, 190, 80)
  );

  text(
    "STATUS: "+status,
    x+12, y+126
  );
}

//================================================================
// 31. COMPLETE PERMANENT DASHBOARD
//================================================================

void drawDashboard() {

  background(5, 9, 23);

  // --------------------------------------------------------------
  // HEADER
  // --------------------------------------------------------------

  fill(100, 215, 255);
  textSize(19);

  text(
    "RIEMANN ZETA - ROOT DISCOVERY LABORATORY",
    12, 8
  );

  fill(255, 220, 90);
  textSize(10);

  text(
    "CRITICAL LINE: Re(s)=1/2 | ROOT TARGET: 10^-15",
    12, 34
  );

  drawButton(
    running ? "STOP" : "RESUME",
    width-220, 8, 95, 34,
    running
      ? color(175, 50, 65)
      : color(30, 140, 95)
  );

  drawButton(
    "RESTART",
    width-115, 8, 100, 34,
    color(35, 100, 165)
  );

  // --------------------------------------------------------------
  // DASHBOARD GRID
  // --------------------------------------------------------------

  float margin = 10;
  float gap = 8;

  float topY = 53;

  float usableH = height-topY-10;

  float colW = (width-2*margin-gap)/2.0f;

  float rowH = (usableH-gap)/2.0f;

  float x1 = margin;
  float x2 = margin+colW+gap;

  float y1 = topY;
  float y2 = topY+rowH+gap;

  // A. Critical strip.

  drawCriticalStrip(
    x1, y1,
    colW, rowH
  );

  // B. Hardy Z graph.

  drawHardyGraph(
    x2, y1,
    colW, rowH
  );

  // C. Endpoint signs.

  drawEndpointPanel(
    x1, y2,
    colW, rowH*0.55f
  );

  // D. Convergence.

  drawConvergencePanel(
    x2, y2,
    colW, rowH*0.55f
  );

  // E. Root history.

  float historyY = y2+rowH*0.55f+gap;

  drawRootHistory(
    x1, historyY,
    colW, rowH*0.45f-gap
  );

  // F. Search status.

  drawSearchStatus(
    x2, historyY,
    colW, rowH*0.45f-gap
  );
}

//================================================================
// 32. SETUP
//================================================================

void setup() {

  orientation(LANDSCAPE);

  fullScreen(P2D);

  textAlign(LEFT, TOP);

  initCoeffs();

  resetLab();
}

//================================================================
// 33. DRAW - ALWAYS THE SAME DASHBOARD
//================================================================

void draw() {

  // Render every panel on the same canvas.

  drawDashboard();

  // Run one numerical operation after drawing.

  if(running && ready) {
    numericalStep();
  }
}

//================================================================
// 34. TOUCH CONTROLS
//================================================================

void mousePressed() {

  // STOP / RESUME.

  if(
    mouseY >= 5 &&
    mouseY <= 50 &&
    mouseX >= width-225 &&
    mouseX <= width-125
  ) {

    running = !running;

    status = running
      ? "SEARCH RESUMED"
      : "SEARCH PAUSED";

    return;
  }

  // RESTART.

  if(
    mouseY >= 5 &&
    mouseY <= 50 &&
    mouseX >= width-120 &&
    mouseX <= width-5
  ) {

    resetLab();

    return;
  }
}
