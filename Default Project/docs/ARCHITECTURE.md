# NEODRIVE — Arquitetura

## Princípio central

A interface **não conhece a origem dos dados**. Toda a lógica de comunicação e hardware vive nas camadas inferiores.

```
INTERFACE (QML/Qt Quick)
        ↓
APLICAÇÃO
        ↓
SERVIÇOS  (bridge p/ QML, settings, calibração, diagnóstico)
        ↓
MODELO DE DADOS (domain)
        ↓
DATA PROVIDER  (DemoDataProvider | ESP32DataProvider futuro)
        ↓
TRANSPORTE     (Bluetooth | Serial | Wi-Fi — interface comum)
        ↓
HARDWARE       (ESP32 → condicionamento → carro 1989)
```

## Regras

1. Componentes QML nunca contêm lógica de comunicação/hardware.
2. `DataProvider` é a única fonte de dados do painel: rpm, speed, temperature, oilPressure, batteryVoltage, vacuum, amperage, fuel, trip, clock.
3. Transportes implementam uma interface comum (`app/communication/transports/`); a aplicação não acopla diretamente a Bluetooth.
4. Configurações separadas em três grupos: aplicativo / ESP32 / dados instantâneos do veículo.

## Modo DEMO

`DemoDataProvider` simula todos os sinais sem hardware:
- RPM: 0–8000 (passos de 1000)
- Velocidade: 0–220 (passos: 40, 80, 120, 140, 160, 180, 200, 220)
- Temperatura, pressão de óleo, bateria, vácuo, amperagem, combustível, estados e alertas.

## Baixa latência

- Timestamps nos dados, interpolação suave no QML, controle de frequência de atualização.
- Filtragem configurada para não introduzir atraso perceptível entre variação real e visual.

## Android

- Sem dependências exclusivas de Windows/desktop; caminhos sempre relativos; empacotamento via PySide6 (Fase K documenta o build APK).
