using Random
using StatsBase
using Dates

estados = ["Livre", "Moderado", "Congestionado"]

# Matriz de transição para o tráfego
matrizes_cidade = Dict(
    "Salvador" => [
        0.1  0.3  0.6;  # Livre: alta chance de virar congestionado
        0.1  0.4  0.5;  # Moderado: tende a congestionado
        0.05 0.25 0.7   # Congestionado: tende a continuar
    ],
    "Feira de Santana" => [
        0.2  0.6  0.2;  # Livre: tende a virar moderado
        0.1  0.6  0.3;  # Moderado: permanece
        0.1  0.5  0.4   # Congestionado: melhora um pouco
    ],
    "Vitória da Conquista" => [
        0.7  0.2  0.1;  # Livre: permanece
        0.5  0.4  0.1;  # Moderado: melhora
        0.4  0.4  0.2   # Congestionado: melhora
    ]
)

# Variáveis globais para armazenar os resultados
resultado_simulacao = []
intervalos_simulados = 0
estado_inicial = 1
hora_inicial = 0
cidade_selecionada = ""

# Funções auxiliares
function proximo_estado(matriz, estado_atual)
    probabilidades = matriz[estado_atual, :]
    println("\nEstado atual: $(estados[estado_atual])")
    println("Probabilidades de transição:")

    for i in 1:length(estados)
        println("  → $(estados[i]): $(round(probabilidades[i], digits=2))")
    end

    proximo = sample(1:length(probabilidades), Weights(probabilidades))
    println("Próximo estado escolhido: $(estados[proximo])\n")
    return proximo
end

function simular_trafego(matriz, estados, intervalos, estado_inicial)
    trafego = []
    estado = estado_inicial

    for _ in 1:intervalos
        push!(trafego, estados[estado])
        estado = proximo_estado(matriz, estado)
    end

    return trafego
end

function mostrar_menu()
    println("\n=== Simulador de Tráfego com Cadeias de Markov ===")
    println("[1] Começar Simulação")
    println("[2] Mostrar Estatísticas")
    println("[3] Previsão com pausa (a cada 30 min)")
    println("[4] Encerrar")
    print("Escolha uma opção: ")
end

function iniciar_simulacao()
    global estado_inicial, intervalos_simulados, resultado_simulacao, hora_inicial, matriz_transicao, cidade_selecionada

    println("\nEscolha a cidade para simular o tráfego:")
    println("[1] Salvador")
    println("[2] Feira de Santana")
    println("[3] Vitória da Conquista")

    while true
        print("Digite o número da cidade: ")
        entrada = readline()
        if entrada == "1"
            cidade_selecionada = "Salvador"
            break
        elseif entrada == "2"
            cidade_selecionada = "Feira de Santana"
            break
        elseif entrada == "3"
            cidade_selecionada = "Vitória da Conquista"
            break
        else
            println("Opção inválida. Tente novamente.")
        end
    end

    matriz_transicao = matrizes_cidade[cidade_selecionada]
    println("Cidade selecionada: $cidade_selecionada")

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
            println("Opção inválida. Tente novamente.")
        end
    end

    while true
        print("Digite a hora inicial (formato HH, entre 00 e 23): ")
        entrada = readline()
        if tryparse(Int, entrada) in 0:23
            hora_inicial = parse(Int, entrada)
            break
        else
            println("Hora inválida. Tente novamente.")
        end
    end

    print("Quantas horas deseja simular? ")
    horas = parse(Int, readline())
    intervalos_simulados = horas * 2 + 1

    Random.seed!(123)
    resultado_simulacao = simular_trafego(matriz_transicao, estados, intervalos_simulados, estado_inicial)

    println("\nSimulação concluída com sucesso!")
end

function mostrar_estatisticas()
    if isempty(resultado_simulacao)
        println("Você precisa executar a simulação primeiro.")
        return
    end

    println("\n=== Estatísticas da Simulação ===")
    println("Cidade simulada: $cidade_selecionada\n")

    frequencias = countmap(resultado_simulacao)
    for estado in estados
        println("$estado: $(get(frequencias, estado, 0)) intervalos de 30 min")
    end
end

function previsao_com_pausa()
    if isempty(resultado_simulacao)
        println("Você precisa executar a simulação primeiro.")
        return
    end

    println("\n=== Previsão com pausa (30 min cada) ===")
    println("Cidade simulada: $cidade_selecionada\n")

    agora = now()
    horario_atual = DateTime(Dates.year(agora), Dates.month(agora), Dates.day(agora), hora_inicial, 0)

    estado_anterior = "Nenhum (estado inicial)"

    for i in 1:intervalos_simulados
        estado_atual = resultado_simulacao[i]
        println("Horário $(Dates.format(horario_atual, "HH:MM")): $estado_atual | Estado anterior: $estado_anterior")
        estado_anterior = estado_atual
        horario_atual += Minute(30)
        sleep(0.5)
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
        println("Encerrando o programa. Até logo!")
        break
    else
        println("Opção inválida. Tente novamente.")
    end
end
