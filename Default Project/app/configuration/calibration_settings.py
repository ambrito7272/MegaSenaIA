"""Configurações de calibração — offset e ganho por sinal.

Aplicados no VehicleBridge (provider → QML), portanto o dashboard mostra
o valor já calibrado. Persistidos via QSettings.
"""

from PySide6.QtCore import QObject, Property, QSettings, Signal, Slot

CALIBRATED_FIELDS: dict[str, dict] = {
    "rpm": {"label": "RPM", "offsetLimit": 400.0},
    "speed": {"label": "Velocidade", "offsetLimit": 10.0},
    "temperature": {"label": "Temperatura", "offsetLimit": 6.0},
    "oilPressure": {"label": "Pressão de óleo", "offsetLimit": 0.3},
    "batteryVoltage": {"label": "Bateria", "offsetLimit": 0.8},
    "vacuum": {"label": "Vácuo", "offsetLimit": 5.0},
    "amperage": {"label": "Amperagem", "offsetLimit": 3.0},
    "fuel": {"label": "Combustível", "offsetLimit": 5.0},
}

GAIN_MIN = 0.90
GAIN_MAX = 1.10


class CalibrationSettings(QObject):
    calibrationChanged = Signal()

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._settings = QSettings("NEODRIVE", "Cockpit")
        self._data: dict[str, dict] = {}
        for key in CALIBRATED_FIELDS:
            self._data[key] = {
                "offset": self._read_float(f"calibration/{key}/offset", 0.0),
                "gain": self._read_float(f"calibration/{key}/gain", 1.0),
            }

    def _read_float(self, key: str, default: float) -> float:
        try:
            return float(self._settings.value(key, default))
        except (TypeError, ValueError):
            return default

    def apply(self, key: str, raw: float) -> float:
        entry = self._data.get(key)
        if entry is None:
            return raw
        return raw * entry["gain"] + entry["offset"]

    def _get_calibration(self) -> dict:
        return {k: dict(v) for k, v in self._data.items()}

    calibration = Property(dict, _get_calibration, notify=calibrationChanged)

    def _get_meta(self) -> dict:
        return {
            "fields": [
                {"key": key, "label": spec["label"], "offsetLimit": spec["offsetLimit"]}
                for key, spec in CALIBRATED_FIELDS.items()
            ],
            "gainMin": GAIN_MIN,
            "gainMax": GAIN_MAX,
        }

    meta = Property(dict, _get_meta, constant=True)

    @Slot(str, float)
    def setOffset(self, key: str, value: float) -> None:
        entry = self._data.get(key)
        if entry is None:
            return
        limit = CALIBRATED_FIELDS[key]["offsetLimit"]
        value = max(-limit, min(limit, float(value)))
        if value == entry["offset"]:
            return
        entry["offset"] = value
        self._settings.setValue(f"calibration/{key}/offset", value)
        self.calibrationChanged.emit()

    @Slot(str, float)
    def setGain(self, key: str, value: float) -> None:
        entry = self._data.get(key)
        if entry is None:
            return
        value = max(GAIN_MIN, min(GAIN_MAX, float(value)))
        if value == entry["gain"]:
            return
        entry["gain"] = value
        self._settings.setValue(f"calibration/{key}/gain", value)
        self.calibrationChanged.emit()

    @Slot(str)
    def resetField(self, key: str) -> None:
        entry = self._data.get(key)
        if entry is None or (entry["offset"] == 0.0 and entry["gain"] == 1.0):
            return
        entry["offset"] = 0.0
        entry["gain"] = 1.0
        self._settings.setValue(f"calibration/{key}/offset", 0.0)
        self._settings.setValue(f"calibration/{key}/gain", 1.0)
        self.calibrationChanged.emit()
