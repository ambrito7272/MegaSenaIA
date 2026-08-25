"""Ponte entre o DataProvider e a interface QML.

Estratégia: o provider publica snapshots em thread própria; o bridge guarda
a referência mais recente e um QTimer do loop principal empurra as
propriedades para o QML a 30 Hz — sem travas cruzadas e sem custo de sinais
entre threads.
"""

from PySide6.QtCore import QObject, Property, QTimer, Signal

from app.data.data_provider import DataProvider
from app.domain.vehicle_data import FIELD_RANGES, VehicleData

PUSH_HZ = 30


class VehicleBridge(QObject):
    telemetryChanged = Signal()
    alertTextChanged = Signal()
    alertLevelChanged = Signal()

    def __init__(self, provider: DataProvider, calibration=None, parent=None) -> None:
        super().__init__(parent)
        self._provider = provider
        self._calibration = calibration
        self._latest: VehicleData | None = None
        self._pushed_key: tuple | None = None
        self._telemetry: dict = {
            "rpm": 0, "speed": 0, "temperature": 0, "oilPressure": 0.0,
            "batteryVoltage": 0.0, "vacuum": 0, "amperage": 0,
            "fuel": 0, "trip": 0.0, "clock": "",
        }
        self._alert_text = ""
        self._alert_level = 0

        provider.subscribe(self._on_snapshot)

        self._timer = QTimer(self)
        self._timer.setInterval(int(1000 / PUSH_HZ))
        self._timer.timeout.connect(self._push)
        self._timer.start()

    def _on_snapshot(self, snapshot: VehicleData) -> None:
        self._latest = snapshot

    def _cal(self, key: str, raw: float) -> float:
        value = raw if self._calibration is None else self._calibration.apply(key, raw)
        bounds = FIELD_RANGES.get(key)
        if bounds is not None:
            value = max(bounds[0], min(bounds[1], value))
        return value

    def _build_telemetry(self, s: VehicleData) -> dict:
        return {
            "rpm": round(self._cal("rpm", s.rpm)),
            "speed": round(self._cal("speed", s.speed)),
            "temperature": round(self._cal("temperature", s.temperature)),
            "oilPressure": round(self._cal("oilPressure", s.oil_pressure), 2),
            "batteryVoltage": round(self._cal("batteryVoltage", s.battery_voltage), 2),
            "vacuum": round(self._cal("vacuum", s.vacuum)),
            "amperage": round(self._cal("amperage", s.amperage)),
            "fuel": round(self._cal("fuel", s.fuel_level)),
            "trip": round(s.trip, 1),
            "clock": s.clock.strftime("%H:%M"),
        }

    def _push(self) -> None:
        snapshot = self._latest
        if snapshot is None:
            return

        telemetry = self._build_telemetry(snapshot)
        key = (
            telemetry["rpm"], telemetry["speed"], telemetry["temperature"],
            telemetry["oilPressure"], telemetry["batteryVoltage"],
            telemetry["vacuum"], telemetry["amperage"], telemetry["fuel"],
            telemetry["trip"], telemetry["clock"],
        )
        if key != self._pushed_key:
            self._pushed_key = key
            self._telemetry = telemetry
            self.telemetryChanged.emit()

        level = 0
        text = ""
        for alert in snapshot.alerts:
            if alert.severity.value == "critical":
                level = 2
                text = alert.message
                break
            if alert.severity.value == "warning":
                level = max(level, 1)
                text = alert.message
        if level != self._alert_level or text != self._alert_text:
            self._alert_level = level
            self._alert_text = text
            self.alertLevelChanged.emit()
            self.alertTextChanged.emit()

    def _get_telemetry(self) -> dict:
        return self._telemetry

    telemetry = Property(dict, _get_telemetry, notify=telemetryChanged)

    def _get_alert_text(self) -> str:
        return self._alert_text

    alertText = Property(str, _get_alert_text, notify=alertTextChanged)

    def _get_alert_level(self) -> int:
        return self._alert_level

    alertLevel = Property(int, _get_alert_level, notify=alertLevelChanged)
