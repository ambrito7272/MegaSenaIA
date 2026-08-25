"""Snapshot instantâneo dos dados do veículo.

Unidade base de cada campo (conversões para exibição em app/domain/units.py):
    rpm                  rpm
    speed                km/h
    temperature          °C
    oilPressure          bar
    batteryVoltage       V
    vacuum               kPa
    amperage             A  (positivo: carga; negativo: descarga)
    fuel                 %  (0–100)
    trip                 km
"""

from dataclasses import dataclass, field
import time
import datetime as _dt

from app.domain.alerts import Alert
from app.domain.enums import DataField


@dataclass(frozen=True, slots=True)
class VehicleData:
    rpm: float = 0.0
    speed: float = 0.0
    temperature: float = 0.0
    oil_pressure: float = 0.0
    battery_voltage: float = 0.0
    vacuum: float = 0.0
    amperage: float = 0.0
    fuel_level: float = 0.0
    lambda_value: float = 1.0
    trip: float = 0.0
    clock: _dt.datetime = field(default_factory=_dt.datetime.now)
    monotonic_ms: int = field(default_factory=lambda: time.monotonic_ns() // 1_000_000)
    alerts: tuple[Alert, ...] = ()

    def to_dict(self) -> dict:
        data = {
            DataField.RPM.value: self.rpm,
            DataField.SPEED.value: self.speed,
            DataField.COOLANT_TEMPERATURE.value: self.temperature,
            DataField.OIL_PRESSURE.value: self.oil_pressure,
            DataField.BATTERY_VOLTAGE.value: self.battery_voltage,
            DataField.VACUUM.value: self.vacuum,
            DataField.AMPERAGE.value: self.amperage,
            DataField.FUEL_LEVEL.value: self.fuel_level,
            DataField.LAMBDA.value: self.lambda_value,
            DataField.TRIP.value: self.trip,
            DataField.CLOCK.value: self.clock.isoformat(timespec="seconds"),
        }
        return data


FIELD_RANGES: dict[str, tuple[float, float]] = {
    "rpm": (0.0, 8000.0),
    "speed": (0.0, 220.0),
    "temperature": (50.0, 130.0),
    "oil_pressure": (0.0, 6.0),
    "battery_voltage": (8.0, 16.0),
    "vacuum": (0.0, 100.0),
    "amperage": (-60.0, 60.0),
    "fuel_level": (0.0, 100.0),
    "lambda_value": (0.6, 1.4),
    "trip": (0.0, 999999.0),
}
