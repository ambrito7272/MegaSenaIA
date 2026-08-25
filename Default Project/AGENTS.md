# NEODRIVE — Regras do Projeto (AGENTS.md)

Digital Cockpit automotivo profissional em **Python + Qt 6 + Qt Quick/QML**, com destino final **Android** (smartphone, tablet, central multimídia, telas automotivas) entregue como **APK**.

Sempre responder em **português (pt-BR)**.

---

## 1. Restrições absolutas

1. **NÃO instalar nada no computador local** sem autorização explícita do usuário: Python, PySide6, Qt, Android SDK, NDK, JDK, IDEs ou qualquer ferramenta grande. O HD tem pouco espaço.
2. **NÃO baixar componentes grandes** sem autorização explícita.
3. **NÃO alterar a arquitetura visual definida** nem substituir Python+Qt6+QML sem justificativa técnica prévia e aprovação.
4. **NÃO implementar hardware ainda**: ESP32 físico, Bluetooth real, CAN, OBD2, sensores físicos — apenas arquitetura abstrata preparada para recebê-los (Fase L, futura).
5. Nunca commitar sem pedido explícito.

## 2. Arquitetura obrigatória

```
INTERFACE (QML/Qt Quick) → APLICAÇÃO → SERVIÇOS → MODELO DE DADOS → DATA PROVIDER → TRANSPORTE → HARDWARE
```

- Lógica de comunicação/hardware **nunca** dentro de componentes QML.
- A interface não sabe a origem dos dados (rpm, speed, temperature, oilPressure, batteryVoltage, vacuum, amperage, fuel, trip, clock).
- Abstração: `DataProvider` → `DemoDataProvider` | `ESP32DataProvider` (futuro).
- Comunicação futura: `CommunicationService → Transport Layer → Bluetooth/Serial/Wi-Fi → ESP32`, com `BluetoothTransport`, `SerialTransport`, `WifiTransport` implementando interface comum (`app/communication/transports/`).
- Veículo alvo: **carro de 1989** — sem OBD2, sem CAN, sem ECU moderna. Sinais elétricos/sensores via ESP32 com condicionamento.

## 3. Modo DEMO

`DemoDataProvider` deve simular dados reais sem hardware:
- RPM: 0–8000 (passos de 1000)
- Velocidade: 0–220 (0, 40, 80, 120, 140, 160, 180, 200, 220)
- Simular também temperatura, pressão de óleo, tensão de bateria, vácuo, amperagem, combustível, estados e alertas.

## 4. Layout visual fixo

- **Velocímetro à ESQUERDA**
- **Manômetros secundários no CENTRO**: temperatura, pressão do óleo, bateria, vacuômetro, amperímetro
- **Tacômetro à DIREITA**
- Combustível: barra horizontal/vertical conforme o layout.

### Regra das cores dos arcos (obrigatória)
Luminosidade **constante** — não aumentar brilho com valor. O arco avança e muda gradualmente de cor:
`amarelo → amarelo-dourado → amarelo/laranja → laranja → laranja-avermelhado → vermelho`.
Implementação preferível: interpolação de matiz (hue) com saturação e luminosidade fixas (`Qt.hsla`).

### Ponteiros
Base grossa, corpo afunilado, ponta fina, geometria vetorial, movimento suave com interpolação, sem movimentos bruscos; rastro luminoso apenas se extremamente discreto.

## 5. Responsividade (obrigatória)

Funcionar em smartphone, tablet, multimídia, telas grandes, proporções variadas, orientação horizontal e vertical quando possível. **Nunca**: elementos cortados, sobreposição, números cortados, ponteiros fora da escala, conteúdo fora da tela, scroll involuntário. Usar Qt Quick, bindings, layouts, anchors, componentes reutilizáveis, animações, Scene Graph, elementos vetoriais — nunca tela fixa para uma resolução.

## 6. Compatibilidade Android

- Evitar dependências exclusivas de Windows, caminhos absolutos, APIs do Windows e bibliotecas que dificultem o build Android.
- Empate técnico → escolher a opção com melhor compatibilidade Android.
- Baixa latência: timestamps, interpolação, animação suave, controle de frequência, filtragem sem atraso perceptível.

## 7. Configurações — separação rigorosa

Separar claramente: **configurações do aplicativo** / **configurações do ESP32** / **dados instantâneos do veículo**.

Estrutura do MENU:
`Configurações · Unidades · Calibração · Brilho · Comunicação · Diagnóstico · Parâmetros · Informações do sistema`

Página "Comunicação" inicialmente mostra apenas `ESP32 — Não conectado`.

## 8. Estrutura de diretórios alvo

```
NEODRIVE/
├── main.py
├── requirements.txt
├── README.md
├── app/{core,domain,data,services,communication,configuration,diagnostics}/
├── qml/{Main.qml,Dashboard,Gauges,Menu,Settings,Communication,Calibration,Diagnostics}/
├── assets/
├── docs/            # arquitetura e build Android
└── tests/
```

## 9. Ordem de execução das fases

A (estrutura) → B (modelo de dados) → C (DataProvider) → D (DemoDataProvider) → E (componentes QML) → F (Dashboard) → G (Menu) → H (Configurações) → I (Comunicação abstrata) → J (Diagnóstico+Calibração) → K (docs de build Android).
**Fase L (futura, só com autorização)**: ESP32 → Bluetooth → sensores → CAN → OBD2 → dados reais.

Ao concluir cada fase: apresentar resumo (estrutura criada, arquivos criados), **informar a estimativa de tempo/horas da fase seguinte** (o projeto será feito em vários dias) e aguardar o usuário antes da fase seguinte.

## 11. Controle de progresso entre sessões

- O projeto avança em **múltiplas sessões/dias**. Ao iniciar qualquer sessão, verificar esta seção e continuar exatamente de onde parou.
- Manter a seção "Estado atual" sempre atualizada ao concluir cada fase (marcar concluída, listar arquivos-chave).
- Nunca refazer fases já concluídas; nunca iniciar a próxima sem autorização do usuário.

## 10. Estado atual

- [x] **Fase A — CONCLUÍDA** (estrutura de diretórios criada; main.py multiplataforma; README; docs/ARCHITECTURE.md). Validação estática (sem ambiente instalado).
- [x] **Fase B — CONCLUÍDA** (`app/domain/`: VehicleData com ranges e timestamps p/ interpolação; DataField; Alert/AlertSeverity; units.py com conversões km/h↔mph, °C↔°F, bar↔psi, kPa↔inHg). Validação estática.
- [x] **Fase C — CONCLUÍDA** (`app/data/data_provider.py`: DataProvider ABC com subscribe/publish thread-safe, ProviderState; sem dependência de Qt). Validação estática.
- [x] **Fase D — CONCLUÍDA** (`app/data/demo_provider.py`: simulação 20 Hz em thread; ciclo acelera/cruza/desacelera por marchas; temperatura/óleo/bateria/vácuo/amperagem/combustível/trip coerentes; alertas de superaquecimento, óleo, bateria e reserva). Correção aplicada: classe Alert criada em app/domain/alerts.py (faltava desde a Fase B).
- [x] **Fase E — CONCLUÍDA** (`qml/Theme.js`; `qml/Gauges/{ArcGauge,GaugeScale,Needle}.qml`; `qml/Dashboard/FuelBar.qml`). Revisado por @reviewer (1ª rodada REPROVADO: import quebrado no FuelBar, fórmula do ponteiro invertida; corrigido e APROVADO COM RESSALVAS). Validação estática — Behaviors em PathAngleArc a confirmar na 1ª execução (Fase F).
- [x] **Fase F — CONCLUÍDA** (`app/services/bridge.py` ponte 30 Hz thread-safe; `app/core/application.py` bootstrap; `main.py` enxuto; `qml/Main.qml`; `qml/Dashboard/{DashboardView,GaugeCell,CenterPanel}.qml`). Layout fixo obrigatório + retrato/paisagem. Revisado por @reviewer (REPROVADO na 1ª rodada: import do ArcGauge p/ Theme.js, NaN no arranque, banner; corrigido — APROVADO COM RESSALVAS). **Pendente 1ª execução real no Codespace**: Behaviors em PathAngleArc, rotação Loader, sobreposição trip/clock×fuel em retrato.
- [x] **Fase G — CONCLUÍDA** (`qml/Main.qml` navegação por Loader; `qml/Menu/{MainMenu,PageShell}.qml`; 8 páginas placeholder navegáveis; Comunicação mostra "ESP32 — Não conectado"). Revisado (@reviewer): REPROVADO 1ª rodada (import "Dashboard" faltando em Main.qml, `title` duplicado de Page, binding loops) → corrigido → APROVADO COM RESSALVAS. Checklist QML adicionada ao AGENTS.md (lição permanente). Pendente execução real: botão voltar Android, sobreposição menuButton×velocímetro.
- [x] **Fase H — CONCLUÍDA** (`app/configuration/`: AppSettings (unidades/brilho/parâmetros via QSettings), Esp32Settings, SystemInfo; páginas reais de Configurações/Unidades/Brilho/Parâmetros/Informações; overlay de brilho no Main.qml). Revisado (@reviewer): REPROVADO 1ª rodada (`const=True` inexistente em PySide6 — é `constant=`, `parent.entries` não resolve, id `root` fora de escopo, getParameter não invocável de QML) → corrigido → APROVADO COM RESSALVAS. Separação app/ESP32/dados-instantâneos garantida.
- [x] **Fase I — CONCLUÍDA** (`app/communication/`: Transport ABC thread-safe + CommunicationService com máquina de estados; stubs honestos Bluetooth/Serial/Wi-Fi (is_available=False); página Comunicação real com status/conectar). Revisado (@reviewer): REPROVADO 1ª rodada (`state` sombreava Item.state, dot preso semi-transparente, baudrateChanged desconectado) → corrigido → APROVADO COM RESSALVAS. **Limitação documentada p/ Fase L**: callbacks de estado chegam na thread do transporte — será preciso marshal para a thread principal (queued/invokeMethod); open() síncrono.
- [x] **Fase J — CONCLUÍDA** (`app/configuration/calibration_settings.py` offset/ganho por sinal persistido e aplicado no bridge com clamp aos FIELD_RANGES; `app/diagnostics/diagnostics_service.py` lê valores BRUTOS direto do provider com dedup; páginas Diagnóstico (faixas, ok/falha ao vivo) e Calibração (sliders ganho/offset + reset + preview)). Revisado (@reviewer): REPROVADO 1ª rodada (bootstrap sem instanciações — meu erro de edição, ListView resetado a 4 Hz, calibração podia empurrar ponteiro p/ fora da escala) → corrigido → APROVADO COM RESSALVAS.
- [x] **Fase K — CONCLUÍDA** (`docs/ANDROID_BUILD.md`: stack recomendada, pipeline pyside6-android-deploy→buildozer→p4a, passo a passo no Codespace, instalação em celular/tablet/multimídia, pontos de atenção, checklist do 1º build). Dados CONFIRMADOS na doc oficial Qt (tool só roda em Linux → build no Codespace/Actions).
- **CICLO A–K COMPLETO.**
- [x] **1ª EXECUÇÃO REAL NO CODESPACE — APROVADA** (PySide6 6.11.2/Qt 6.11, modo offscreen + screenshot 1280×720): app carrega limpo, DEMO fluindo (RPM/óleo/bateria/vácuo/amp/temp/combustível coerentes), rampa de cor e ponteiros corretos, layout fixo ok. Correções feitas ao vivo: exports de pacote (CalibrationSettings, domain), ORGANIZATION import, ShapePath wrapper (capStyle), radiusX/radiusY (API Qt 6.10+), halo via alpha, race no start do provider. Modo foto: NEODRIVE_SCREENSHOT=caminho. **Pendente**: polimento cosmético (rótulos apertados no velocímetro, largura do centro), teste de rotação Loader, botão voltar Android (no APK).
- Próximos passos: polimento cosmético + 1º APK (docs/ANDROID_BUILD.md) + Fase L (hardware — SOMENTE com autorização explícita).
- Ambiente local (Python/PySide6/SDK) não instalado por decisão do usuário — desenvolvimento do código aqui, testes/build no GitHub Codespace (`github.com/ambrito7272/NEODRIVE`).

## 12. Disciplina de engenharia (vale para todo o projeto)

### Triagem de complexidade
- **N1** (ajuste simples): fluxo direto, sem cerimônia.
- **N2** (vários arquivos): planejar → implementar → testar/verificar.
- **N3** (arquitetura/refatoração grande): o acima + revisão com `@reviewer` antes de considerar concluído.
- **N4** (problema crítico): N3 + `@researcher` para investigação e plano apresentado ao usuário antes de executar.

### Anti-invenção (obrigatório)
- Nunca inventar APIs, parâmetros, versões, comandos ou configurações.
- Classificar afirmações técnicas: CONFIRMADO / PROVÁVEL / HIPÓTESE / DESCONHECIDO quando houver dúvida relevante.
- Em caso de dúvida sobre API/recurso → verificar documentação via web antes de escrever.

### Fluxo de erro
Reproduzir → evidências → hipótese → experimento → causa raiz → correção → teste. Nunca repetir a mesma tentativa cegamente; se falhar 2x, mudar de hipótese.

### Verificação
- Nunca afirmar que algo funciona sem evidência (execução, teste, lint ou build).
- Sem ambiente instalado (fase atual): validar por leitura criteriosa + `@reviewer`; registrar que a validação foi estática.

### Economia de contexto
- Ler apenas o necessário; buscas em paralelo; evitar re-ler arquivos já conhecidos nesta sessão.

### Checklist QML (lição das fases E–G — checar em TODO arquivo novo)
- Imports relativos: Theme.js a partir de subpasta é `"../Theme.js"`; componentes de diretório irmão exigem `import "Pasta"`.
- Não redeclarar propriedades herdadas de Controls (ex.: Page já tem `title`).
- Evitar bindings que dependam da própria dimensão implícita do posicionador (loops).

### Autoavaliação pós-tarefa importante
Responder brevemente: houve retrabalho? contexto desperdiçado? solução mais simples existia? Registrar lição aplicável na seção "Estado atual"/docs se for permanente.
