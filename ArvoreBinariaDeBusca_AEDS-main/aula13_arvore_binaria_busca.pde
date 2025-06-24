ArvoreBinaria arv = new ArvoreBinaria();

void setup(){
   size(600, 600); 
}

void draw(){
  background(255);
  
  arv.mostrar();
}

void mouseClicked() {
  arv.insere((int)random(1000)); 
}
