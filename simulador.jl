using Random
using StatsBase
using Dates


# Estados possíveis do clima
estados = ["Ensolarado", "Nublado", "Chuvoso"]

# Matriz de transição de probabilidades
matriz_transicao = [
    0.7  0.2  0.1;
    0.3  0.4  0.3;
    0.2  0.3  0.5
]

# Variáveis globais para armazenar os resultados
resultado_simulacao = []
dias_simulados = 0
estado_inicial = 1

# Funções auxiliares
function proximo_estado(matriz, estado_atual)
    probabilidades = matriz[estado_atual, :]
    println("\n📌 Estado atual: $(estados[estado_atual])")
    println("🔢 Probabilidades de transição:")

    for i in 1:length(estados)
        println("  → $(estados[i]): $(round(probabilidades[i], digits=2))")
    end

    proximo = sample(1:length(probabilidades), Weights(probabilidades))
    println("🎯 Próximo estado escolhido: $(estados[proximo])\n")
    return proximo
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

function mostrar_menu()
    println("\n=== 🌤️ Simulador de Clima com Cadeias de Markov ===")
    println("[1] Começar Simulação")
    println("[2] Mostrar Estatísticas")
    println("[3] Previsão dia a dia com pausa")
    println("[4] Encerrar")
    print("Escolha uma opção: ")
end

function iniciar_simulacao()
    global estado_inicial, dias_simulados, resultado_simulacao

    println("\nEscolha o estado inicial:")
    for (i, estado) in enumerate(estados)
        println("[$i] $estado")
    end
    while true
        print("Digite o número do estado inicial (1 a $(length(estados))): ")
        entrada = readline()
        if tryparse(Int, entrada) in 1:length(estados)
            estado_inicial = parse(Int, entrada)
            break
        else
            println("⚠️ Opção inválida. Tente novamente.")
        end
    end

    print("Quantos dias deseja simular? ")
    dias_simulados = parse(Int, readline())

    Random.seed!(123)
    resultado_simulacao = simular_clima(matriz_transicao, estados, dias_simulados, estado_inicial)

    println("\n✅ Simulação concluída com sucesso!")
end

function mostrar_estatisticas()
    if isempty(resultado_simulacao)
        println("⚠️ Você precisa executar a simulação primeiro.")
        return
    end

    frequencias = countmap(resultado_simulacao)
    println("\n📊 Estatísticas da Simulação:")
    for estado in estados
        println("$estado: $(get(frequencias, estado, 0)) dias")
    end
end


function previsao_com_pausa()
    if isempty(resultado_simulacao)
        println("⚠️ Você precisa executar a simulação primeiro.")
        return
    end

    println("\n🕒 Previsão com pausa:")
    dias_semana = ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"]
    hoje = Dates.now()

    clima_anterior = "Nenhum (estado inicial)"

    for i in 1:dias_simulados
        nome_dia = dias_semana[Dates.dayofweek(hoje + Day(i))]
        clima_atual = resultado_simulacao[i]
        println("Dia $i ($nome_dia): $clima_atual | Clima anterior: $clima_anterior")
        clima_anterior = clima_atual
        sleep(0.5)  # pausa de meio segundo
    end
end

# Loop principal do programa
while true
    mostrar_menu()
    opcao = readline()

    if opcao == "1"
        iniciar_simulacao()
    elseif opcao == "2"
        mostrar_estatisticas()
    elseif opcao == "3"
        previsao_com_pausa()
    elseif opcao == "4"
        println("👋 Encerrando o programa. Até logo!")
        break
    else
        println("❌ Opção inválida. Tente novamente.")
    end
end
