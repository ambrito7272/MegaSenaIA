"""Bootstrap da aplicação NEODRIVE."""

import os
import sys
from pathlib import Path

from app.communication import CommunicationService
from app.configuration import (
    AppSettings,
    CalibrationSettings,
    Esp32Settings,
    SystemInfo,
)
from app.data import DemoDataProvider
from app.diagnostics import DiagnosticsService
from app.services.bridge import VehicleBridge

QML_DIR = Path(__file__).resolve().parents[2] / "qml"


def run() -> int:
    try:
        from PySide6.QtGui import QGuiApplication
        from PySide6.QtQml import QQmlApplicationEngine
    except ImportError:
        print("PySide6 nao instalado. Execute: pip install -r requirements.txt")
        return 1

    app = QGuiApplication(sys.argv)

    provider = DemoDataProvider()
    app_settings = AppSettings()
    esp32_settings = Esp32Settings()
    system_info = SystemInfo()
    comms = CommunicationService(esp32_settings)
    calibration = CalibrationSettings()
    bridge = VehicleBridge(provider, calibration=calibration)
    diagnostics = DiagnosticsService(provider)

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("vehicle", bridge)
    engine.rootContext().setContextProperty("appSettings", app_settings)
    engine.rootContext().setContextProperty("esp32Settings", esp32_settings)
    engine.rootContext().setContextProperty("systemInfo", system_info)
    engine.rootContext().setContextProperty("comms", comms)
    engine.rootContext().setContextProperty("calibration", calibration)
    engine.rootContext().setContextProperty("diag", diagnostics)
    engine.addImportPath(str(QML_DIR))

    main_qml = QML_DIR / "Main.qml"
    if not main_qml.exists():
        print(f"Main.qml nao encontrado: {main_qml}")
        return 1
    engine.load(main_qml)

    if not engine.rootObjects():
        print("Falha ao carregar a interface QML.")
        return 1

    provider.start()

    screenshot_path = os.environ.get("NEODRIVE_SCREENSHOT", "")
    if screenshot_path:
        from PySide6.QtCore import QTimer

        def _grab():
            import shiboken6
            from PySide6.QtQuick import QQuickWindow

            base = engine.rootObjects()[0]
            window = shiboken6.wrapInstance(shiboken6.getCppPointer(base)[0], QQuickWindow)
            if window is None:
                print("NEODRIVE_SCREENSHOT: janela nao disponivel")
                app.quit()
                return
            size_spec = os.environ.get("NEODRIVE_SCREENSHOT_SIZE", "1280x720")
            try:
                w_str, h_str = size_spec.lower().split("x")
                window.resize(int(w_str), int(h_str))
            except ValueError:
                window.resize(1280, 720)
            image = window.grabWindow()
            image.save(screenshot_path)
            print(f"Screenshot salvo em: {screenshot_path} ({size_spec})")
            app.quit()

        QTimer.singleShot(2500, _grab)

    try:
        result = app.exec()
    finally:
        provider.stop()
    return result
