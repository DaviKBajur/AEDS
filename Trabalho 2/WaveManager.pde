class WaveManager {
    private Queue<Enemy> enemyQueue;
    private float spawnTimer;
    private float spawnDelay;
    private boolean waveInProgress;
    private int enemiesInWave;
    private int enemiesSpawned;
    
    WaveManager() {
        this.enemyQueue = new LinkedList<>();
        this.spawnTimer = 0;
        this.spawnDelay = 1.0f;
        this.waveInProgress = false;
        this.enemiesInWave = 0;
        this.enemiesSpawned = 0;
    }
    
    void update() {
        if (waveInProgress) {
            spawnTimer += 0.016f * gameSpeed;
            
            if (spawnTimer >= spawnDelay && !enemyQueue.isEmpty()) {
                spawnEnemy();
                spawnTimer = 0;
            }
            
            if (enemiesSpawned >= enemiesInWave && gameGrid.getEnemies().isEmpty()) {
                endWave();
            }
        }
    }
    
    void startWave() {
        if (!waveInProgress) {
            waveInProgress = true;
            enemiesSpawned = 0;
            gameState.setCurrentWave(gameState.getCurrentWave() + 1);
            
            generateWave();
        }
    }
    
    private void generateWave() {
        int waveNumber = gameState.getCurrentWave();
        enemiesInWave = 5 + waveNumber * 4;
        
        for (int i = 0; i < enemiesInWave; i++) {
            EnemyType type = selectEnemyType(waveNumber);
            PVector spawnPos = getRandomSpawnPosition();
            enemyQueue.add(new Enemy(type, spawnPos));
        }
    }
    
    private EnemyType selectEnemyType(int waveNumber) {
        float rand = random(1.0f);
        
        if (waveNumber >= 3 && rand < 0.25f) {
            return EnemyType.FAST;
        } else if (waveNumber >= 5 && rand < 0.20f) {
            return EnemyType.STRONG;
        } else if (waveNumber >= 7 && rand < 0.15f) {
            return EnemyType.EXPLODER;
        } else if (waveNumber >= 9 && rand < 0.10f) {
            return EnemyType.TANK;
        } else {
            return EnemyType.NORMAL;
        }
    }
    
    private PVector getRandomSpawnPosition() {
        int x = GRID_WIDTH - 1;
        int y = GRID_HEIGHT/2;                                  //(int)random(GRID_HEIGHT);
        return new PVector(x, y);
    }
    
    private void spawnEnemy() {
        if (!enemyQueue.isEmpty()) {
            Enemy enemy = enemyQueue.poll();
            gameGrid.addEnemy(enemy);
            enemiesSpawned++;
        }
    }
    
    private void endWave() {
        waveInProgress = false;
        gameState.nextWave();
        
        if (gameState.hasWon()) {
            return;
        }
        
        delay(2000);
        startWave();
    }
    
    
    void display() {
        fill(255);
        textAlign(LEFT, TOP);
        textSize(16);
        text("Onda: " + gameState.getCurrentWave() + "/" + WAVES_TO_WIN, 10, 10);
        
        if (waveInProgress) {
            text("Inimigos restantes: " + (enemiesInWave - enemiesSpawned + gameGrid.getEnemies().size()), 10, 30);
        } else {
            text("Pressione ESPAÇO para iniciar a próxima onda", 10, 30);
        }
    }
    
    boolean isWaveInProgress() {
        return waveInProgress;
    }
}
