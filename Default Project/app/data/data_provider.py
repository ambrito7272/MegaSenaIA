"""Contrato abstrato de fornecimento de dados ao painel.

Todo provider (Demo, ESP32 futuro) entrega snapshots imutáveis de
VehicleData a assinantes. Nenhuma dependência de Qt aqui: a camada de
serviços adapta os callbacks para sinais QML.
"""

import threading
from abc import ABC, abstractmethod
from enum import Enum
from typing import Callable

from app.domain.vehicle_data import VehicleData


class ProviderState(Enum):
    STOPPED = "stopped"
    RUNNING = "running"
    ERROR = "error"


DataProviderCallback = Callable[[VehicleData], None]


class DataProvider(ABC):
    """Fonte única de dados do veículo para toda a aplicação."""

    def __init__(self) -> None:
        self._state = ProviderState.STOPPED
        self._subscribers: list[DataProviderCallback] = []
        self._lock = threading.Lock()
        self._last_snapshot: VehicleData | None = None

    @property
    def state(self) -> ProviderState:
        return self._state

    @property
    def is_running(self) -> bool:
        return self._state is ProviderState.RUNNING

    @property
    def last_snapshot(self) -> VehicleData | None:
        with self._lock:
            return self._last_snapshot

    def subscribe(self, callback: DataProviderCallback) -> None:
        with self._lock:
            if callback not in self._subscribers:
                self._subscribers.append(callback)

    def unsubscribe(self, callback: DataProviderCallback) -> None:
        with self._lock:
            if callback in self._subscribers:
                self._subscribers.remove(callback)

    def start(self) -> None:
        if self.is_running:
            return
        self._state = ProviderState.RUNNING
        self._on_start()

    def stop(self) -> None:
        if not self.is_running:
            return
        self._state = ProviderState.STOPPED
        self._on_stop()

    def _publish(self, snapshot: VehicleData) -> None:
        with self._lock:
            self._last_snapshot = snapshot
            subscribers = tuple(self._subscribers)
        for callback in subscribers:
            callback(snapshot)

    @abstractmethod
    def _on_start(self) -> None:
        """Inicializa a fonte de dados (thread, conexão etc.)."""

    @abstractmethod
    def _on_stop(self) -> None:
        """Encerra a fonte de dados liberando recursos."""
