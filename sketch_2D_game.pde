
// 2D Game (Processing / Java)
// Enemies move toward a Goal.
// - Click NORMAL enemies to remove them.
// - Clicking a BAD enemy ends the game (penalty).
// Game ends when too many enemies reach the goal.
// Demonstrates: 2+ classes, ArrayList, collisions, inheritance, (light polymorphism)

ArrayList<Enemy> enemies;
Goal goal;

int reachedGoal = 0;
int maxReached = 5;      // game over threshold
int startEnemies = 8;    // start with 5+ (and a bit more challenge)
boolean gameOver = false;

void setup() {
  size(900, 600);

  // Goal placed safely inside boundaries (not touching edges)
  goal = new Goal(width * 0.7, height * 0.5, 40);

  enemies = new ArrayList<Enemy>();

  // Spawn a mix of Enemy and BadEnemy
  for (int i = 0; i < startEnemies; i++) {
    enemies.add(makeRandomEnemy());
  }
}

void draw() {
  background(25);

  // Draw goal
  goal.display();

 
  fill(255);
  textSize(16);
  text("Reached goal: " + reachedGoal + " / " + maxReached, 20, 30);
  text("Enemies left: " + enemies.size(), 20, 55);
  text("Click normal enemies to remove. Avoid clicking purple enemies.", 20, 80);

  // Stop updating game when over
  if (gameOver) {
    textSize(48);
    fill(255, 80, 80);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width/2, height/2);
    textAlign(LEFT, BASELINE);
    return;
  }

  // Update enemies (iterate backwards so removals are safe)
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);

    e.moveToward(goal.x, goal.y);
    e.display();

    // Enemy-goal collision
    if (goal.collidesWith(e)) {
      reachedGoal++;
      enemies.remove(i);

      // Spawn a new one to keep pressure on
      enemies.add(makeRandomEnemy());
    }
  }

  // End condition
  if (reachedGoal >= maxReached) {
    gameOver = true;
  }
}

void mousePressed() {
  if (gameOver) return;

  // Mouse-enemy collision: click to interact
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);

    if (e.isClicked(mouseX, mouseY)) {

      // Penalty: clicking a BadEnemy ends the game
      if (e instanceof BadEnemy) {
        println("Clicked a BAD enemy. Game over!");
        gameOver = true;
      } else {
        enemies.remove(i);
        println("Enemy removed!");
      }

      break; // only one interaction per click
    }
  }
}

// Helper: spawn a random enemy type
Enemy makeRandomEnemy() {
  float x = random(width);
  float y = random(height);
  float r = 18;

  // 75% normal enemies, 25% bad enemies
  if (random(1) < 0.75) {
    return new Enemy(x, y, r, 1.2);
  } else {
    return new BadEnemy(x, y, r, 1.35);
  }
}


// Classes


class Goal {
  float x, y;
  float r;

  Goal(float x, float y, float r) {
    this.x = x;
    this.y = y;
    this.r = r;
  }

  void display() {
    noStroke();
    fill(80, 200, 120);
    ellipse(x, y, r*2, r*2);

    fill(0, 80);
    ellipse(x, y, r*1.2, r*1.2);
  }

  // Boolean collision: goal vs enemy
  boolean collidesWith(Enemy e) {
    return dist(x, y, e.x, e.y) < (r + e.r);
  }
}

class Enemy {
  float x, y;
  float r;
  float speed;

  Enemy(float x, float y, float r, float speed) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.speed = speed;
  }

  void moveToward(float tx, float ty) {
    float dx = tx - x;
    float dy = ty - y;
    float d = sqrt(dx*dx + dy*dy);

    if (d > 0.0001) {
      x += (dx / d) * speed;
      y += (dy / d) * speed;
    }
  }

  void display() {
    noStroke();
    fill(230, 120, 90);
    ellipse(x, y, r*2, r*2);

    // small "eye" so it looks like it's moving with intent
    fill(0);
    ellipse(x + 4, y - 3, r*0.25, r*0.25);
  }

  // Boolean collision: mouse click vs enemy
  boolean isClicked(float mx, float my) {
    return dist(mx, my, x, y) < r;
  }
}

// 2nd enemy type (different class) using INHERITANCE
class BadEnemy extends Enemy {

  BadEnemy(float x, float y, float r, float speed) {
    super(x, y, r, speed); // call Enemy constructor
  }

  // Override display so it looks different
  void display() {
    noStroke();
    fill(160, 60, 220); // purple = dangerous
    ellipse(x, y, r*2, r*2);

    // "danger mark"
    fill(0);
    triangle(x, y - r*0.6, x - r*0.4, y + r*0.4, x + r*0.4, y + r*0.4);
  }
}
