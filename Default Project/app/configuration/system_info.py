"""Informações estáticas do sistema para a página correspondente."""

import platform
import sys

from PySide6.QtCore import QObject, Property


class SystemInfo(QObject):
    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._data = {
            "appName": "NEODRIVE Cockpit",
            "appVersion": "0.1.0",
            "qtVersion": "",
            "pysideVersion": "",
            "pythonVersion": platform.python_version(),
            "platform": f"{platform.system()} {platform.machine()}",
            "provider": "DemoDataProvider",
        }
        try:
            import PySide6
            from PySide6 import QtCore

            self._data["pysideVersion"] = PySide6.__version__
            self._data["qtVersion"] = QtCore.qVersion()
        except Exception:
            pass

    def _get_info(self) -> dict:
        return dict(self._data)

    info = Property(dict, _get_info, constant=True)
