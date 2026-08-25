"""Interface comum de transporte — Bluetooth, Serial e Wi-Fi a implementam.

Nenhuma implementação real aqui: os transports concretos chegam na Fase L,
junto do hardware. A interface já define o contrato completo.
"""

import threading
from abc import ABC, abstractmethod
from enum import Enum
from typing import Callable


class TransportState(Enum):
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    ERROR = "error"


DataCallback = Callable[[bytes], None]
StateCallback = Callable[[TransportState], None]


class Transport(ABC):
    def __init__(self) -> None:
        self._state = TransportState.DISCONNECTED
        self._data_callbacks: list[DataCallback] = []
        self._state_callbacks: list[StateCallback] = []
        self._lock = threading.Lock()

    @property
    def state(self) -> TransportState:
        return self._state

    def subscribe_data(self, callback: DataCallback) -> None:
        with self._lock:
            if callback not in self._data_callbacks:
                self._data_callbacks.append(callback)

    def subscribe_state(self, callback: StateCallback) -> None:
        with self._lock:
            if callback not in self._state_callbacks:
                self._state_callbacks.append(callback)

    def _set_state(self, state: TransportState) -> None:
        with self._lock:
            self._state = state
            callbacks = tuple(self._state_callbacks)
        for callback in callbacks:
            callback(state)

    def _emit_data(self, payload: bytes) -> None:
        with self._lock:
            callbacks = tuple(self._data_callbacks)
        for callback in callbacks:
            callback(payload)

    @abstractmethod
    def is_available(self) -> bool:
        """Informa se o meio de transporte existe neste dispositivo."""

    @abstractmethod
    def open(self) -> bool:
        """Inicia a conexão; retorna False se não conseguir."""

    @abstractmethod
    def close(self) -> None:
        """Encerra a conexão liberando recursos."""

    @abstractmethod
    def send(self, payload: bytes) -> bool:
        """Envia dados ao ESP32; retorna False em falha."""
