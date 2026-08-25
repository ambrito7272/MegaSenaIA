"""Modelo de dados do veículo — NEODRIVE."""

from app.domain.alerts import Alert, AlertSeverity
from app.domain.enums import DataField
from app.domain.units import (
    DisplayUnits,
    PressureUnit,
    SpeedUnit,
    TemperatureUnit,
    UnitSystem,
    VacuumUnit,
    convert_pressure,
    convert_speed,
    convert_temperature,
    convert_vacuum,
    format_clock,
    format_trip,
    format_value,
)
from app.domain.vehicle_data import FIELD_RANGES, VehicleData

__all__ = [
    "Alert",
    "AlertSeverity",
    "DataField",
    "DisplayUnits",
    "FIELD_RANGES",
    "PressureUnit",
    "SpeedUnit",
    "TemperatureUnit",
    "UnitSystem",
    "VacuumUnit",
    "VehicleData",
    "convert_pressure",
    "convert_speed",
    "convert_temperature",
    "convert_vacuum",
    "format_clock",
    "format_trip",
    "format_value",
]
