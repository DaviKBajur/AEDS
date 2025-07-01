class Grafo {
  int numVertices;
  int[][] matrizAdj;
  PVector[] posicoes;
  PVector[] velocidades;
  float raio = 10;
  float k = 0.001;
  float c = 3000;

  Grafo(int numVertices) {
    this.numVertices = numVertices;
    matrizAdj = new int[numVertices][numVertices];
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
  }

  Grafo(int[][] adj) {
    this.numVertices = adj.length;
    matrizAdj = adj;
    posicoes = new PVector[numVertices];
    velocidades = new PVector[numVertices];
    inicializarPosicoes();
  }

  void adicionarAresta(int i, int j) {
    matrizAdj[i][j] = 1;
    matrizAdj[j][i] = 1;
  }

  void adicionarAresta(int i, int j, int peso) {
    matrizAdj[i][j] = peso;
    matrizAdj[j][i] = peso;
  }

  void inicializarPosicoes() {
    float angulo = TWO_PI / (numVertices - 1);
    float raioCirculo = min(width, height) / 3;
    for (int i = 1; i < numVertices; i++) {
      float x = width / 2 + raioCirculo * cos((i - 1) * angulo);
      float y = height / 2 + raioCirculo * sin((i - 1) * angulo);
      posicoes[i] = new PVector(x, y);
      velocidades[i] = new PVector(0, 0);
    }
    posicoes[0] = new PVector(width / 2, height / 2);
    velocidades[0] = new PVector(0, 0);
  }

  void atualizar() {
    for (int i = 1; i < numVertices; i++) {
      PVector forca = new PVector(0, 0);

      for (int j = 0; j < numVertices; j++) {
        if (i != j) {
          PVector direcao = PVector.sub(posicoes[i], posicoes[j]);
          float distancia = direcao.mag();
          if (distancia > 0) {
            direcao.normalize();
            float forcaRepulsao = c / (distancia * distancia);
            direcao.mult(forcaRepulsao);
            forca.add(direcao);
          }
        }
      }

      for (int j = 0; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          PVector direcao = PVector.sub(posicoes[j], posicoes[i]);
          float distancia = direcao.mag();
          direcao.normalize();
          float forcaAtracao = k * (distancia - raio);
          direcao.mult(forcaAtracao);
          forca.add(direcao);
        }
      }

      velocidades[i].add(forca);
      posicoes[i].add(velocidades[i]);
      velocidades[i].mult(0.5);

      if (posicoes[i].x < 0 || posicoes[i].x > width) velocidades[i].x *= -1;
      if (posicoes[i].y < 0 || posicoes[i].y > height) velocidades[i].y *= -1;
    }
  }

  // Novo: desenha o grafo com destaque para arestas do caminho
  void desenhar(int[] caminho) {
    textAlign(CENTER);

    // Desenha arestas
    strokeWeight(1);
    for (int i = 0; i < numVertices; i++) {
      for (int j = i + 1; j < numVertices; j++) {
        if (matrizAdj[i][j] > 0) {
          // Se a aresta faz parte do caminho, desenha em vermelho
          if (fazParteDoCaminho(i, j, caminho)) {
            stroke(255, 0, 0);
            strokeWeight(3);
          } else {
            stroke(0);
            strokeWeight(1);
          }
          line(posicoes[i].x, posicoes[i].y, posicoes[j].x, posicoes[j].y);
        }
      }
    }

    // Desenha nós
    for (int i = 0; i < numVertices; i++) {
      fill(255);
      stroke(0);
      ellipse(posicoes[i].x, posicoes[i].y, raio * 2, raio * 2);
      fill(0);
      text(str(i), posicoes[i].x, posicoes[i].y + 4);
    }
  }

  // Auxiliar: verifica se a aresta i-j está no caminho
  boolean fazParteDoCaminho(int i, int j, int[] caminho) {
    for (int k = 0; k < caminho.length - 1; k++) {
      int a = caminho[k];
      int b = caminho[k + 1];
      if ((a == i && b == j) || (a == j && b == i)) {
        return true;
      }
    }
    return false;
  }

  // Novo: algoritmo de Dijkstra que retorna o caminho como array
  int[] dijkstra(int origem, int destino) {
    int[] dist = new int[numVertices];
    int[] anterior = new int[numVertices];
    boolean[] visitado = new boolean[numVertices];

    for (int i = 0; i < numVertices; i++) {
      dist[i] = Integer.MAX_VALUE;
      anterior[i] = -1;
      visitado[i] = false;
    }
    dist[origem] = 0;

    for (int count = 0; count < numVertices - 1; count++) {
      int u = -1;
      int minDist = Integer.MAX_VALUE;
      for (int i = 0; i < numVertices; i++) {
        if (!visitado[i] && dist[i] < minDist) {
          minDist = dist[i];
          u = i;
        }
      }

      if (u == -1) break;
      visitado[u] = true;

      for (int v = 0; v < numVertices; v++) {
        if (matrizAdj[u][v] > 0 && !visitado[v]) {
          int alt = dist[u] + matrizAdj[u][v];
          if (alt < dist[v]) {
            dist[v] = alt;
            anterior[v] = u;
          }
        }
      }
    }

    ArrayList<Integer> caminhoList = new ArrayList<Integer>();
    for (int v = destino; v != -1; v = anterior[v]) {
      caminhoList.add(0, v);
    }

    if (caminhoList.size() == 0 || caminhoList.get(0) != origem) {
      return new int[0]; // sem caminho
    }

    int[] caminho = new int[caminhoList.size()];
    for (int i = 0; i < caminho.length; i++) {
      caminho[i] = caminhoList.get(i);
    }

    return caminho;
  }
}


Grafo grafo;
int[] caminho;

void setup() {
  size(800, 600);
  grafo = new Grafo(6);
  grafo.adicionarAresta(0, 1, 2);
  grafo.adicionarAresta(1, 2, 1);
  grafo.adicionarAresta(2, 3, 4);
  grafo.adicionarAresta(3, 4, 20);
  grafo.adicionarAresta(4, 5, 2);
  grafo.adicionarAresta(0, 5, 10);

  caminho = grafo.dijkstra(2, 5); // calcula o menor caminho
}

void draw() {
  background(255);
  grafo.atualizar();
  grafo.desenhar(caminho); // desenha o grafo com caminho destacado
}
