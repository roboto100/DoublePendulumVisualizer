class pendulum {

  // Declare global variables that are used throughout script.
  float g = 9.8;
  float step;

  float l1;
  float l2;
  float m1;
  float m2;
  float theta1;
  float theta2;

  float theta1_dd;
  float theta2_dd;

  // These values could be overwritten if you wanted your pendulums to have initial velocity
  float theta1_d = 0;
  float theta2_d = 0;

  float x1 = 0;
  float y1 = 0;
  float x2 = 0;
  float y2 = 0;

  // Constructor, saves input values. Doesn't do anything else.
  pendulum(float theta1_, float theta2_, float l1_, float l2_, float m1_, float m2_, float step_) {

    theta1 = theta1_;
    theta2 = theta2_;

    l1 = l1_;
    l2 = l2_;

    m1 = m1_;
    m2 = m2_;

    step = step_;
  }

  // Call to take a single step using Eulers method.
  // Specify the stepSize incase we're at an exception where we need to take a smaller step
  // This might happen if we want to move 1 second into the future using step sizes of 0.3. Our last step would need to be for 0.1.
  void stepSingle(float stepSize) {
    // Get second derivative of θ1 and θ2
    theta1_dd = get_theta1_dd();
    theta2_dd = get_theta2_dd();

    // Use Euler's method to calculate first derivatives of θ1 and θ2
    theta1_d += stepSize* theta1_dd;
    theta2_d += stepSize* theta2_dd;

    // Use Euler's method again to calculate θ1 and θ2
    theta1 += stepSize* theta1_d;
    theta2 += stepSize* theta2_d;

    // Calculate the (x,y) coordinates of the pendulums
    x1 = l1*sin(theta1);
    y1 = l1*cos(theta1);
    x2 = x1 + l2*sin(theta2);
    y2 = y1 + l2*cos(theta2);

    // Don't worry about different sized windows. Scale all lengths by 100; assuming a window size of 600x600
    float scaleDist = 200;
    x1 = 300 + map(x1, -l1-l2, l1+l2, -scaleDist, scaleDist);
    x2 = 300 + map(x2, -l1-l2, l1+l2, -scaleDist, scaleDist);
    y1 = 300 + map(y1, -l1-l2, l1+l2, -scaleDist, scaleDist);
    y2 = 300 + map(y2, -l1-l2, l1+l2, -scaleDist, scaleDist);
  }

  // Call this to run multiple steps. This should run each pendulum for the same time, regardless of step size.
  void stepMulti() {

    // Imagine we want to step 1 second into the future, with stepsize of 0.3
    // First, we take 3 steps of 0.3, then we're left with 0.1 sitting on the end. What do we do with that time?
    // One option is just to take a step of 0.1 at the end to catch up. That is what this code does.

    // Because we're running this function once every frame, and the framrate should be 30; we should take a step of 1/30 seconds
    // Note we don't use frameRate here, because doing so would change the simulation depending on what framerate we actually ran at.
    // As is, the speed will change, but the coordinates should stay consistent.
    float simulationTime = (0.033333);
    int validSteps = floor(simulationTime/step);

    // Do all the steps we can do, given the preset step size
    for (int i=0; i<validSteps; i++) {
      stepSingle(step);
    }

    // If there's any small amount left over, take a step of that size
    if (simulationTime%step!=0) {
      stepSingle(simulationTime%step);
    }
  }

  void stepToTime(float time) {
    // Simulate the pendulum to the specified time
    float simulationTime = time;
    int validSteps = floor(simulationTime/step);

    for (int i=0; i<validSteps; i++) {
      stepSingle(step);
    }

    // If there's any small amount left over, take a step of that size
    if (simulationTime%step!=0) {
      stepSingle(simulationTime%step);
    }
  }

  void display() {
    // Display the two balls and the rods connecting them.
    ellipse(x1, y1, 25, 25);
    ellipse(x2, y2, 25, 25);
    stroke(255);
    line(width/2, height/2, x1, y1);
    line(x1, y1, x2, y2);
  }

  // A function that just returns the value of θ1''
  float get_theta1_dd() {
    float p1 = -g*(2*m1+m2)*sin(theta1);
    float p2 = -m2*g*sin(theta1-2*theta2);
    float p3 = -2*sin(theta1-theta2)*m2*(pow(theta2_d, 2)*l2+pow(theta1_d, 2)*l1*cos(theta1-theta2));
    float p4 = 2*m1+m2-m2*cos(2*theta1-2*theta2);
    return (p1+p2+p3)/(l1*p4);
  }

  // A function that just returns the value of θ2''
  float get_theta2_dd() {
    float p1 = 2*sin(theta1-theta2);
    float p2 = pow(theta1_d, 2)*l1*(m1+m2);
    float p3 = g*(m1+m2)*cos(theta1);
    float p4 = pow(theta2_d, 2)*l2*m2*cos(theta1-theta2);
    float p5 = 2*m1+m2-m2*cos(2*theta1-2*theta2);
    return p1*(p2+p3+p4)/(l2*p5);
  }

  // Set's the colour to a value depending on where the second pendulum is. Returns a boolean describing if this was successful
  boolean setColour() {
    // Get the pendulum position from -2 to 2
    float px = map(x2, 100, 500, -2, 2);
    float py = map(y2, 100, 500, 2, -2);
    // Get the angle of the pendulum
    float angle = atan2(py, px);
    // Make sure this angle is valid
    if (Float.isNaN(angle)) {
      return false;
    }
    // Map this angle to a value we can use for colour
    angle = map(angle, -PI, PI, 0, 255);
    // Calculate the distance the pendulum is from the center, and scale for use with colour
    float distance = map(dist(px, py, 0, 0), 0, 2, 0, 255);
    // Apply the colour and return true to say we've been sucessful
    stroke(angle, distance, 255);
    return true;
  }
}
