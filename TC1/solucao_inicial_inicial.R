
solucao_incial <- function(nome_arquivo){
# nome_arquivo: nome do .csv a ser lido e calculado
# vetor_resultado: retorno da fun��o com solu��o inicial
                   # Linha 1: �ncide da cidade visitada
                   # Linha 2: Custo at� a cidade a ser visitada

# Carregar dados
{
dados <- as.matrix(read.csv( nome_arquivo, sep=',' ,header = FALSE ))
dados[dados == 0] <- Inf # Define como infinito as cidades que v�o para elas mesmas.
                         # Inf tamb�m sera usada para definir se uma cidade j� foi visitada 
}

# Caminho a partir da cidade 1
{
n <- length(dados[,1])
cidade_atual <- 1        # Cidade inicial = 1
vetor_result <- matrix(0, nrow = 2, ncol = n)

vetor_aux <- matrix(0, nrow = 2, ncol = n)
vetor_aux[1,] <- seq(1, n, 1) 
vetor_aux[2,] <- dados[cidade_atual, ] 

vetor_aux <- vetor_aux[,order(vetor_aux[2,])] # Ordena o vetor 
idx <- round(runif(1,1,3))  # Escolha aleat�ria entre as 3 cidades mais pr�ximas

vetor_result[1,1] <- vetor_aux[1,idx] # Coloca cidade no vetor de resposta
vetor_result[2,1] <- vetor_aux[2,idx] # Coloca custo no vetor de resposta

cidade_atual <- vetor_aux[1,idx]
dados[,cidade_atual] <- Inf # Marca a cidade escolhida como visitada
}

# C�lculo da solu��o da 2� cidade at� n-1
vetor_aux <- matrix(0, nrow = 2, ncol = n-1) # Novo vetor auxiliar, excluindo a cidade 1 (inicial)
for (i in 2:(n-1)){

  vetor_aux[1,] <- seq(2, n, 1) #Preencendo a linha 1 com os indices das cidades
  vetor_aux[2,] <- dados[cidade_atual, 2:n] #Preenchendo a linha 2 com os custos das cidades
  
  vetor_aux <- vetor_aux[,order(vetor_aux[2,])] 
  
  #Gera indice aleatorino entre 1 e m considerando nao pegar infinito e os piores resultados no fim do algoritmo
  m <- 3
  if(i <= n-4){ idx <- round(runif(1,1,m)) }
  else if(i == n-3){ idx <- round(runif(1,1,2)) }
  else{ idx <- 1 }

  if(is.infinite(vetor_aux[2,idx]) == TRUE){ idx <- 1 } # Se solu��o for j� visita, escolhe a mais pr�xima 

  # Preenche vetor resposta
  vetor_result[1,i] <- vetor_aux[1,idx] 
  vetor_result[2,i] <- vetor_aux[2,idx]
  
  cidade_atual <- vetor_aux[1,idx]
  dados[,cidade_atual] <- Inf # Marca a cidade escolhida como visitado

}

# Calcula dist�ncia m�nima para a cidade restante (a cidade inicial 1)
{
vetor_aux <- matrix(0, nrow = 2, ncol = n)
vetor_aux[1,] <- seq(1, n, 1) 
vetor_aux[2,] <- dados[cidade_atual, 1:n] 

vetor_aux <- vetor_aux[,order(vetor_aux[2,])] # Ordena vetor pelo valor de custo

vetor_result[1,n] <- vetor_aux[1,1] 
vetor_result[2,n] <- vetor_aux[2,1] 
}

return(vetor_result)

}
