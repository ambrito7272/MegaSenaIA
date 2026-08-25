"""Modelo de alertas do veículo."""

import datetime as _dt
from dataclasses import dataclass, field
from enum import Enum


class AlertSeverity(Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"


@dataclass(frozen=True, slots=True)
class Alert:
    code: str
    severity: AlertSeverity
    message: str
    timestamp: _dt.datetime = field(default_factory=_dt.datetime.now)
