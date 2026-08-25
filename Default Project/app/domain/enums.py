"""Campos de dados do veículo fornecidos ao painel."""

from enum import Enum


class DataField(str, Enum):
    RPM = "rpm"
    SPEED = "speed"
    COOLANT_TEMPERATURE = "temperature"
    OIL_PRESSURE = "oilPressure"
    BATTERY_VOLTAGE = "batteryVoltage"
    VACUUM = "vacuum"
    AMPERAGE = "amperage"
    FUEL_LEVEL = "fuel"
    TRIP = "trip"
    CLOCK = "clock"
    LAMBDA = "lambda"
