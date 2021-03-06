###################################################################
# UNIVERSIDADE FEDERAL DE MINAS GERAIS                            
# BACHARELADO EM ENGENHARIA DE SISTEMAS                           
# DISCIPLINA: ELE088 Teoria da Decisao                            
# PROFESSOR: Lucas de Souza Batista                               
# ALUNOs: Ariel Domingues, Hernane Braga e Nikolas Fantoni        
# DATA: Outubro/2019                               
# TC2 - Otimizacao multi-objetivo do PCV

# O algoritmo abaixo pode ser rodado como um todo ou em blocos, conforme dividido a seguir.
#  aconselhável a limpeza do ambiente antes da execução do algoritmo, usando a funÃ§Ã£o abaixo.
rm(list=ls())

# Importando Bibliotecas, arquivos necessÃ¡rios e os dados
# Aqui deve ser definido se o arquivo distancia.csv ou o arquivo tempo.csv
# serÃ£o utilizados na otimizacao.
source('solucao_inicial.R')
source('vizinhanca2.R')
source('ConfereDominancia.R')
dados_tempo <- as.matrix(read.csv(file="tempo.csv", header=FALSE, sep=","))
dados_distancia <- as.matrix(read.csv(file="distancia.csv", header=FALSE, sep=","))

fnormalizada <- function(X, min, max){
  ftempo <- (sum(X$custotempo) - min[1])/(max[1] - min[1])
  fdistancia <- (sum(X$custodistancia) - min[2])/(max[2] - min[2])
  return(c(ftempo, fdistancia))
}

#Define os custos minimos passados como enunciado
min <- array(0, 2)
min[1] <- 16.5
min[2] <- 1250

#Define os custos mÃ¡ximos usando uma solucÃ£o inicial aleatÃ³ria
Xrand <- sample(2:250)
maxt <- dados_tempo[1,Xrand[1]]
maxd <- dados_distancia[1,Xrand[1]] 
for (i in 1:(length(Xrand)-1)){
  maxt <- c(maxt,dados_tempo[Xrand[i],Xrand[i+1]])
  maxd <- c(maxd,dados_distancia[Xrand[i],Xrand[i+1]])
}
maxt <- c(maxt,dados_tempo[Xrand[i+1],1])
maxd <- c(maxd,dados_distancia[Xrand[i+1],1])

destino <- c(Xrand,1)
max <- array(0, 2)
max[1] <- sum(maxt)
max[2] <- sum(maxd)

###################################################
###           BLOCO DA SOLUÃÃO INICIAL          ###
###################################################

# Define o grau de variabilidade da soluÃ§Ã£o inicial (nÃºmero inteiro).
# Valores menores significam uma soluÃ§Ã£o mais prÃ³xima da soluÃ§Ã£o obtida
# a partir de um algoritmo guloso.

X <- t(solucao_inicial("distancia.csv","tempo.csv", 1))
dtemp <- X[,2]
X[,2] <- X[,3]
X[,3] <- dtemp
colnames(X) <- c("destino", "custotempo", "custodistancia")
X <- data.frame(X)
X$custotempo[1] <- dados_tempo[1,X$destino[1]] #corrige um valor da solução inicial

custoinicial_tempo <- sum(X$custotempo)
custoinicial_distancia <- sum(X$custodistancia)

wt <- 1
wd <- 0
w <- c(wt, wd)

superficie_best <- array(0, c(2, 40))

for (j in 1:100) {
  
f <- fnormalizada(X, min, max)
f <- wt*f[1]+wd*f[2]
custoinicial_norm <- f
###################################################
###       BLOCO DA TEMPERATURA INICIAL          ###
###################################################

# Calcula a temperatura inicial T0 com base na fÃ³rmula
# e^-mÃ©dia(deltaE)/T0 = tau
tau <- 0.5
grau <- 1
deltaE <- NULL
for (i in 1:40){
  flinha <- fnormalizada(Vizinhanca(X, dados_tempo, dados_distancia, 1), min, max)
  deltaE <- c(deltaE,(abs(wt*flinha[1]+wd*flinha[2]) - f))
}
T0 <- -mean(deltaE)/(log(tau))
rm(tau, i, grau, deltaE)

###################################################
###       BLOCO DO SIMULATED ANNEALING          ###
###################################################

# Constantes do SA
seqi <- seq(0.00001,1,0.00001) # Usada para sortear um valor
costt_norm <- f # Guarda os custos ao longo do algoritmo
iteracao <- 0 # Valor das iteraÃ§Ãµes totais feitas
nivel <- 1 # NÃ?vel de perturbaÃ§Ã£o vizinhanÃ§a inicial (quanto maior, maior a diferenÃ§a entre as soluÃ§Ãµes)
D0 <- 0.7 # VariaÃ§Ã£o da temperatura inicial estÃ¡tica
Tk <- T0 # PrÃ³xima temperatura
m <- 1 # Valor das iteraÃ§Ãµes que serÃ£o feitas para cada temperatura
xbest <- X # Guarda a melhor soluÃ§Ã£o
fbest <- f # Guarda o valor da melhor soluÃ§Ã£o

# Looping do SA
while (iteracao < 1000 && Tk > (0.00001*T0) && nivel<=6){
  aceitacao <- 0
  m <- 0
  menordeltaE <- Inf
  todosdeltaE <- NULL
  
  # Faz a repetiÃ§Ã£o para cada mudanÃ§a na temperatura
  while (m <= 400 && aceitacao <= 15){
    cost1 <- f # Custo da soluÃ§Ã£o atual
    x1 <- Vizinhanca(X, dados_tempo, dados_distancia, nivel) # Encontra nova soluÃ§Ã£o na vizinhanÃ§a
    flinha <- sum(w*fnormalizada(x1, min, max))
    cost2 <- flinha # Custo da nova soluÃ§Ã£o
    deltaE <- cost2 - cost1 # Calcula a diferenÃ§a dos custos das soluÃ§Ãµes
    
    # Caso a vizinhanÃ§a retorne uma soluÃ§Ã£o idÃªntica
    while (deltaE == 0){
      cost1 <- f
      x1 <- Vizinhanca(X, dados_tempo, dados_distancia, nivel)
      flinha <- sum(w*fnormalizada(x1, min, max))
      cost2 <- flinha
      deltaE <- cost2 - cost1 
    }
    
    # Se a nova soluÃ§Ã£o x1 for melhor que a anterior
    if (deltaE <= 0){
      if (deltaE < menordeltaE) {
        menordeltaE <- deltaE # Atualiza menor deltaE
      }
      todosdeltaE <- c(todosdeltaE,deltaE) # Guarda todos os deltaE de soluÃ§Ãµes aceita
      aceitacao <- aceitacao +1 # Atualiza o contador de soluÃ§Ãµes aceitas
      X <- x1 # Atualiza a soluÃ§Ã£o atual
      f <- flinha
      if (f < fbest){
        xbest <- x1 #Atualiza a melhor soluÃ§Ã£o
        fbest <- f
      }
      costt_norm <- c(costt_norm,cost2) # Atualiza os custos encontrados
    }
    # Se a nova soluÃ§Ã£o x1 for pior que a anterior
    else {
      prob <- exp(-deltaE/Tk) # Calcula a probabilidade da soluÃ§Ã£o ser aceita
      if (sample(seqi,1)<prob) { # Se for aceita, parte anÃ¡loga ao caso de x1 ser melhor que X
        if (deltaE < menordeltaE) {
          menordeltaE <- deltaE
        }
        todosdeltaE <- c(todosdeltaE,deltaE)
        aceitacao <- aceitacao +1
        X <- x1
        f <- flinha
        costt_norm <- c(costt_norm,cost2)
      }
    }
    m <- m+1 # Contador de iteraÃ§Ãµes por temperatura
  }
  
  # Atualiza a temperatura com base na regra iterativa
  if (is.null(todosdeltaE)) {
    Tk <- D0*Tk
  } else {
    Tk <- min(abs(menordeltaE)/abs(mean(todosdeltaE)), D0)*Tk
  }
  
  # Se nÃ£o foram aceitas nenhuma soluÃ§Ã£o, aumenta o nÃ?vel da vizinhanÃ§a
  if (aceitacao<1) {
    nivel <- nivel + 1
  }
  # Se foram aceitas quaisquer soluÃ§Ãµes, volta para a vizinhanÃ§a de nÃ?vel mais baixo
  # para tentar uma busca local
  if (aceitacao >= 1){
    nivel <- 1
  }
  
  iteracao <- iteracao + 1 # Incrementa a iteraÃ§Ã£o total do algoritmo
}

# Salva o custo final da melhor soluÃ§Ã£o encontrada
custofinal_tempo <- sum(xbest$custotempo)
custofinal_distancia <- sum(xbest$custodistancia)
custofinal_norm <- fbest

# Limpa variÃ¡veis nÃ£o mais Ãºteis
rm(cost1, cost2, prob, seqi)

###################################################
###             BLOCO DAS SOLUÃÃES              ###
###################################################

# Plota custos e imprime o custo final e o custo inicial
plot(1:length(costt_norm), costt_norm,type="l", xlab="",ylab="Custo normalizado", main="EvoluÃ§Ã£o do custo normalizado ao longo do algoritmo SA")
cat("Custo inicial de tempo: ", custoinicial_tempo, " | Custo final de tempo: ", custofinal_tempo,"\n") 
cat("Custo inicial de distancia: ", custoinicial_distancia, " | Custo final de distancia: ", custofinal_distancia,"\n")
cat("Custo inicial normalizado: ", custoinicial_norm, " | Custo final normalizado: ", custofinal_norm, "\n\n")

wt <- wt - 0.025
wd <- wd + 0.025
w <- c(wt, wd)

superficie_best[,j] <- c(sum(xbest$custotempo), sum(xbest$custodistancia))

}

#Superfície Pareto Ótima
superficie_best_semdominancia <- ConfereDominancia(superficie_best)
plot(superficie_best_semdominancia[1,], superficie_best_semdominancia[2,], xlab = "Custo tempo", ylab = "Custo distancia", main="Superfície pareto Ótima")
par(new=T)
plot(superficie_best_semdominancia[1,], superficie_best_semdominancia[2,], type='l', xlab = "Custo tempo", ylab = "Custo distancia", main="Superfície Pareto Ótima")
