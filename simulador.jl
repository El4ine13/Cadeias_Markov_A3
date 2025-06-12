using Random
using StatsBase
using Dates

estados = ["Livre", "Lento", "Congestionado", "Acidente"]

matrizes_cidade = Dict(
    "Salvador" => [
        0.20  0.30  0.30  0.20;
        0.10  0.20  0.50  0.20;
        0.10  0.20  0.50  0.20;
        0.10  0.10  0.30  0.50
    ],
    "Feira de Santana" => [
        0.30  0.40  0.20  0.10;
        0.10  0.30  0.40  0.20;
        0.10  0.20  0.50  0.20;
        0.10  0.10  0.30  0.50
    ],
    "Lauro de Freitas" => [
        0.40  0.30  0.20  0.10;
        0.20  0.40  0.30  0.10;
        0.20  0.30  0.30  0.20;
        0.10  0.20  0.30  0.40
    ]
)

resultado_simulacao = []
resultado_cidades = []
intervalos_simulados = 0
estado_inicial = 1
hora_inicial = 0

function proximo_estado(matriz, estado_atual)
    probabilidades = matriz[estado_atual, :]
    proximo = sample(1:length(probabilidades), Weights(probabilidades))
    return proximo
end

function escolher_cidade()
    println("\nEscolha a cidade para este intervalo:")
    println("[1] Salvador")
    println("[2] Feira de Santana")
    println("[3] Lauro de Freitas")

    while true
        print("Digite o número da cidade: ")
        entrada = readline()
        if entrada == "1"
            return "Salvador"
        elseif entrada == "2"
            return "Feira de Santana"
        elseif entrada == "3"
            return "Lauro de Freitas"
        else
            println("Opção inválida. Tente novamente.")
        end
    end
end

function simular_trafego(estados, intervalos, estado_inicial)
    trafego = []
    cidades = []
    estado = estado_inicial

    println("\nEscolha a cidade inicial para começar a simulação:")
    cidade = escolher_cidade()

    for i in 1:intervalos
        push!(trafego, estados[estado])
        push!(cidades, cidade)

        total_minutos = (i - 1) * 30
        hora = hora_inicial + div(total_minutos, 60)
        minuto = mod(total_minutos, 60)
        println("\n[$(i)] Intervalo das $(Dates.format(Time(hora % 24, minuto), "HH:MM"))")
        println("Resultado: $(estados[estado]) na cidade $cidade")

        if i < intervalos
            cidade = escolher_cidade()
            matriz = matrizes_cidade[cidade]
            estado = proximo_estado(matriz, estado)
        end
    end

    return trafego, cidades
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
    global estado_inicial, intervalos_simulados, resultado_simulacao, hora_inicial, resultado_cidades

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
    resultado_simulacao, resultado_cidades = simular_trafego(estados, intervalos_simulados, estado_inicial)

    println("\nSimulação concluída com sucesso!")
end

function mostrar_estatisticas()
    if isempty(resultado_simulacao)
        println("Você precisa executar a simulação primeiro.")
        return
    end

    println("\n=== Estatísticas da Simulação ===\n")
    freqs = countmap(zip(resultado_simulacao, resultado_cidades))

    for cidade in keys(matrizes_cidade)
        println("Cidade: $cidade")
        for estado in estados
            total = get(freqs, (estado, cidade), 0)
            println("  $estado: $total vezes")
        end
        println()
    end
end

function previsao_com_pausa()
    if isempty(resultado_simulacao)
        println("Você precisa executar a simulação primeiro.")
        return
    end

    println("\n=== Previsão com pausa (30 min cada) ===")

    agora = now()
    horario_atual = DateTime(Dates.year(agora), Dates.month(agora), Dates.day(agora), hora_inicial, 0)

    for i in 1:intervalos_simulados
        estado = resultado_simulacao[i]
        cidade = resultado_cidades[i]
        println("Horário $(Dates.format(horario_atual, "HH:MM")) → $estado em $cidade")
        horario_atual += Minute(30)
        sleep(0.5)
    end
end

# Loop principal
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
