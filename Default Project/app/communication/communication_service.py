"""CommunicationService — orquestra o transporte com o ESP32.

Máquina de estados: DISCONNECTED → CONNECTING → CONNECTED/ERROR.
A UI só consome propriedades; a troca de transporte é transparente.
"""

from PySide6.QtCore import QObject, Property, QTimer, Signal, Slot

from app.communication.transport import Transport, TransportState
from app.communication.transports.bluetooth_transport import BluetoothTransport
from app.communication.transports.serial_transport import SerialTransport
from app.communication.transports.wifi_transport import WifiTransport
from app.configuration import Esp32Settings


def create_transport(settings: Esp32Settings) -> Transport:
    transport_type = settings.transport
    if transport_type == "serial":
        return SerialTransport(settings.address, settings.baudrate)
    if transport_type == "wifi":
        return WifiTransport(settings.address)
    return BluetoothTransport(settings.address)


class CommunicationService(QObject):
    connectionStateChanged = Signal()
    statusTextChanged = Signal()

    def __init__(self, esp32_settings: Esp32Settings, parent=None) -> None:
        super().__init__(parent)
        self._settings = esp32_settings
        self._transport: Transport | None = None
        self._state = TransportState.DISCONNECTED
        self._status_text = "ESP32 — Não conectado"
        self._detail = "Toque em conectar para tentar"

        esp32_settings.transportChanged.connect(self._on_settings_changed)
        esp32_settings.addressChanged.connect(self._on_settings_changed)
        esp32_settings.baudrateChanged.connect(self._on_settings_changed)

    def _get_state(self) -> str:
        return self._state.value

    state = Property(str, _get_state, notify=connectionStateChanged)

    def _get_status_text(self) -> str:
        return self._status_text

    statusText = Property(str, _get_status_text, notify=statusTextChanged)

    def _get_detail(self) -> str:
        return self._detail

    detailText = Property(str, _get_detail, notify=statusTextChanged)

    @Slot()
    def requestConnect(self) -> None:
        if self._state in (TransportState.CONNECTING, TransportState.CONNECTED):
            self._disconnect()
            return
        self._connect()

    @Slot()
    def requestDisconnect(self) -> None:
        self._disconnect()

    def _on_settings_changed(self) -> None:
        self._disconnect()

    def _connect(self) -> None:
        self._set_state(TransportState.CONNECTING)
        self._set_detail("Verificando transporte...")

        transport = create_transport(self._settings)
        if not transport.is_available():
            label = {
                "bluetooth": "Bluetooth",
                "serial": "Serial",
                "wifi": "Wi-Fi",
            }.get(self._settings.transport, self._settings.transport)
            self._set_state(TransportState.DISCONNECTED)
            self._set_detail(f"Transporte {label} indisponível nesta versão")
            return

        self._transport = transport
        transport.subscribe_state(self._on_transport_state)
        self._set_detail("Conectando ao ESP32...")
        if not transport.open():
            self._transport = None
            self._set_state(TransportState.DISCONNECTED)
            self._set_detail("Falha ao abrir conexão")

    def _disconnect(self) -> None:
        if self._transport is not None:
            self._transport.close()
            self._transport = None
        self._set_state(TransportState.DISCONNECTED)
        self._set_detail("Toque em conectar para tentar")

    def _on_transport_state(self, state: TransportState) -> None:
        self._set_state(state)

    def _set_state(self, state: TransportState) -> None:
        if state == self._state:
            return
        self._state = state
        labels = {
            TransportState.DISCONNECTED: "ESP32 — Não conectado",
            TransportState.CONNECTING: "ESP32 — Conectando...",
            TransportState.CONNECTED: "ESP32 — Conectado",
            TransportState.ERROR: "ESP32 — Erro de conexão",
        }
        self._status_text = labels[state]
        self.connectionStateChanged.emit()
        self.statusTextChanged.emit()

    def _set_detail(self, text: str) -> None:
        if text == self._detail:
            return
        self._detail = text
        self.statusTextChanged.emit()
