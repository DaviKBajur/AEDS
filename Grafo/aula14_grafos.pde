Grafo grafo;

void setup() {
  size(800, 600);
  frameRate(60);
  
  int n = 10;
  int[][] adj = new int[n][n];
  
  for(int i = 0; i < n; i++)
    for(int j = 0; j < n; j++){
      if(i == j){
        adj[i][j] = 0;
      }
      else{
        adj[i][j] = random(1) > 0.5 ? int(random(1, 5)) : 0;
        adj[j][i] = adj[i][j];
      }
    }
  
  grafo = new Grafo(adj);
  
}

void draw(){
  background(255);
  grafo.atualizar();
  grafo.desenhar();
}
