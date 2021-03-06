###################################################################
# UNIVERSIDADE FEDERAL DE MINAS GERAIS                            
# BACHARELADO EM ENGENHARIA DE SISTEMAS                           
# DISCIPLINA: ELE088 Teoria da Decisao                            
# PROFESSOR: Lucas de Souza Batista                               
# ALUNOs: Ariel Domingues, Hernane Braga e Nikolas Fantoni        
# DATA: Novembro/2019                               
# TC3 - Tomada de Decisão Multicritério no PCV

# Estruturas de vizinhanca para serem aplicadas no algoritmo Simulated Annealing (SA).

# Considerando os dados de custo como duas matrizes quadradas nxn e a solucao como um data.frame nx3
# onde as tres colunas se referem a 'destino', 'custotempo' e 'custodistancia', respectivamente. 
# Ou seja, a linha x do data.frame se refere a cidade x, sendo a primeira coluna a cidade destino,
# a segunda o tempo para de ir ate ela e a terceira a distancia.

#############################################################################################
# Funcao de nivel de perturbacao 1 ou 4, dependendo do numero de trocas (num_trocas). 
# As letras 'SD' equivalem a 'Simples' e 'Dupla'. A(s) cidade(s) eh(sao) escolhida(s) 
# aleatoriamente e troca(m) de lugar com seu vizinho da frente. Ou seja, se a ordem do caminho
# for A > B > C > D > E, e B eh a cidade escolhida, entao B troca com C e a nova ordem passa a 
# ser A > C > B > D > E. O numero de trocas definira quantas trocas desse tipo serao feitas
# de uma vez (1 ou 2).

TrocaVizinhaSD <- function(solucao_atual, dados_tempo, dados_distancia, num_trocas){
  nova_solucao <- solucao_atual
  
  for (i in 1:num_trocas) {
    cidade <- sample(dim(solucao_atual)[1], 1) # Escolhe-se uma cidade aleatoriamente
    
    vizinho_anterior <- which(solucao_atual$destino == cidade) 
    prox_vizinho1    <- solucao_atual$destino[cidade]
    prox_vizinho2    <- solucao_atual$destino[prox_vizinho1]
    
    # As trocas necessarias sao feitas com os novos custos extraidos das matrizes de custos
    nova_solucao[prox_vizinho1,]    <- c(cidade, 
                                         dados_tempo[prox_vizinho1, cidade], 
                                         dados_distancia[prox_vizinho1, cidade])
    
    nova_solucao[cidade,]           <- c(prox_vizinho2, 
                                         dados_tempo[cidade, prox_vizinho2], 
                                         dados_distancia[cidade, prox_vizinho2])
    
    nova_solucao[vizinho_anterior,] <- c(prox_vizinho1, 
                                         dados_tempo[vizinho_anterior, prox_vizinho1], 
                                         dados_distancia[vizinho_anterior, prox_vizinho1])
    
    solucao_atual <- nova_solucao
  }
  
  return(nova_solucao)
}

##################################################################################################
# Funcao de nivel de perturbacao 2 ou 6, dependendo do numero de deslocamentos (num_deslocs).
# As letras 'SD' referem-se a 'Simples' e 'Duplo', assim como a funcao anterior. A(s) cidade(s) 
# eh(sao) escolhida(s) aleatoriamente e sofrem um deslocamento para frente de 2 a 5 cidades 
# (distribuicao uniforme). Ou seja, se a ordem do caminho for A > B > C > D > E > F, e B  
# eh a cidade escolhida, entao B eh deslocada e a ordem passa a ser A > C > D > E > F > B,
# se o deslocamento for de 4 cidades por exemplo. O numero de deslocamentos definira quantos serao 
# feitos de uma vez (1 ou 2).

DeslocamentoSD <- function(solucao_atual, dados_tempo, dados_distancia, num_deslocs){
  nova_solucao <- solucao_atual
  
  for (i in 1:num_deslocs) {
    cidade <- sample(dim(solucao_atual)[1], 1) # Escolhe-se uma cidade aleatoriamente
    
    vizinho_anterior <- which(solucao_atual$destino == cidade)
    prox_vizinho1    <- solucao_atual$destino[cidade]
    
    # A cidade escolhida eh retirada do caminho.
    nova_solucao[vizinho_anterior,] <- c(prox_vizinho1, dados_tempo[vizinho_anterior, prox_vizinho1], dados_distancia[vizinho_anterior, prox_vizinho1])
     
    # Ela sera deslocada 2 a 5 posicoes para frente. O 'for' percorre o caminho para isso.
    delta_desloc <- sample(2:5, 1)
    for (j in 1:(delta_desloc-1)) {
      prox_vizinho1 <- solucao_atual$destino[prox_vizinho1]
    }
    prox_vizinho2 <- solucao_atual$destino[prox_vizinho1]
    
    # A cidade eh inserida apos o deslocamento.
    nova_solucao[prox_vizinho1,] <- c(cidade, 
                                      dados_tempo[prox_vizinho1, cidade], 
                                      dados_distancia[prox_vizinho1, cidade])
    
    nova_solucao[cidade,]        <- c(prox_vizinho2, 
                                      dados_tempo[cidade, prox_vizinho2], 
                                      dados_distancia[cidade, prox_vizinho2])
    
    solucao_atual <- nova_solucao
  }
  
  return(nova_solucao)
}

###################################################################################################
# Funcao de nivel de perturbacao 3. Uma cidade eh escolhida aleatoriamente e tem o trecho subsequente
# de 2 a 15 cidades invertido. Ou seja, de o caminho for A > B > C > D > E > F, e B eh a cidade 
# escolhida, entao o caminho seguinte a B eh invertido de forma a se tornar A > E > D > C > B > F,
# se o trecho for de 4 cidades por exemplo.

Inversao <- function(solucao_atual, dados_tempo, dados_distancia){
  nova_solucao <- solucao_atual
  cidade <- sample(dim(solucao_atual)[1], 1) # Escolhe-se uma cidade aleatoriamente
  
  vizinho_anterior <- which(solucao_atual$destino == cidade)
  prox_vizinho1    <- solucao_atual$destino[cidade]
  prox_vizinho2    <- solucao_atual$destino[prox_vizinho1]
  
  # As cidades do trecho a ser invertido passam a apontar para as cidades anteriores a elas.
  nova_solucao[prox_vizinho1,] <- c(cidade, 
                                    dados_tempo[prox_vizinho1, cidade], 
                                    dados_distancia[prox_vizinho1, cidade])
  
  # O for realiza o percorrimento do trecho.
  delta_intervalo <- sample(2:15, 1)
  for (j in 1:(delta_intervalo-2)) {
    nova_solucao[prox_vizinho2,] <- c(prox_vizinho1, 
                                      dados_tempo[prox_vizinho2, prox_vizinho1],
                                      dados_distancia[prox_vizinho2, prox_vizinho1])
    
    prox_vizinho1 <- prox_vizinho2
    prox_vizinho2 <- solucao_atual$destino[prox_vizinho2]
  }
  
  # As arestas das extremidades do trecho sao unidas para se fechar o caminho novamente.
  nova_solucao[vizinho_anterior,] <- c(prox_vizinho1, 
                                       dados_tempo[vizinho_anterior, prox_vizinho1], 
                                       dados_distancia[vizinho_anterior, prox_vizinho1])
  
  nova_solucao[cidade,]           <- c(prox_vizinho2, 
                                       dados_tempo[cidade, prox_vizinho2], 
                                       dados_distancia[cidade, prox_vizinho2])
  
  return(nova_solucao)
}

###################################################################################################
# Funcao de nivel de perturbacao 5. Uma cidade eh escolhida aleatoriamente e eh trocada de lugar
# com outra cidade a sua frente com um intervalo de 2 a 7 cidades entre elas. Ou seja, se o caminho
# for A > B > C > D > E > F > G, e B eh a cidade escolhida, entao ocorre a troca e o novo caminho passa
# a ser A > G > C > D > E > F > B, se o intervalo for de 4 cidades por exemplo.

TrocaIntervalada <- function(solucao_atual, dados_tempo, dados_distancia){
  nova_solucao <- solucao_atual
  cidade1 <- sample(dim(solucao_atual)[1], 1) # Escolhe-se uma cidade aleatoriamente.
  
  # Armazena-se os vizinhos da cidade 1 para receberem a cidade 2 trocada posteriormente.
  vizinho_anterior_cidade1 <- which(solucao_atual$destino == cidade1)
  prox_vizinho_cidade1     <- solucao_atual$destino[cidade1]
  vizinho_anterior_cidade2 <- prox_vizinho_cidade1
  
  # O intervalo eh percorrido pelo for.
  delta_intervalo <- sample(2:7, 1)
  for (j in 1:(delta_intervalo-1)) {
    vizinho_anterior_cidade2 <- solucao_atual$destino[vizinho_anterior_cidade2]
  }
  cidade2 <- solucao_atual$destino[vizinho_anterior_cidade2]
  prox_vizinho_cidade2 <- solucao_atual$destino[cidade2]
  
  # Os vizinhos da cidade 2 foram capturados e portanto ocorre a troca de fato das cidades no caminho.
  nova_solucao[vizinho_anterior_cidade1,] <- c(cidade2, 
                                               dados_tempo[vizinho_anterior_cidade1, cidade2], 
                                               dados_distancia[vizinho_anterior_cidade1, cidade2])
  
  nova_solucao[cidade2,]                  <- c(prox_vizinho_cidade1, 
                                               dados_tempo[cidade2, prox_vizinho_cidade1], 
                                               dados_distancia[cidade2, prox_vizinho_cidade1])
  
  nova_solucao[vizinho_anterior_cidade2,] <- c(cidade1, 
                                               dados_tempo[vizinho_anterior_cidade2, cidade1],
                                               dados_distancia[vizinho_anterior_cidade2, cidade1])
  
  nova_solucao[cidade1,]                  <- c(prox_vizinho_cidade2, 
                                               dados_tempo[cidade1, prox_vizinho_cidade2], 
                                               dados_distancia[cidade1, prox_vizinho_cidade2])
  
  return(nova_solucao)
}

###########################################################################################################
# Funcao que escolhera qual nivel de perturbacao utilizar. Para chama-la, o parametro nivel deve ser passado
# de 1 a 6, em ordem crescente de perturbacao. Passa-se uma solucao e os dados de custo de tempo e distancia
# como parametros e, dado o nivel, ela chama uma das estruturas de vizinhanca, que obtem uma nova solucao.

Vizinhanca <- function(solucao_atual, dados_tempo, dados_distancia, nivel){
  switch (nivel,
          TrocaVizinhaSD(solucao_atual, dados_tempo, dados_distancia, 1), # nivel 1 - Troca vizinha simples
          DeslocamentoSD(solucao_atual, dados_tempo, dados_distancia, 1), # nivel 2 - Deslocamento simples
          Inversao(solucao_atual, dados_tempo, dados_distancia),          # nivel 3
          TrocaVizinhaSD(solucao_atual, dados_tempo, dados_distancia, 2), # nivel 4 - Troca vizinha dupla
          TrocaIntervalada(solucao_atual, dados_tempo, dados_distancia),  # nivel 5
          DeslocamentoSD(solucao_atual, dados_tempo, dados_distancia, 2)  # nivel 6 - Deslocamento duplo
  )
}
