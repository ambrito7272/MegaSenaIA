# MegaSena IA

Aplicativo Android (Kotlin + Jetpack Compose + Material 3 + Room, MVVM) de **análise estatística**
da Mega Sena com geração de combinações otimizadas por restrições e pontuação composta.

> ## ⚠️ AVISO DE RESPONSABILIDADE
> Este aplicativo utiliza modelos matemáticos para análise estatística, mas **NÃO pode garantir
> acertos na loteria**. A Mega Sena é um jogo de azar onde cada sorteio é independente e todos os
> números têm probabilidade teórica igual (probabilidade de sena: 1 em 50.063.860). Os modelos são
> ferramentas educacionais de análise de dados — qualquer backtesting honesto mostra desempenho
> equivalente ao acaso. Jogue com responsabilidade e nunca aposte mais do que pode perder.

## Funcionalidades

- **Base histórica** carregada de `assets/sorteios.csv` (resultados oficiais da Caixa) para o Room.
- **Estatísticas**: frequência absoluta/relativa, atraso atual, maior atraso, média de intervalos,
  entropia de Shannon por número, quentes/frios.
- **Gerador com 4 modos**: Estatístico, Machine Learning (decay exponencial + coocorrência),
  Híbrido e Aleatório.
- **Restrições combinatórias** validadas: soma 150–250, pares/ímpares 2/4–4/2, máx. 2 consecutivos,
  mín. 1 por quadrante, máx. 2 por dezena, primos 2–4.
- **Score composto 0–100**: frequência 20% · ML 25% · bayesiana 20% · temporal 15% ·
  combinatorial 10% · teoria da informação 10%.
- **Simulação Monte Carlo** (10k/100k/500k iterações) com comparação às probabilidades analíticas
  (hipergeométrica: quadra ≈ 1/2.332, quina ≈ 1/154.518, sena = 1/50.063.860).
- **Histórico** com busca; salvamento e compartilhamento de jogos.

## Estrutura

```
app/src/main/kotlin/com/megasenaia/app/
├── MainActivity.kt / MegaSenaApp.kt / MegaSenaViewModel.kt
├── data/
│   ├── MegaRepository.kt
│   └── local/  (Entities, Daos, MegaSenaDatabase, CsvSeeder)
├── domain/
│   ├── model/       (Sorteio, NumeroStats, ModoGeracao, Combinacao, ResultadoSimulacao)
│   ├── statistics/  (StatisticsEngine: frequências, atrasos, entropia)
│   ├── generator/   (ConstraintValidator, Generator, ScoreCalculator, MonteCarloSimulator)
│   └── ml/          (MLPredictionEngine)
└── ui/
    ├── theme/ components/ navigation/
    └── screens/     (Home, Generator, Statistics, History, Simulation)
```

## Populando a base histórica e o modelo ML (obrigatório antes do build)

O app lê `app/src/main/assets/sorteios.csv` (dados) e opcionalmente `lstm_mega.tflite` (LSTM).
Sem o `.tflite`, o modo Machine Learning usa automaticamente o motor heurístico.

```bash
python3 scripts/fetch_resultados.py            # sorteios oficiais desde jan/2014 (~1400)
pip install -r scripts/requirements.txt        # tensorflow-cpu (Codespace)
python3 scripts/train_lstm.py                  # treina, avalia honestamente e exporta o .tflite
```

O treino imprime a avaliação honesta em holdout (média de acertos do top-6 vs. 0,6 do acaso).

## Build

No GitHub Codespace ou Android Studio:

```bash
./gradlew assembleDebug        # APK debug
./gradlew assembleRelease      # APK release (minificado/R8)
```

- minSdk 26 (Android 8.0) · targetSdk 34 · Kotlin 2.0.20 · AGP 8.5.2 · Compose BOM 2024.09

## Privacidade

Nenhum dado pessoal é coletado. Resultados de sorteios são dados públicos. Todo armazenamento é
local (Room/QSettings equivalentes). Sem permissões de internet no APK — os dados entram via CSV.

## Roadmap (próximas fases)

- [x] Testes unitários (validador, estatística, Monte Carlo, ML, próximo sorteio, backtest) — `./gradlew test`
- [x] Backtesting honesto walk-forward exibido na tela Simulação (modelo vs. aleatório vs. esperado teórico 0,6)
- [x] Desdobramentos: fechamento COMPLETO (7→7, 8→28, ... até 12 dezenas) e ECONÔMICO (guloso de cobertura de pares, heurístico)
- [x] Tracking de performance: jogos salvos × sorteios reais (melhor acerto, quadras/quinas/senas, ROI estimado) na tela Meus Jogos
- [x] LSTM real em TensorFlow Lite: treino offline (`scripts/train_lstm.py`), inferência no app com fallback heurístico automático
- [x] Gráficos avançados: heatmap 60×60 de coocorrência de pares (+ top pares vs. esperado teórico) e radar de equilíbrio da combinação
