import java.util.*;

// Configurações do jogo
final int GRID_WIDTH = 40;
final int GRID_HEIGHT = 30;
final int CELL_SIZE = 20;
final int STARTING_MONEY = 100000000;
final int WAVES_TO_WIN = 20;
final float GAME_SPEED_NORMAL = 1.0f;
final float GAME_SPEED_FAST = 2.0f;

// Estados do jogo
GameState gameState;
GameGrid gameGrid;
WaveManager waveManager;
Player player;
UI ui;
float gameSpeed = GAME_SPEED_NORMAL;


PImage img;

void setup() {
    size(800, 600);
    gameState = new GameState();
    gameGrid = new GameGrid(GRID_WIDTH, GRID_HEIGHT, CELL_SIZE);
    waveManager = new WaveManager();
    player = new Player(STARTING_MONEY);
    ui = new UI();
    img = loadImage("Money.png");
}

void draw() {
    background(50, 100, 50);
    
    
    gameGrid.update();
    gameGrid.display();
    waveManager.update();
    waveManager.display();
    ui.display();
  //  imageMode();
    image(img, 0, (height / 2)-27, 50,50);
    if (gameState.isGameOver()) {
        displayGameOver();
    }
}

void mousePressed() {
    if (gameState.isPlaying()) {
        int gridX = mouseX / CELL_SIZE;
        int gridY = mouseY / CELL_SIZE;
        
        if (gridX >= 0 && gridX < GRID_WIDTH && gridY >= 0 && gridY < GRID_HEIGHT) {
            ui.handleGridClick(gridX, gridY);
        }
    }
}

void keyPressed() {
    if (key == '1') {
        ui.selectStructure(StructureType.WALL);
    } else if (key == '2') {
        ui.selectStructure(StructureType.SAND);
    } else if (key == '3') {
        ui.selectStructure(StructureType.TOWER);
    } else if (key == 'r' || key == 'R') {
        restartGame();
    } else if (key == ' ' && !waveManager.isWaveInProgress()) {
        waveManager.startWave();
    } else if (key == 't' || key == 'T') {
        toggleGameSpeed();
    }
}

void displayGameOver() {
    fill(0, 0, 0, 150);
    rect(0, 0, width, height);
    
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    
    if (gameState.hasWon()) {
        text("VITÓRIA!", width/2, height/2 - 20);
        text("Você sobreviveu a " + WAVES_TO_WIN + " ondas!", width/2, height/2 + 20);
    } else {
        text("DERROTA!", width/2, height/2 - 20);
        text("O dinheiro foi capturado!", width/2, height/2 + 20);
    }
    
    textSize(16);
    text("Pressione R para reiniciar", width/2, height/2 + 60);
}

void restartGame() {
    gameState = new GameState();
    gameGrid = new GameGrid(GRID_WIDTH, GRID_HEIGHT, CELL_SIZE);
    waveManager = new WaveManager();
    player = new Player(STARTING_MONEY);
    ui = new UI();
    gameSpeed = GAME_SPEED_NORMAL;
}

void toggleGameSpeed() {
    if (gameSpeed == GAME_SPEED_NORMAL) {
        gameSpeed = GAME_SPEED_FAST;
    } else {
        gameSpeed = GAME_SPEED_NORMAL;
    }
}
