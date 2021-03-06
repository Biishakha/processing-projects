/* 
 * COVID-19 Simulator
 * Visualization inspired by this Washington Post article: https://www.washingtonpost.com/graphics/2020/world/corona-simulator/
 * Based on Ira Greenberg's CircleCollision example (https://processing.org/examples/circlecollision.html)
 * Basic logic added by Michelle Dudley.
 * There are some lazy/suspect design decisions I've made that I've marked with TODOs.
 */

// A list of Ball objects representing all the people in the simulation.
ArrayList<Ball> balls =  new ArrayList<Ball>();

// Totals of infected/uninfected/recovered people in the population.
// Stored as separate variables because looping through all the people
// in the list would be very inefficient since we check these numbers
// every frame to update the statistics at the top of the screen.

// TODO: These numbers aren't connected to the initial setup of the
// population (i.e., getIsInfected() doesn't change to match the number
// of infected people if it's changed up here). These should be connected
// in some way.
int infected = 2; // infected person is 0 at first
int uninfected = 200 -  infected; // we want the uninfected person to be total minus infected
int recovered = 0;
int death=0;
int mask = 3;
PImage bg;


// cols stores the columns in the graph at the top of the screen.
ArrayList<Column> cols = new ArrayList<Column>();
// leftCol is the pixel position on screen where the next graph column will go.
// It is initially offset to take into account the words/numbers on the left
// side of the screen.
int leftCol = 110;

// columnCounter counts the number of frames that have passed. It's used in 
// draw() to limit the number of columns that are drawn because drawing once every
// frame makes the graph outgrow the size of the window too quickly.
int columnCounter = 0;

void setup() {
  size(960, 540); // here ive changed the size of the window according to the background size of the picture
  bg = loadImage("knox.jpeg");  // I imported the picture in this program and then used it as the background image. I used knox as the image because I wanted to show social distancing at knox. 
  for (int i = 0; i < 200; i++) {
    // Adds a new Ball that starts at a random x value and a random y value that
    // avoids the graph area at the top of the screen.
    balls.add(new Ball(random(width), random(60, height), 5.0, getIsInfected(i), getIsSocialDistancing(i), getIsWearingMask(i)));
  }
}

// Currently, only the first Ball is returned as infected.
// TODO: Make this variable based on how many people we'd like to be infected
// initially.
State getIsInfected(int i) {
  return i < 5? State.INFECTED : State.UNINFECTED; //here
}


// Currently, about 1 in 5 people are social distancing. The first person
// is set to not be social distancing because it makes the simulation move faster.
// TODO: Update this logic as necessary when getIsInfected() is updated.
boolean getIsSocialDistancing(int i) {
  return floor(random(0, 5)) != 0 && i != 0;
}
boolean getIsWearingMask(int i) {
  return floor(random(0, 2)) != 0 && i != 0; //
}


void draw() {
  
  
  background(bg); //background

  for (Ball b : balls) {
    b.update();
    b.display();
    b.checkBoundaryCollision();
  }

  drawStats();
  
  // Only draw new parts of the graph every 10 frames so that the screen doesn't 
  // fill up too quickly.
  if (columnCounter % 10 == 0) {
    cols.add(new Column());
    leftCol += 1;
  }
  // Update the number of frames that have happened.
  columnCounter++;
  for (Column c : cols) {
    c.display();
  }
  
  // Check for collisions between every ball and every other ball.
  for (int i = 0; i < balls.size(); i++) { //<>//
    for (int j = i + 1; j < balls.size(); j++) {
      balls.get(i).checkCollision(balls.get(j));
    }
  }
}

// Draw all the words to the left of the graph, as well as their accompanying numbers.
void drawStats() {
  fill(204);
  rect(0, 0, width, 60);
  fill(51);
  text("healthy: " + uninfected, 10, 30);
  text("sick: " + infected, 10, 40);
  text("recovered: " + recovered, 10, 20);
  text("death: " + death, 10, 10);
  text("lightblue are people wearing mask and practicing sanitization", 10,50);


}



enum State {
  UNINFECTED,
  INFECTED,
  DEATH, //here
  RECOVERED,
  MASK
  
  
}


/* Ball represents an individual person in the simulation. The person has
 * an infection State, and can be social distancing.
 * TODO: infectedDays as it's implemented right now is inelegant. Might be
 * better to move it to a State class instead.
 */
class Ball {
  PVector position;
  PVector velocity;

  float radius, m;
  State state;
  // If infected, tracks how many days a person has been infected.
  // After 900 days/frames, the person recovers.
  int infectedDays;
  //AFTER 1015 days/frames, the person becomes severe and dies.
  int maxInfectedDays;
  boolean isSocialDistancing;
  boolean isWearingMask;

  Ball(float x, float y, float r_, State state, boolean isSocialDistancing, boolean isWearingMask) {
    position = new PVector(x, y);
    radius = r_;
    // People who are social distancing should start and stay at 0 velocity,
    // so they need to be heavy to avoid moving due to collisions.
    if (isSocialDistancing) {
      m = 1000;
      velocity = new PVector(0, 0);
    } else {
      m = radius*.1;
      velocity = PVector.random2D();
    }
    this.state = state;
    infectedDays = 0;
    this.isSocialDistancing = isSocialDistancing;
    this.isWearingMask = isWearingMask;
  }

  void update() {
    position.add(velocity);
    if (state == State.INFECTED) {
      infectedDays++;
    }
    // If the person has been infected for 900 days, they should be moved into
    // the recovered state.
    if ((infectedDays >= 900) && (isSocialDistancing == true)) {
      state = State.RECOVERED;
      infectedDays = 0;
      infected--;
      //death++;
      recovered++;
    }
    // if a person has been infected for more than 1000 days they ;
    if((infectedDays >= 900) && (isSocialDistancing == false)){
      state= State.DEATH;
      infectedDays=0;
      infected--;
      death++;
    }
    if(isWearingMask) {
     state = State.MASK; 
    }
  
  }

  void checkBoundaryCollision() {
    if (position.x > width-radius) {
      position.x = width-radius;
      velocity.x *= -1;
    } else if (position.x < radius) {
      position.x = radius;
      velocity.x *= -1;
    } else if (position.y > height-radius) {
      position.y = height-radius;
      velocity.y *= -1;
    } else if (position.y < radius + 60) {
      position.y = radius + 60;
      velocity.y *= -1;
    }
  }
  
  // Update state of this ball and the ball with which it collided. Also update
  // the global variables that count the number of infected people.
  // (possible) TODO: Separate out the part that deals with global variables from
  // code that deals with the individual Balls specifically.
  void checkAndSetInfection(Ball other) {
    if (other.state == State.INFECTED  && this.state == State.UNINFECTED) {
      this.state = State.INFECTED;
      infected++;
      uninfected--;
    }
    if (this.state == State.INFECTED && other.state == State.UNINFECTED) {
      other.state = State.INFECTED;
      infected++;
      uninfected--;
    }
    if (this.state == State.INFECTED && other.state == State.MASK) {
      other.state = State.MASK;
    }
  }

  void checkCollision(Ball other) {

    // Get distances between the balls components
    PVector distanceVect = PVector.sub(other.position, position);

    // Calculate magnitude of the vector separating the balls
    float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    float minDistance = radius + other.radius;

    if (distanceVectMag < minDistance) {
      checkAndSetInfection(other);
      
      float distanceCorrection = (minDistance-distanceVectMag)/2.0; //<>//
      PVector d = distanceVect.copy();
      PVector correctionVector = d.normalize().mult(distanceCorrection);
      other.position.add(correctionVector);
      position.sub(correctionVector);

      // get angle of distanceVect
      float theta  = distanceVect.heading();
      // precalculate trig values
      float sine = sin(theta);
      float cosine = cos(theta);

      /* bTemp will hold rotated ball positions. You 
       just need to worry about bTemp[1] position*/
      PVector[] bTemp = {
        new PVector(), new PVector()
      };

      /* this ball's position is relative to the other
       so you can use the vector between them (bVect) as the 
       reference point in the rotation expressions.
       bTemp[0].position.x and bTemp[0].position.y will initialize
       automatically to 0.0, which is what you want
       since b[1] will rotate around b[0] */
      bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
      bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

      // rotate Temporary velocities
      PVector[] vTemp = {
        new PVector(), new PVector()
      };

      vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
      vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
      vTemp[1].x  = cosine * other.velocity.x + sine * other.velocity.y;
      vTemp[1].y  = cosine * other.velocity.y - sine * other.velocity.x;

      /* Now that velocities are rotated, you can use 1D
       conservation of momentum equations to calculate 
       the final velocity along the x-axis. */
      PVector[] vFinal = {  
        new PVector(), new PVector()
      };

      // final rotated velocity for b[0]
      vFinal[0].x = ((m - other.m) * vTemp[0].x + 2 * other.m * vTemp[1].x) / (m + other.m);
      vFinal[0].y = vTemp[0].y;

      // final rotated velocity for b[0]
      vFinal[1].x = ((other.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + other.m);
      vFinal[1].y = vTemp[1].y;

      // hack to avoid clumping
      bTemp[0].x += vFinal[0].x;
      bTemp[1].x += vFinal[1].x;

      /* Rotate ball positions and velocities back
       Reverse signs in trig expressions to rotate 
       in the opposite direction */
      // rotate balls
      PVector[] bFinal = { 
        new PVector(), new PVector()
      };

      bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
      bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
      bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
      bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

      // !!! IMPORTANT !!!
      // The following lines must be commented out–otherwise there's a clumping issue with large numbers
       //<>//
      // update balls to screen position
      // other.position.x = position.x + bFinal[1].x;
      // other.position.y = position.y + bFinal[1].y;

      // position.add(bFinal[0]);

      // update velocities
      velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
      velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
      other.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
      other.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
    }
  }

  void display() {
    noStroke();
    if (state == State.INFECTED) {
      // Infected people are drawn in red.
      fill(252, 3, 40);
    } else if (state == State.UNINFECTED) {
      // Uninfected people are drawn in gray.
      fill(204);
    } else if (state == State.DEATH){ 
      fill(0, 0, 255);
    } else if (state == State.MASK){
      fill(0, 200, 255);
    } 
    else {
      // Recovered people are drawn in green
      fill(135, 224, 145);
    }
    
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}

/* Column represents a column of the graph that exists above the ball simulation.
 * It calculates the sizes of the rectangles that make up a column based on the ratio
 * between each of the "types" of people (infected, uninfected, recovered and death).
 */
class Column {
  int colWidth = 1;
  int top = 10;
  int totalHeight = 30;
  int numActors = balls.size();
  int infected_, uninfected_, recovered_, death_, mask_; //<>//
  // position vars for top/recovered
  PVector position1Top, position1Bottom;
  // position vars for middle/uninfected
  PVector position2Top, position2Bottom;
  // position vars for bottom/infected
  PVector position3Top, position3Bottom;
  
  Column () {
    this.infected_ = infected;
    this.uninfected_ = uninfected;
    this.recovered_ = recovered;
    this.death_= death;
    
    float recoveredShare = recovered_ * 1.0 / numActors * totalHeight;
    float infectedShare = infected_ * 1.0 / numActors * totalHeight;
    float uninfectedShare = uninfected_ * 1.0 / numActors * totalHeight;
    float deathShare = death_ * 1.0 / numActors * totalHeight;
    
    position1Top = new PVector(leftCol, top);
    position1Bottom = new PVector(leftCol + colWidth, top + recoveredShare);
    position2Top = new PVector(leftCol, top + recoveredShare);
    position2Bottom = new PVector(leftCol + colWidth, top + recoveredShare + uninfectedShare);
    position3Top = new PVector(leftCol, top + recoveredShare + uninfectedShare);
    position3Bottom = new PVector(leftCol + colWidth, top + recoveredShare + infectedShare + uninfectedShare + deathShare);
  }
  
  void display() {
    noStroke();
    rectMode(CORNERS);
    // Draw recovered rectangle.
    fill(135, 224, 145);
    rect(position1Top.x, position1Top.y, position1Bottom.x, position1Bottom.y);
    // Draw uninfected rectangle.
    fill(180);
    rect(position2Top.x, position2Top.y, position2Bottom.x, position2Bottom.y); //<>//
    // Draw infected rectangle.
    fill(252, 3, 40);
    rect(position3Top.x, position3Top.y, position3Bottom.x, position3Bottom.y);
  }
}
