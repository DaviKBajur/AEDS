enum StructureType {
    WALL,
    SAND,
    TOWER
}

class UI {
    private StructureType selectedStructure;
    private final int WALL_COST = 5;
    private final int SAND_COST = 6;
    private final int TOWER_COST = 50;
    
    UI() {
        selectedStructure = StructureType.WALL;
    }
    
    void selectStructure(StructureType type) {
        selectedStructure = type;
    }
    
    void handleGridClick(int gridX, int gridY) {
        if (gameGrid.canBuildAt(gridX, gridY)) {
            int cost = getStructureCost(selectedStructure);
            
            if (player.canAfford(cost)) {
                gameGrid.buildStructure(gridX, gridY, selectedStructure);
                player.spendMoney(cost);
            }
        }
    }
    
    private int getStructureCost(StructureType type) {
        switch (type) {
            case WALL:
                return WALL_COST;
            case SAND:
                return SAND_COST;
            case TOWER:
                return TOWER_COST;
            default:
                return 0;
        }
    }
    
    void display() {
        displayStructurePanel();
        displayInstructions();
        displayGameSpeed();
        player.display();
        waveManager.display();
    }
    
    private void displayStructurePanel() {
        float panelX = 10;
        float panelY = height - 120;
        float buttonWidth = 80;
        float buttonHeight = 30;
        
        fill(50, 50, 50, 200);
        rect(panelX, panelY, 250, 110);
        
        fill(255);
        textAlign(LEFT, TOP);
        textSize(14);
        text("Estruturas:", panelX + 5, panelY + 5);
        
        displayStructureButton("Parede ($" + WALL_COST + ")", panelX + 5, panelY + 25, 
                             StructureType.WALL, buttonWidth, buttonHeight);
        displayStructureButton("Areia ($" + SAND_COST + ")", panelX + 95, panelY + 25, 
                             StructureType.SAND, buttonWidth, buttonHeight);
        displayStructureButton("Torre ($" + TOWER_COST + ")", panelX + 185, panelY + 25, 
                             StructureType.TOWER, buttonWidth, buttonHeight);
        
        displayStructureButton("1", panelX + 5, panelY + 65, StructureType.WALL, 20, 20);
        displayStructureButton("2", panelX + 35, panelY + 65, StructureType.SAND, 20, 20);
        displayStructureButton("3", panelX + 65, panelY + 65, StructureType.TOWER, 20, 20);
        
        text("Teclas de atalho", panelX + 95, panelY + 65);
    }
    
    private void displayStructureButton(String text, float x, float y, StructureType type, 
                                      float w, float h) {
        if (selectedStructure == type) {
            fill(100, 150, 255);
        } else {
            fill(100, 100, 100);
        }
        
        rect(x, y, w, h);
        
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(12);
        text(text, x + w/2, y + h/2);
    }
    
    private void displayInstructions() {
        fill(255);
        textAlign(LEFT, TOP);
        textSize(12);
        text("Clique no grid para construir estruturas", 10, height - 150);
        text("Proteja o núcleo vermelho dos inimigos!", 10, height - 135);
        text("Pressione ESPAÇO para iniciar ondas", 10, height - 120);
    }
    
    StructureType getSelectedStructure() {
        return selectedStructure;
    }
    
    private void displayGameSpeed() {
        fill(255);
        textAlign(LEFT, TOP);
        textSize(12);
        text("Velocidade: " + (gameSpeed == 1.0f ? "1x" : "2x"), 10, height - 180);
        text("Pressione T para alternar velocidade", 10, height - 165);
    }
}
