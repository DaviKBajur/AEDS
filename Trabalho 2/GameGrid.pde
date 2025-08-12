enum CellType {
    EMPTY,
    WALL,
    WALL_DAMAGED,
    SAND,
    TOWER,
    CORE,
    SPAWN
}

class GameGrid {
    private CellType[][] grid;
    private int width, height, cellSize;
    private List<Enemy> enemies;
    private List<Tower> towers;
    private List<Projectile> projectiles;
    private PVector corePosition;
    private Map<String, Integer> wallHealth;
    
    GameGrid(int w, int h, int cellSize) {
        this.width = w;
        this.height = h;
        this.cellSize = cellSize;
        this.grid = new CellType[w][h];
        this.enemies = new ArrayList<>();
        this.towers = new ArrayList<>();
        this.projectiles = new ArrayList<>();
        this.wallHealth = new HashMap<>();
        
        initializeGrid();
    }
    
    private void initializeGrid() {
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                grid[x][y] = CellType.EMPTY;
            }
        }
        
        corePosition = new PVector(0, height / 2);
        grid[(int)corePosition.x][(int)corePosition.y] = CellType.CORE;
        
        for (int y = 0; y < height; y++) {
            grid[width - 1][y] = CellType.SPAWN;
        }
    }
    
    boolean canBuildAt(int x, int y) {
        return x >= 0 && x < width && y >= 0 && y < height && 
               grid[x][y] == CellType.EMPTY;
    }
    
    void buildStructure(int x, int y, StructureType type) {
        if (!canBuildAt(x, y)) return;
        
        switch (type) {
            case WALL:
                grid[x][y] = CellType.WALL;
                wallHealth.put(x + "," + y, 3);
                break;
            case SAND:
                grid[x][y] = CellType.SAND;
                break;
            case TOWER:
                grid[x][y] = CellType.TOWER;
                towers.add(new Tower(x * cellSize + cellSize/2, y * cellSize + cellSize/2));
                break;
        }
        
        recalculatePaths();
    }
    
    void recalculatePaths() {
        for (Enemy enemy : enemies) {
            enemy.setPath(findPath(enemy.getGridPosition(), corePosition));
        }
    }
    
    List<PVector> findPath(PVector start, PVector end) {
        PriorityQueue<Node> openSet = new PriorityQueue<>();
        Map<PVector, Node> allNodes = new HashMap<>();
        
        Node startNode = new Node(start, 0, null);
        openSet.add(startNode);
        allNodes.put(start, startNode);
        
        while (!openSet.isEmpty()) {
            Node current = openSet.poll();
            
            if (current.position.equals(end)) {
                return reconstructPath(current);
            }
            
            for (PVector neighbor : getNeighbors(current.position)) {
                if (grid[(int)neighbor.x][(int)neighbor.y] == CellType.WALL) {
                    continue;
                }
                
                float cost = getMovementCost(neighbor);
                float newCost = current.gCost + cost;
                
                Node neighborNode = allNodes.get(neighbor);
                if (neighborNode == null) {
                    neighborNode = new Node(neighbor, newCost, current);
                    openSet.add(neighborNode);
                    allNodes.put(neighbor, neighborNode);
                } else if (newCost < neighborNode.gCost) {
                    neighborNode.gCost = newCost;
                    neighborNode.parent = current;
                }
            }
        }
        
        // Se não encontrou caminho, força um caminho através de paredes danificadas
        return findForcedPath(start, end);
    }
    
    private List<PVector> findForcedPath(PVector start, PVector end) {
        PriorityQueue<Node> openSet = new PriorityQueue<>();
        Map<PVector, Node> allNodes = new HashMap<>();
        
        Node startNode = new Node(start, 0, null);
        openSet.add(startNode);
        allNodes.put(start, startNode);
        
        while (!openSet.isEmpty()) {
            Node current = openSet.poll();
            
            if (current.position.equals(end)) {
                return reconstructPath(current);
            }
            
            for (PVector neighbor : getNeighbors(current.position)) {
                float cost = getForcedMovementCost(neighbor);
                float newCost = current.gCost + cost;
                
                Node neighborNode = allNodes.get(neighbor);
                if (neighborNode == null) {
                    neighborNode = new Node(neighbor, newCost, current);
                    openSet.add(neighborNode);
                    allNodes.put(neighbor, neighborNode);
                } else if (newCost < neighborNode.gCost) {
                    neighborNode.gCost = newCost;
                    neighborNode.parent = current;
                }
            }
        }
        
        return new ArrayList<>();
    }
    
    private float getForcedMovementCost(PVector pos) {
        if (grid[(int)pos.x][(int)pos.y] == CellType.SAND) {
            return 2.0f;
        }
        if (grid[(int)pos.x][(int)pos.y] == CellType.WALL) {
            return 10.0f; // Custo alto mas não infinito
        }
        if (grid[(int)pos.x][(int)pos.y] == CellType.WALL_DAMAGED) {
            return 3.0f;
        }
        return 1.0f;
    }
    
    private List<PVector> getNeighbors(PVector pos) {
        List<PVector> neighbors = new ArrayList<>();
        int x = (int)pos.x;
        int y = (int)pos.y;
        
        if (x > 0) neighbors.add(new PVector(x-1, y));
        if (x < width-1) neighbors.add(new PVector(x+1, y));
        if (y > 0) neighbors.add(new PVector(x, y-1));
        if (y < height-1) neighbors.add(new PVector(x, y+1));
        
        return neighbors;
    }
    
    private float getMovementCost(PVector pos) {
        if (grid[(int)pos.x][(int)pos.y] == CellType.SAND) {
            return 2.0f;
        }
        if (grid[(int)pos.x][(int)pos.y] == CellType.WALL_DAMAGED) {
            return 1.5f;
        }
        return 1.0f;
    }
    
    private List<PVector> reconstructPath(Node endNode) {
        List<PVector> path = new ArrayList<>();
        Node current = endNode;
        
        while (current != null) {
            path.add(0, current.position);
            current = current.parent;
        }
        
        return path;
    }
    
    void addEnemy(Enemy enemy) {
        enemies.add(enemy);
        enemy.setPath(findPath(enemy.getGridPosition(), corePosition));
    }
    
    void update() {
        updateEnemies();
        updateTowers();
        updateProjectiles();
        checkCollisions();
    }
    
    private void updateEnemies() {
        for (int i = enemies.size() - 1; i >= 0; i--) {
            Enemy enemy = enemies.get(i);
            enemy.update();
            
            if (enemy.hasReachedCore()) {
                gameState.setGameOverLose();
                return;
            }
            
            if (enemy.isDead()) {
                int waveNumber = gameState.getCurrentWave();
                int baseReward = 0;
                
                switch (enemy.getType()) {
                    case FAST:
                        baseReward = 18;
                        break;
                    case STRONG:
                        baseReward = 30;
                        break;
                    case EXPLODER:
                        baseReward = 25;
                        explodeWalls(enemy.getGridPosition());
                        break;
                    case TANK:
                        baseReward = 40;
                        break;
                    default:
                        baseReward = 15;
                        break;
                }
                
                int finalReward = baseReward + (waveNumber - 1) * 2;
                player.addMoney(finalReward);
                enemies.remove(i);
            }
        }
    }
    
    private void updateTowers() {
        for (Tower tower : towers) {
            tower.update(enemies);
            if (tower.canShoot()) {
                Enemy target = tower.findTarget(enemies);
                if (target != null) {
                    Projectile proj = tower.shoot(target);
                    projectiles.add(proj);
                    proj.setTower(tower);
                    
                    int damage = tower.getDamage();
                    target.takeDamage(damage);
                    
                    if (target.isDead()) {
                        tower.addXP(5);
                    }
                }
            }
        }
    }
    
    private void updateProjectiles() {
        for (int i = projectiles.size() - 1; i >= 0; i--) {
            Projectile proj = projectiles.get(i);
            proj.update();
            
            if (proj.hasHitTarget() || proj.isOutOfBounds()) {
                projectiles.remove(i);
            }
        }
    }
    
    private void checkCollisions() {
        for (int i = projectiles.size() - 1; i >= 0; i--) {
            Projectile proj = projectiles.get(i);
            
            for (Enemy enemy : enemies) {
                if (proj.hits(enemy)) {
                    projectiles.remove(i);
                    break;
                }
            }
        }
    }
    
    void display() {
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                float screenX = x * cellSize;
                float screenY = y * cellSize;
                
                switch (grid[x][y]) {
                    case EMPTY:
                        fill(100, 150, 100);
                        break;
                    case WALL:
                        fill(80, 80, 80);
                        break;
                    case WALL_DAMAGED:
                        fill(120, 80, 80);
                        break;
                    case SAND:
                        fill(194, 178, 128);
                        break;
                    case TOWER:
                        fill(50, 50, 150);
                        break;
                    case CORE:
                        fill(255, 0, 0);
                        break;
                    case SPAWN:
                        fill(150, 100, 100);
                        break;
                }
                
                rect(screenX, screenY, cellSize, cellSize);
                stroke(50);
                noFill();
                rect(screenX, screenY, cellSize, cellSize);
            }
        }
        
        for (Enemy enemy : enemies) {
            enemy.display();
        }
        
        for (Tower tower : towers) {
            tower.display();
        }
        
        for (Projectile proj : projectiles) {
            proj.display();
        }
    }
    
    PVector getCorePosition() {
        return corePosition;
    }
    
    List<Enemy> getEnemies() {
        return enemies;
    }
    
    boolean isWallAt(int x, int y) {
        return grid[x][y] == CellType.WALL || grid[x][y] == CellType.WALL_DAMAGED;
    }
    
    void damageWall(int x, int y) {
        String key = x + "," + y;
        if (wallHealth.containsKey(key)) {
            int health = wallHealth.get(key);
            health--;
            
            if (health <= 0) {
                grid[x][y] = CellType.EMPTY;
                wallHealth.remove(key);
                recalculatePaths();
            } else {
                wallHealth.put(key, health);
                if (health == 1) {
                    grid[x][y] = CellType.WALL_DAMAGED;
                }
            }
        }
    }
    
    private void explodeWalls(PVector position) {
        int x = (int)position.x;
        int y = (int)position.y;
        
        for (int dx = -1; dx <= 1; dx++) {
            for (int dy = -1; dy <= 1; dy++) {
                int newX = x + dx;
                int newY = y + dy;
                
                if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
                    if (grid[newX][newY] == CellType.WALL) {
                        grid[newX][newY] = CellType.EMPTY;
                    }
                }
            }
        }
        
        recalculatePaths();
    }
}

class Node implements Comparable<Node> {
    PVector position;
    float gCost;
    Node parent;
    
    Node(PVector pos, float cost, Node parent) {
        this.position = pos;
        this.gCost = cost;
        this.parent = parent;
    }
    
    @Override
    public int compareTo(Node other) {
        return Float.compare(this.gCost, other.gCost);
    }
}
