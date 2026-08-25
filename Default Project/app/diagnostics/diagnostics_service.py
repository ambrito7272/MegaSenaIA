"""Serviço de diagnóstico — leitura ao vivo dos sinais brutos vs faixas físicas.

Lê direto do provider (valor BRUTO, pré-calibração): diagnóstico avalia o
sensor, não a exibição. Sempre em unidades base (km/h, °C, bar, kPa, V, A, %).
"""

from PySide6.QtCore import QObject, Property, QTimer, Signal

from app.data.data_provider import DataProvider
from app.domain.vehicle_data import FIELD_RANGES

FIELD_META = [
    ("rpm", "RPM", "rpm", 0),
    ("speed", "Velocidade", "km/h", 0),
    ("temperature", "Temperatura", "°C", 1),
    ("oilPressure", "Pressão de óleo", "bar", 2),
    ("batteryVoltage", "Bateria", "V", 2),
    ("vacuum", "Vácuo", "kPa", 0),
    ("amperage", "Amperagem", "A", 0),
    ("fuel", "Combustível", "%", 0),
    ("trip", "Trip", "km", 1),
]

REFRESH_HZ = 4


class DiagnosticsService(QObject):
    rowsChanged = Signal()

    def __init__(self, provider: DataProvider, parent=None) -> None:
        super().__init__(parent)
        self._provider = provider
        self._latest = None
        self._rows: list[dict] = []
        self._out_of_range_count = 0
        self._last_key: tuple | None = None

        provider.subscribe(self._on_snapshot)

        self._timer = QTimer(self)
        self._timer.setInterval(int(1000 / REFRESH_HZ))
        self._timer.timeout.connect(self._refresh)
        self._timer.start()

    def _on_snapshot(self, snapshot) -> None:
        self._latest = snapshot

    def _get_rows(self) -> list[dict]:
        return self._rows

    rows = Property(list, _get_rows, notify=rowsChanged)

    def _get_out_of_range(self) -> int:
        return self._out_of_range_count

    outOfRangeCount = Property(int, _get_out_of_range, notify=rowsChanged)

    @Property(str, constant=True)
    def providerName(self) -> str:
        return type(self._provider).__name__

    def _refresh(self) -> None:
        snapshot = self._latest
        if snapshot is None:
            return

        raw_by_key = {
            "rpm": snapshot.rpm,
            "speed": snapshot.speed,
            "temperature": snapshot.temperature,
            "oilPressure": snapshot.oil_pressure,
            "batteryVoltage": snapshot.battery_voltage,
            "vacuum": snapshot.vacuum,
            "amperage": snapshot.amperage,
            "fuel": snapshot.fuel_level,
            "trip": snapshot.trip,
        }

        rows = []
        failures = 0

        for key, label, unit, decimals in FIELD_META:
            value = raw_by_key[key]
            lo, hi = FIELD_RANGES.get(key, (0.0, 0.0))
            ok = lo <= value <= hi
            if not ok:
                failures += 1
            rows.append({
                "key": key,
                "label": label,
                "value": f"{value:.{decimals}f} {unit}",
                "range": f"{lo:g} a {hi:g}",
                "ok": ok,
            })

        key = tuple((r["key"], r["value"], r["ok"]) for r in rows)
        self._rows = rows
        self._out_of_range_count = failures
        if key != self._last_key:
            self._last_key = key
            self.rowsChanged.emit()
