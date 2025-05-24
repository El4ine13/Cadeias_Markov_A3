using Random
using StatsBase


estados = ["Ensolarado", "Nublado", "Chuvoso"]

matriz_transicao = [
    0.7  0.2  0.1;
    0.3  0.4  0.3;
    0.2  0.3  0.5
]


function proximo_estado(matriz, estado_atual)
    probabilidades = matriz[estado_atual, :]
    return sample(1:length(probabilidades), Weights(probabilidades))
end


function simular_clima(matriz, estados, dias, estado_inicial)
    clima = []
    estado = estado_inicial
    
    for _ in 1:dias
        push!(clima, estados[estado])
        estado = proximo_estado(matriz, estado)
    end

    return clima
end


Random.seed!(123)
dias_simulados = 30            
estado_inicial = 1

resultado = simular_clima(matriz_transicao, estados, dias_simulados, estado_inicial)


println("📅 Previsão do clima para os próximos $dias_simulados dias:")
for (i, clima) in enumerate(resultado)
    println("Dia $i: $clima")
end
