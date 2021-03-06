###################################################################
# UNIVERSIDADE FEDERAL DE MINAS GERAIS                            
# BACHARELADO EM ENGENHARIA DE SISTEMAS                           
# DISCIPLINA: ELE088 Teoria da Decisao                            
# PROFESSOR: Lucas de Souza Batista                               
# ALUNOs: Ariel Domingues, Hernane Braga e Nikolas Fantoni        
# DATA: Setembro/2019                               
# TC1 - Otimizacao mono-objetivo do PCV

solucao_inicial <- function(nome_arquivo, r){
# nome_arquivo: nome do .csv a ser lido e calculado
# r: numero de cidades vizinhas que sao candidatas a serem escolhidas. 
#    Quanto maior o valor r, maior a probabilidade da solucao inicial estar longe do ótimo
#    local gerado por uma solução totalmente gulosa.
     
# vetor_resultado: retorno da funcao com a solucao inicial - Retornado apenas linhas l2 e l3, ordenadas a partinha de l1
                   # Linha 1: Cidade atual [i]
                   # Linha 2: Cidade escolhida [j]
                   # Linha 3: Custo de i ate j

# Carregar dados
{

dados <- as.matrix(read.csv( nome_arquivo, sep=',' ,header = FALSE ))
dados[dados == 0] <- Inf # Define como infinito as cidades que vão para elas mesmas.
                         # Inf também sera usada para definir se uma cidade já foi visitada 
}

# Caminho a partir da cidade 1
{
n <- length(dados[,1])
cidade_atual <- 1        # Cidade inicial = 1
vetor_result <- matrix(0, nrow = 3, ncol = n)

vetor_aux <- matrix(0, nrow = 2, ncol = n)
vetor_aux[1,] <- seq(1, n, 1) 
vetor_aux[2,] <- dados[cidade_atual, ] 

vetor_aux <- vetor_aux[,order(vetor_aux[2,])] # Ordena o vetor 
idx <- round(runif(1,1,r))  # Escolha aleatoria entre as r cidades mais proximas

vetor_result[1,1] <- cidade_atual     # indice Cidade atual [i]
vetor_result[2,1] <- vetor_aux[1,idx] # indice da cidade escolhida [j]
vetor_result[3,1] <- vetor_aux[2,idx] # Custo de ir de i -> j

cidade_atual <- vetor_aux[1,idx]
dados[,cidade_atual] <- Inf # Marca a cidade escolhida como visitada
}

# Calculo da solucao da 2 cidade ate n-1
vetor_aux <- matrix(0, nrow = 2, ncol = n-1) # Novo vetor auxiliar, excluindo a cidade 1 (inicial)
for (i in 2:(n-1)){

  vetor_aux[1,] <- seq(2, n, 1) #Preencendo a linha 1 com os indices das cidades
  vetor_aux[2,] <- dados[cidade_atual, 2:n] #Preenchendo a linha 2 com os custos das cidades
  
  vetor_aux <- vetor_aux[,order(vetor_aux[2,])] 
  
  #Gera indice aleatorino entre 1 e m considerando nao pegar infinito e os piores resultados no fim do algoritmo
  m <- r
  if(i <= n-4){ idx <- round(runif(1,1,m)) }
  else if(i == n-3){ idx <- round(runif(1,1,2)) }
  else{ idx <- 1 }

  if(is.infinite(vetor_aux[2,idx]) == TRUE){ idx <- 1 } # Se solu??o for j? visita, escolhe a mais pr?xima 

  # Preenche vetor resposta
  vetor_result[1,i] <- cidade_atual
  vetor_result[2,i] <- vetor_aux[1,idx] 
  vetor_result[3,i] <- vetor_aux[2,idx]
  
  cidade_atual <- vetor_aux[1,idx]
  dados[,cidade_atual] <- Inf # Marca a cidade escolhida como visitado

}

# Calcula distancia minima para a cidade restante ( cidade inicial 1)
{
vetor_aux <- matrix(0, nrow = 2, ncol = n)
vetor_aux[1,] <- seq(1, n, 1) 
vetor_aux[2,] <- dados[cidade_atual, 1:n] 

vetor_aux <- vetor_aux[,order(vetor_aux[2,])] # Ordena vetor pelo valor de custo

vetor_result[1,n] <- cidade_atual
vetor_result[2,n] <- vetor_aux[1,1] 
vetor_result[3,n] <- vetor_aux[2,1] 

}


vetor_result <- vetor_result[,order(vetor_result[1,])] # Ordena matriz pela linha 1

return(vetor_result[2:3,]) 

}
