# -----------------------------------------------
# 🌦️ Simulador de Clima usando Cadeias de Markov
# -----------------------------------------------
# Linguagem: Julia
# Autora: Elaine
# Descrição: Simula a previsão do tempo com base em
#           transições probabilísticas entre estados climáticos.
# -----------------------------------------------

using Random           # Para geração aleatória
using StatsBase        # Para usar sample() com pesos (probabilidades)

# 1️⃣ Definição dos estados possíveis
estados = ["Ensolarado", "Nublado", "Chuvoso"]

# 2️⃣ Matriz de Transição de Estados
# Cada linha representa o clima atual
# Cada coluna representa o próximo estado
# As linhas devem somar 1.0 (100%)
matriz_transicao = [
    0.7  0.2  0.1;   # De Ensolarado → Ensolarado (70%), Nublado (20%), Chuvoso (10%)
    0.3  0.4  0.3;   # De Nublado    → Ensolarado (30%), Nublado (40%), Chuvoso (30%)
    0.2  0.3  0.5    # De Chuvoso    → Ensolarado (20%), Nublado (30%), Chuvoso (50%)
]

# 3️⃣ Função para determinar o próximo estado com base nas probabilidades
function proximo_estado(matriz, estado_atual)
    probabilidades = matriz[estado_atual, :]                  # Obtém a linha da matriz
    return sample(1:length(probabilidades), Weights(probabilidades))  # Escolhe o próximo estado baseado em peso
end

# 4️⃣ Função principal de simulação do clima
function simular_clima(matriz, estados, dias, estado_inicial)
    clima = []                        # Lista para guardar os climas simulados
    estado = estado_inicial          # Estado atual (como índice)
    
    for _ in 1:dias
        push!(clima, estados[estado])  # Adiciona o nome do clima atual à lista
        estado = proximo_estado(matriz, estado)  # Atualiza o estado com base na matriz
    end

    return clima
end

# 5️⃣ Executando a simulação
Random.seed!(123)               # Semente para resultados reprodutíveis
dias_simulados = 30             # Número de dias a simular
estado_inicial = 1              # Começa com "Ensolarado" (índice 1 na lista `estados`)

resultado = simular_clima(matriz_transicao, estados, dias_simulados, estado_inicial)

# 6️⃣ Exibindo o resultado final
println("📅 Previsão do clima para os próximos $dias_simulados dias:")
for (i, clima) in enumerate(resultado)
    println("Dia $i: $clima")
end
