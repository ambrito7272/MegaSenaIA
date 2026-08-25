"""Transporte Serial (placeholder — implementação real na Fase L)."""

from app.communication.transport import Transport, TransportState


class SerialTransport(Transport):
    def __init__(self, port: str, baudrate: int) -> None:
        super().__init__()
        self._port = port
        self._baudrate = baudrate

    def is_available(self) -> bool:
        return False

    def open(self) -> bool:
        self._set_state(TransportState.ERROR)
        return False

    def close(self) -> None:
        self._set_state(TransportState.DISCONNECTED)

    def send(self, payload: bytes) -> bool:
        return False
