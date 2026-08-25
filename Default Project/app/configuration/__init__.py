"""Configurações persistidas — três grupos rigorosamente separados:

1. AppSettings    : preferências do aplicativo (unidades, brilho, parâmetros).
2. Esp32Settings  : como conectar ao ESP32 (transporte, endereço, baudrate).
3. Dados instantâneos do veículo: NUNCA persistidos — vivem apenas no
   VehicleBridge (app/services/bridge.py) durante a execução.
"""

from app.configuration.app_settings import AppSettings, PARAMETER_SPECS
from app.configuration.calibration_settings import CalibrationSettings
from app.configuration.esp32_settings import Esp32Settings
from app.configuration.system_info import SystemInfo

__all__ = [
    "AppSettings",
    "CalibrationSettings",
    "Esp32Settings",
    "SystemInfo",
    "PARAMETER_SPECS",
]
