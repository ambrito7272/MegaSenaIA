"""Camada de comunicação com o ESP32.

CommunicationService → Transport (interface comum) → Bluetooth/Serial/Wi-Fi.
Implementações reais dos transports chegam na Fase L, com o hardware.
"""

from app.communication.communication_service import CommunicationService
from app.communication.transport import Transport, TransportState
from app.communication.transports.bluetooth_transport import BluetoothTransport
from app.communication.transports.serial_transport import SerialTransport
from app.communication.transports.wifi_transport import WifiTransport

__all__ = [
    "BluetoothTransport",
    "CommunicationService",
    "SerialTransport",
    "Transport",
    "TransportState",
    "WifiTransport",
]
