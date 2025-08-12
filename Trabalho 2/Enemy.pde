class Enemy {
    private PVector position;
    private PVector gridPosition;
    private List<PVector> path;
    private int pathIndex;
    private int health;
    private int maxHealth;
    private float speed;
    private float moveTimer;
    private float moveDelay;
    private EnemyType type;
    private float wallDamageTimer;
    private float wallDamageDelay;
    
        Enemy(EnemyType type, PVector spawnPosition) {
        this.type = type;
        this.position = new PVector(spawnPosition.x * CELL_SIZE + CELL_SIZE/2, 
                                    spawnPosition.y * CELL_SIZE + CELL_SIZE/2);
        this.gridPosition = spawnPosition.copy();
        this.path = new ArrayList<>();
        this.pathIndex = 0;
        
        int waveNumber = gameState.getCurrentWave();
        float healthMultiplier = 1.0f + (waveNumber - 1) * 0.5f;
        
        switch (type) {
            case FAST:
                this.maxHealth = (int)(4 * healthMultiplier);
                this.speed = 1.8f;
                this.moveDelay = 0.4f;
                break;
            case STRONG:
                this.maxHealth = (int)(12 * healthMultiplier);
                this.speed = 0.6f;
                this.moveDelay = 1.0f;
                break;
            case EXPLODER:
                this.maxHealth = (int)(8 * healthMultiplier);
                this.speed = 0.7f;
                this.moveDelay = 0.8f;
                break;
            case TANK:
                this.maxHealth = (int)(25 * healthMultiplier);
                this.speed = 0.4f;
                this.moveDelay = 1.2f;
                break;
            default:
                this.maxHealth = (int)(6 * healthMultiplier);
                this.speed = 1.0f;
                this.moveDelay = 0.5f;
                break;
        }
        
        this.health = maxHealth;
        this.moveTimer = 0;
        this.wallDamageTimer = 0;
        this.wallDamageDelay = 2.0f;
    }
    
    void update() {
        moveTimer += speed * 0.016f * gameSpeed;
        wallDamageTimer += 0.016f * gameSpeed;
        
        if (moveTimer >= moveDelay && pathIndex < path.size() - 1) {
            moveToNextPathPoint();
            moveTimer = 0;
        }
        
        checkWallDamage();
    }
    
    private void checkWallDamage() {
        if (wallDamageTimer >= wallDamageDelay) {
            PVector currentPos = getGridPosition();
            if (gameGrid.isWallAt((int)currentPos.x, (int)currentPos.y)) {
                gameGrid.damageWall((int)currentPos.x, (int)currentPos.y);
            }
            wallDamageTimer = 0;
        }
    }
    
    private void moveToNextPathPoint() {
        pathIndex++;
        PVector nextGridPos = path.get(pathIndex);
        gridPosition = nextGridPos.copy();
        position = new PVector(nextGridPos.x * CELL_SIZE + CELL_SIZE/2, 
                              nextGridPos.y * CELL_SIZE + CELL_SIZE/2);
    }
    
    void setPath(List<PVector> newPath) {
        this.path = new ArrayList<>(newPath);
        this.pathIndex = 0;
    }
    
    void takeDamage(int damage) {
        health -= damage;
    }
    
    boolean isDead() {
        return health <= 0;
    }
    
    boolean hasReachedCore() {
        return pathIndex >= path.size() - 1 && 
               gridPosition.dist(gameGrid.getCorePosition()) < 1.0f;
    }
    
    PVector getPosition() {
        return position;
    }
    
    PVector getGridPosition() {
        return gridPosition;
    }
    
    int getHealth() {
        return health;
    }
    
    int getMaxHealth() {
        return maxHealth;
    }
    
    EnemyType getType() {
        return type;
    }
    
    List<PVector> getPath() {
        return path;
    }
    
    int getPathIndex() {
        return pathIndex;
    }
    
    float getSpeed() {
        return speed;
    }
    
    float getMoveDelay() {
        return moveDelay;
    }
    
    void display() {
        float size = CELL_SIZE * 0.8f;
        
        switch (type) {
            case FAST:
                fill(255, 100, 100);
                break;
            case STRONG:
                fill(100, 100, 255);
                break;
            case EXPLODER:
                fill(255, 0, 0);
                break;
            case TANK:
                size = CELL_SIZE * 1.2f;
                fill(0, 0, 255);
                break;
            default:
                fill(255, 200, 100);
                break;
        }
        
        ellipse(position.x, position.y, size, size);
        
        displayHealthBar();
    }
    
    private void displayHealthBar() {
        float barWidth = CELL_SIZE * 0.6f;
        float barHeight = 4;
        float barX = position.x - barWidth/2;
        float barY = position.y - CELL_SIZE/2 - 8;
        
        fill(255, 0, 0);
        rect(barX, barY, barWidth, barHeight);
        
        float healthPercent = (float)health / maxHealth;
        fill(0, 255, 0);
        rect(barX, barY, barWidth * healthPercent, barHeight);
    }
}

enum EnemyType {
    NORMAL,
    FAST,
    STRONG,
    EXPLODER,
    TANK
}
