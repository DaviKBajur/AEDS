class Player {
    private int money;
    private int score;
    
    Player(int startingMoney) {
        this.money = startingMoney;
        this.score = 0;
    }
    
    boolean canAfford(int cost) {
        return money >= cost;
    }
    
    void spendMoney(int amount) {
        if (canAfford(amount)) {
            money -= amount;
        }
    }
    
    void addMoney(int amount) {
        money += amount;
        score += amount;
    }
    
    int getMoney() {
        return money;
    }
    
    int getScore() {
        return score;
    }
    
    void display() {
        fill(255);
        textAlign(RIGHT, TOP);
        textSize(16);
        text("Dinheiro: $" + money, width - 10, 10);
        text("Pontuação: " + score, width - 10, 30);
    }
}
