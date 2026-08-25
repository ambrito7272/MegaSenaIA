# NEODRIVE

Digital Cockpit automotivo profissional em **Python + Qt 6 (Qt Quick/QML)**, com destino final **Android** (smartphone, tablet, central multimídia).

## Visão geral

- Interface QML/Qt Quick responsiva (velocímetro à esquerda, manômetros secundários no centro, tacômetro à direita).
- Modo **DEMO** completo para uso sem hardware.
- Arquitetura em camadas preparada para receber dados reais de um ESP32 (Fase L futura) via Bluetooth/Serial/Wi-Fi.
- Veículo alvo: carro de 1989 — sem OBD2/CAN/ECU moderna; sinais elétricos condicionados pelo ESP32.

## Estrutura

```
main.py                  # ponto de entrada
app/
  core/                  # bootstrap da aplicação
  domain/                # modelo de dados do veículo
  data/                  # DataProvider + DemoDataProvider
  services/              # serviços de aplicação (bridge p/ QML)
  communication/         # CommunicationService + transports (abstrato)
  configuration/         # configurações do app / ESP32
  diagnostics/           # diagnóstico e calibração
qml/                     # interface Qt Quick
assets/                  # recursos visuais
docs/                    # arquitetura e build Android
tests/                   # testes automatizados
```

## Executar (modo demo)

```bash
pip install -r requirements.txt
python main.py
```

## Documentação

- `docs/ARCHITECTURE.md` — arquitetura em camadas e fluxo de dados.
- `docs/ANDROID_BUILD.md` — build Android/APK completo (Fase K).

## Regras do projeto

Consulte `AGENTS.md` para as restrições e convenções obrigatórias.
