void setup() { //<>//
  // Setup the screen
  size(600, 600);
  background(0);
  frameRate(30);
  // Change to Hue Saturation Brightness Mode for colour
  colorMode(HSB);

  // Add some text to the top left corner
  float time = t*0.033333;
  text("Time: "+nf(time, 1, 3), 25, 25);
}

// Set up the pendulum we'll be using
pendulum pendulum1;

int t = 1;


// Where we start the circle
int x = 100;
int y = 100;

// Use some global variables here. This should speed up the calculations slightly
float xPosition = 0;
float yPosition = 0;

void draw() {

  // Repeat the following 500 times (to speed up the drawing process)
  for (int i = 0; i<500; i++) {
    // Calculate where the pixel is in relation to a circle
    float useX = map(x, 100, 500, -2, 2);
    float useY = map(y, 100, 500, 2, -2);

    // Make sure the point is inside our good circle
    if (pow(useX, 2)+pow(useY, 2)<4) {
      // Calculate the angle to the first pendulum
      float angle1_temp = angle1(useX, useY);
      // Calculate the angle to the second pendulum
      float angle2_temp = angle2(useX, useY);

      // Make sure both angles are valid
      if (!Float.isNaN(angle1_temp) & !Float.isNaN(angle2_temp)) {

        // Create a pendulum at the angles specified.
        pendulum1 = new pendulum(angle1_temp, angle2_temp, 1, 1, 1, 1, 0.001);

        // Figure out how long to simulate this pendulum for
        float time = t*0.033333;

        // Simulate the pendulum for that time
        pendulum1.stepToTime(time);
        // Try to get the colour, and add a point to our canvas if we're successful
        if (pendulum1.setColour()) {
          point(x, y);
        }
      }
    }


    // Move the x position we're testing up by 1
    x ++;
    // Wrap over if we move too far right
    if (x>=500) {
      y ++;
      x = 100;
      // If y=300 (half way point), we get a strange line. Skip over this point
      if (y==300) {
        y+=1;
      }
    }
    // If we hit the bottom of the circle
    if (y>=500) {
      // Reset the y coordinate (x coordinate should already be set to 0
      y = 100;
      // Save the image
      // change the 0 to however long you want to simulate for
      if (t<30*0) {
        save("Pendulum"+str(t)+".png");
      }
      // Increase how long we simulate for
      t++;
      // Reset canvas and draw new time on top left corner
      background(0);
      float time = t*0.033333;
      text("Time: "+nf(time, 1, 3), 25, 25);
    }
  }
}

float angle1(float myX, float myY) {
  // returns the angle to the first pendulum

  // Calculate the x and y position of the first pendulum
  xPosition = xPos(myX, myY);
  yPosition = yPos(myX, myY, xPosition);

  return atan2(yPosition, xPosition)+PI/2;
}

float angle2(float myX, float myY) {
  // Assumes angle1 has been called just prior.
  // This function relies on xPosition and yPosition being accurate (recently calculated)

  return atan2(myY-yPosition, myX-xPosition)+PI/2;
}

float xPos(float x1, float y1) {
  // Takes the x and y positions of the second pendulum. Returns the x position of the first pendulum
  float p1 = -pow(y1, 2)*(pow(x1, 4)+2*pow(x1, 2)*(pow(y1, 2)-2)+pow(y1, 2)*(pow(y1, 2)-4));
  if (y1>0) {
    return (pow(x1, 3)+sqrt(p1)+x1*pow(y1, 2))/(2*(pow(x1, 2)+pow(y1, 2)));
  }
  return (pow(x1, 3)-sqrt(p1)+x1*pow(y1, 2))/(2*(pow(x1, 2)+pow(y1, 2)));
}

float yPos(float x1, float y1, float xPosition) {
  // Takes the x and y positions of the second pendulum, as well as the x position of the first pendulum. Returns the y position of the first pendulum
  return (pow(x1, 2)+pow(y1, 2)-2*x1*xPosition)/(2*y1);
}
