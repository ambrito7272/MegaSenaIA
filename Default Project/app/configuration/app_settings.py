"""Configurações do APLICATIVO — persistência multiplataforma via QSettings.

Escopo desta classe: preferências do app apenas (unidades, brilho,
parâmetros de alerta). Configurações de ESP32 ficam em Esp32Settings;
dados instantâneos do veículo NUNCA são persistidos (vivem só no bridge).
"""

from PySide6.QtCore import QObject, Property, QSettings, Signal, Slot

ORGANIZATION = "NEODRIVE"
APPLICATION = "Cockpit"

PARAMETER_SPECS: dict[str, tuple[float, float, float]] = {
    "warnTemp": (95.0, 115.0, 105.0),
    "critTemp": (105.0, 125.0, 115.0),
    "reserveFuel": (5.0, 25.0, 10.0),
    "oilMin": (0.3, 1.2, 0.6),
}


class AppSettings(QObject):
    unitSystemChanged = Signal()
    brightnessChanged = Signal()
    parameterChanged = Signal(str)

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._settings = QSettings(ORGANIZATION, APPLICATION)
        self._unit_system = str(self._settings.value("units/system", "metric"))
        if self._unit_system not in ("metric", "imperial"):
            self._unit_system = "metric"
        self._brightness = self._clamp(self._read_float("display/brightness", 100.0), 20.0, 100.0)
        self._parameters: dict[str, float] = {}
        for name, (_lo, _hi, default) in PARAMETER_SPECS.items():
            raw = self._read_float(f"parameters/{name}", default)
            self._parameters[name] = self._clamp_parameter(name, raw)

    def _read_float(self, key: str, default: float) -> float:
        try:
            return float(self._settings.value(key, default))
        except (TypeError, ValueError):
            return default

    @staticmethod
    def _clamp(value: float, lo: float, hi: float) -> float:
        return max(lo, min(hi, value))

    def _clamp_parameter(self, name: str, value: float) -> float:
        lo, hi, _default = PARAMETER_SPECS[name]
        return self._clamp(value, lo, hi)

    def _get_unit_system(self) -> str:
        return self._unit_system

    def _set_unit_system(self, value: str) -> None:
        if value not in ("metric", "imperial") or value == self._unit_system:
            return
        self._unit_system = value
        self._settings.setValue("units/system", value)
        self.unitSystemChanged.emit()

    unitSystem = Property(str, _get_unit_system, _set_unit_system, notify=unitSystemChanged)

    def _get_brightness(self) -> int:
        return int(self._brightness)

    def _set_brightness(self, value: int) -> None:
        clamped = int(self._clamp(float(value), 20.0, 100.0))
        if clamped == self._get_brightness():
            return
        self._brightness = float(clamped)
        self._settings.setValue("display/brightness", clamped)
        self.brightnessChanged.emit()

    brightness = Property(int, _get_brightness, _set_brightness, notify=brightnessChanged)

    def _get_unit_labels(self) -> dict:
        if self._unit_system == "imperial":
            return {"speed": "mph", "temperature": "°F", "oilPressure": "psi", "vacuum": "inHg"}
        return {"speed": "km/h", "temperature": "°C", "oilPressure": "bar", "vacuum": "kPa"}

    unitLabels = Property(dict, _get_unit_labels, notify=unitSystemChanged)

    def _get_parameters(self) -> dict:
        return dict(self._parameters)

    parameters = Property(dict, _get_parameters, notify=parameterChanged)

    @Slot(str, float)
    def setParameter(self, name: str, value: float) -> None:
        if name not in PARAMETER_SPECS:
            return
        clamped = self._clamp_parameter(name, float(value))
        if clamped == self._parameters[name]:
            return
        self._parameters[name] = clamped
        self._settings.setValue(f"parameters/{name}", clamped)
        self.parameterChanged.emit(name)

    parameterSpecs = Property(dict, lambda self: PARAMETER_SPECS, constant=True)
