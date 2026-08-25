"""Configurações do ESP32 — preferências de conexão persistidas.

Nada aqui conecta de fato: a conexão real pertence à camada
app/communication (Fase I). Estes valores apenas descrevem COMO conectar.
"""

from PySide6.QtCore import QObject, Property, QSettings, Signal

from app.configuration.app_settings import APPLICATION, ORGANIZATION

VALID_TRANSPORTS = ("bluetooth", "serial", "wifi")


class Esp32Settings(QObject):
    transportChanged = Signal()
    addressChanged = Signal()
    baudrateChanged = Signal()

    def __init__(self, parent=None) -> None:
        super().__init__(parent)
        self._settings = QSettings(ORGANIZATION, APPLICATION)

        self._transport = str(self._settings.value("esp32/transport", "bluetooth"))
        if self._transport not in VALID_TRANSPORTS:
            self._transport = "bluetooth"

        self._address = str(self._settings.value("esp32/address", ""))
        try:
            self._baudrate = int(self._settings.value("esp32/baudrate", 115200))
        except (TypeError, ValueError):
            self._baudrate = 115200

    def _get_transport(self) -> str:
        return self._transport

    def _set_transport(self, value: str) -> None:
        if value not in VALID_TRANSPORTS or value == self._transport:
            return
        self._transport = value
        self._settings.setValue("esp32/transport", value)
        self.transportChanged.emit()

    transport = Property(str, _get_transport, _set_transport, notify=transportChanged)

    def _get_address(self) -> str:
        return self._address

    def _set_address(self, value: str) -> None:
        value = str(value).strip()
        if value == self._address:
            return
        self._address = value
        self._settings.setValue("esp32/address", value)
        self.addressChanged.emit()

    address = Property(str, _get_address, _set_address, notify=addressChanged)

    def _get_baudrate(self) -> int:
        return self._baudrate

    def _set_baudrate(self, value: int) -> None:
        allowed = (9600, 19200, 38400, 57600, 115200)
        value = int(value)
        if value not in allowed or value == self._baudrate:
            return
        self._baudrate = value
        self._settings.setValue("esp32/baudrate", value)
        self.baudrateChanged.emit()

    baudrate = Property(int, _get_baudrate, _set_baudrate, notify=baudrateChanged)
