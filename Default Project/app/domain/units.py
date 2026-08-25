"""Sistema de unidades e conversões para exibição."""

import datetime as _dt
from dataclasses import dataclass
from enum import Enum


class UnitSystem(Enum):
    METRIC = "metric"
    IMPERIAL = "imperial"


class TemperatureUnit(Enum):
    CELSIUS = "celsius"
    FAHRENHEIT = "fahrenheit"


class PressureUnit(Enum):
    BAR = "bar"
    PSI = "psi"


class SpeedUnit(Enum):
    KMH = "kmh"
    MPH = "mph"


class VacuumUnit(Enum):
    KPA = "kpa"
    INHG = "inhg"


@dataclass(frozen=True, slots=True)
class DisplayUnits:
    speed: SpeedUnit = SpeedUnit.KMH
    temperature: TemperatureUnit = TemperatureUnit.CELSIUS
    oil_pressure: PressureUnit = PressureUnit.BAR
    vacuum: VacuumUnit = VacuumUnit.KPA

    @classmethod
    def from_system(cls, system: UnitSystem) -> "DisplayUnits":
        if system is UnitSystem.IMPERIAL:
            return cls(
                speed=SpeedUnit.MPH,
                temperature=TemperatureUnit.FAHRENHEIT,
                oil_pressure=PressureUnit.PSI,
                vacuum=VacuumUnit.INHG,
            )
        return cls()


def convert_speed(value_kmh: float, unit: SpeedUnit) -> float:
    return value_kmh * 0.621371 if unit is SpeedUnit.MPH else value_kmh


def convert_temperature(value_c: float, unit: TemperatureUnit) -> float:
    return value_c * 9.0 / 5.0 + 32.0 if unit is TemperatureUnit.FAHRENHEIT else value_c


def convert_pressure(value_bar: float, unit: PressureUnit) -> float:
    return value_bar * 14.5037738 if unit is PressureUnit.PSI else value_bar


def convert_vacuum(value_kpa: float, unit: VacuumUnit) -> float:
    return value_kpa * 0.29529980 if unit is VacuumUnit.INHG else value_kpa


def format_value(value: float, decimals: int = 0) -> str:
    return f"{value:.{decimals}f}"


def format_clock(moment: _dt.datetime) -> str:
    return moment.strftime("%H:%M")


def format_trip(value_km: float) -> str:
    return f"{value_km:,.1f}".replace(",", " ")
