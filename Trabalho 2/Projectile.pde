class Projectile {
    private PVector position;
    private PVector velocity;
    private Enemy target;
    private int damage;
    private float speed;
    private boolean hit;
    private Tower tower;
    private PVector predictedTargetPosition;
    private float timeToTarget;
    
    Projectile(PVector startPos, Enemy target, int damage) {
        this.position = startPos.copy();
        this.target = target;
        this.damage = damage;
        this.speed = 300;
        this.hit = false;
        
        calculatePredictedTrajectory();
    }
    
    private void calculatePredictedTrajectory() {
        PVector currentTargetPos = target.getPosition();
        PVector targetVelocity = calculateTargetVelocity();
        
        float distance = position.dist(currentTargetPos);
        timeToTarget = distance / speed;
        
        predictedTargetPosition = new PVector(
            currentTargetPos.x + targetVelocity.x * timeToTarget,
            currentTargetPos.y + targetVelocity.y * timeToTarget
        );
        
        PVector direction = PVector.sub(predictedTargetPosition, position);
        direction.normalize();
        velocity = PVector.mult(direction, speed);
    }
    
    private PVector calculateTargetVelocity() {
        if (target.getPath().size() <= 1) {
            return new PVector(0, 0);
        }
        
        PVector currentGridPos = target.getGridPosition();
        int pathIndex = target.getPathIndex();
        
        if (pathIndex < target.getPath().size() - 1) {
            PVector nextGridPos = target.getPath().get(pathIndex + 1);
            PVector currentScreenPos = new PVector(
                currentGridPos.x * CELL_SIZE + CELL_SIZE/2,
                currentGridPos.y * CELL_SIZE + CELL_SIZE/2
            );
            PVector nextScreenPos = new PVector(
                nextGridPos.x * CELL_SIZE + CELL_SIZE/2,
                nextGridPos.y * CELL_SIZE + CELL_SIZE/2
            );
            
            PVector direction = PVector.sub(nextScreenPos, currentScreenPos);
            direction.normalize();
            
            float enemySpeed = target.getSpeed() * CELL_SIZE / target.getMoveDelay();
            return PVector.mult(direction, enemySpeed);
        }
        
        return new PVector(0, 0);
    }
    
    void update() {
        if (target != null && !target.isDead()) {
            position.add(PVector.mult(velocity, 0.016f * gameSpeed));
            
            float distanceToTarget = position.dist(target.getPosition());
            float distanceToPredicted = position.dist(predictedTargetPosition);
            
            if (distanceToTarget < 15 || distanceToPredicted < 15) {
                hit = true;
            }
        } else {
            hit = true;
        }
    }
    
    boolean hasHitTarget() {
        return hit;
    }
    
    boolean isOutOfBounds() {
        return position.x < 0 || position.x > width || 
               position.y < 0 || position.y > height;
    }
    
    boolean hits(Enemy enemy) {
        return position.dist(enemy.getPosition()) < 15;
    }
    
    void display() {
        fill(255, 255, 0);
        stroke(255, 200, 0);
        
        ellipse(position.x, position.y, 6, 6);
        
        if (target != null && !target.isDead()) {
            displayPredictionLine();
        }
    }
    
    private void displayPredictionLine() {
        stroke(255, 255, 0, 100);
        strokeWeight(1);
        line(position.x, position.y, predictedTargetPosition.x, predictedTargetPosition.y);
        
        fill(255, 255, 0, 50);
        noStroke();
        ellipse(predictedTargetPosition.x, predictedTargetPosition.y, 8, 8);
    }
    
    int getDamage() {
        return damage;
    }
    
    void setTower(Tower tower) {
        this.tower = tower;
    }
    
    Tower getTower() {
        return tower;
    }
}
