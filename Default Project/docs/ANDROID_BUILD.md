# NEODRIVE — Build Android (APK)

Guia para transformar o código-fonte Python + Qt/QML em APK instalável em
smartphone, tablet e centrais multimídia Android.

> ⚠️ Ferramenta oficial (`pyside6-android-deploy`) só roda em **Linux**.
> Por isso o build deve acontecer no **GitHub Codespace** ou **Actions** —
> nunca no Windows local. Isso também protege seu HD.

---

## 1. Stack recomendada

| Componente | Versão | Observação |
|---|---|---|
| Python | 3.11.x (aceita 3.10+) | O entry point **deve se chamar `main.py`** ✓ (já é) |
| PySide6 / Qt | 6.10+ (testado pela comunidade até 6.11) | Módulos usados pelo NEODRIVE suportados no Android: QtCore, QtGui, QtQml, QtQuick, QtQuickControls2 |
| JDK | **17** | Alinhado com a toolchain atual do Qt |
| Android SDK | platform-tools · platforms;android-34 · build-tools;35.0.0 | Versões pares com o Qt usado |
| Android NDK | r26 (26.1.10909125) p/ Qt 6.10 · r27c p/ PySide6 6.11 | Seguir a tabela Qt-for-Android da versão escolhida |
| Extras | buildozer + python-for-android (bootstrap Qt) | Instalados automaticamente pelo fluxo abaixo |

---

## 2. Como funciona o pipeline

```
código-fonte (main.py + app/ + qml/)
        ↓
wheels PySide6/shiboken6 cross-compilados p/ Android (uma vez por arquitetura)
        ↓
pyside6-android-deploy  →  gera buildozer.spec  →  python-for-android
        ↓
APK (modo debug)  ou  AAB (modo release)
```

Arquiteturas: `aarch64` (celulares/tablets modernos), `armv7a`, `x86_64`, `i686`.
O tool **não** faz multi-arquitetura num único pacote — gerar um APK por alvo.

---

## 3. Passo a passo no Codespace

### 3.1 Preparar ambiente (uma vez)

```bash
sudo apt-get update && sudo apt-get install -y openjdk-17-jdk
python3 -m pip install --upgrade pip

git clone https://code.qt.io/pyside/pyside-setup ~/pyside-setup
cd ~/pyside-setup
git checkout <versão-PySide6-escolhida>   # ex.: 6.10.0
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
pip install -r tools/cross_compile_android/requirements.txt
```

### 3.2 Baixar SDK/NDK (uma vez)

```bash
python tools/cross_compile_android/main.py --download-only --auto-accept-license
# SDK: ~/.pyside6_android_deploy/android-sdk/
# NDK: ~/.pyside6_android_deploy/android-ndk/<versão>/
```

### 3.3 Cross-compilar os wheels (uma vez por arquitetura/Qt)

```bash
python tools/cross_compile_android/main.py \
    --plat-name=aarch64 \
    --qt-install-path=<caminho-do-qt> \
    --auto-accept-license --skip-update
# wheels saem em ~/pyside-setup/dist/
```

### 3.4 Gerar o APK do NEODRIVE

```bash
cd /workspaces/NEODRIVE
source ~/pyside-setup/venv/bin/activate

pyside6-android-deploy \
    --name NEODRIVE \
    --wheel-pyside=~/pyside-setup/dist/PySide6-*-android_aarch64.whl \
    --wheel-shiboken=~/pyside-setup/dist/shiboken6-*-android_aarch64.whl \
    --ndk-path=~/.pyside6_android_deploy/android-ndk/<versão> \
    --sdk-path=~/.pyside6_android_deploy/android-sdk/
```

Saída: arquivo `.apk` no diretório do projeto (modo debug padrão).

---

## 4. Instalação nos dispositivos

1. Copiar o `.apk` (download pelo navegador do GitHub ou `adb push`);
2. No aparelho: permitir "Instalar apps desconhecidos" para o gerenciador usado;
3. Abrir o APK e instalar.

| Dispositivo | Observações |
|---|---|
| Smartphone | Alvo principal; testar retrato/paisagem e botão voltar |
| Tablet | Layout paisagem completo; gauges maiores se aproveitam bem |
| Central multimídia | Se Android 8+ e tela widescreen: usar APK `aarch64` ou `armv7a` conforme o hardware; fixar brilho alto |

Para publicar em loja (futuro): gerar modo **release/AAB** com assinatura própria.

---

## 5. Pontos de atenção conhecidos

- **Caminhos QML**: hoje `app/core/application.py` resolve `qml/` relativo ao
  `__file__`. No APK os assets são empacotados — pode ser necessário embutir
  os QML via recursos (qrc) ou ajustar o caminho após o primeiro teste real.
- **Brilho**: overlay simulado; controle real de brilho exigirá API Android
  específica (Fase L+/ajustes).
- **Botão voltar do Android**: ainda não tratado — validar no primeiro APK.
- **Desempenho**: 7 gauges vetoriais com MSAA — medir FPS num aparelho real;
  reduzir `layer.samples` se necessário.
- **Permissões Bluetooth**: só serão necessárias na Fase L (o stub não pede nada).

---

## 6. Checklist do primeiro build (executar no Codespace)

1. [ ] App roda no desktop do Codespace (`python main.py`) sem erros;
2. [ ] Wheels cross-compilados sem erro para `aarch64`;
3. [ ] `pyside6-android-deploy` conclui e produz APK;
4. [ ] APK instala no celular;
5. [ ] Cockpit abre em modo DEMO, gauges animam;
6. [ ] Rotação retrato/paisagem reorganiza o layout;
7. [ ] Menu navega nas 8 páginas;
8. [ ] Voltar do Android fecha página/menu (corrigir se fechar o app);
9. [ ] Brilho/unidades/calibração persistem entre reinícios do app.
