enum GamePhase {
    PLAYING,
    GAME_OVER_WIN,
    GAME_OVER_LOSE
}

class GameState {
    private GamePhase currentPhase;
    private int currentWave;
    
    GameState() {
        currentPhase = GamePhase.PLAYING;
        currentWave = 0;
    }
    
    boolean isPlaying() {
        return currentPhase == GamePhase.PLAYING;
    }
    
    boolean isGameOver() {
        return currentPhase == GamePhase.GAME_OVER_WIN || 
               currentPhase == GamePhase.GAME_OVER_LOSE;
    }
    
    boolean hasWon() {
        return currentPhase == GamePhase.GAME_OVER_WIN;
    }
    
    boolean hasLost() {
        return currentPhase == GamePhase.GAME_OVER_LOSE;
    }
    
    void setGameOverWin() {
        currentPhase = GamePhase.GAME_OVER_WIN;
    }
    
    void setGameOverLose() {
        currentPhase = GamePhase.GAME_OVER_LOSE;
    }
    
    int getCurrentWave() {
        return currentWave;
    }
    
    void setCurrentWave(int wave) {
        currentWave = wave;
    }
    
    void nextWave() {
        currentWave++;
        if (currentWave >= WAVES_TO_WIN) {
            setGameOverWin();
        }
    }
}
