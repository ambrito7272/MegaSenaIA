import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Comunicação"

    Column {
        id: statusColumn

        readonly property real base: Math.min(parent ? parent.width : 300,
                                              parent ? parent.height : 300)
        readonly property string connState: comms ? comms.state : "disconnected"
        readonly property color stateColor: connState === "connected" ? Theme.okColor
                                           : connState === "connecting" ? Theme.warnColor
                                           : connState === "error" ? Theme.dangerColor
                                           : Theme.tickMinor

        spacing: base * 0.04
        anchors.centerIn: parent

        Item {
            width: statusColumn.base * 0.6
            height: statusColumn.base * 0.06
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: dot
                anchors.verticalCenter: parent.verticalCenter
                x: (parent.width - width - parent.height * 0.35) / 2
                width: parent.height * 0.9
                height: width
                radius: width / 2
                color: statusColumn.stateColor

                opacity: 1.0

                SequentialAnimation on opacity {
                    running: statusColumn.connState === "connecting"
                    alwaysRunToEnd: false
                    NumberAnimation { to: 0.25; duration: 450 }
                    NumberAnimation { to: 1.0; duration: 450 }
                }

                Connections {
                    target: statusColumn
                    function onConnStateChanged() {
                        if (statusColumn.connState !== "connecting")
                            dot.opacity = 1.0
                    }
                }
            }

            Text {
                text: "ESP32"
                color: Theme.valueColor
                font.pixelSize: Math.max(16, parent.height * 1.4)
                font.weight: Font.Bold
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: comms ? comms.statusText : "ESP32 — Não conectado"
            color: Theme.titleColor
            font.pixelSize: Math.max(12, statusColumn.base * 0.04)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: comms ? comms.detailText : ""
            color: Theme.titleColor
            font.pixelSize: Math.max(11, statusColumn.base * 0.033)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: connectButton
            anchors.horizontalCenter: parent.horizontalCenter
            width: statusColumn.base * 0.45
            height: Math.max(44, statusColumn.base * 0.075)
            text: statusColumn.connState === "connected" ? "Desconectar"
                  : statusColumn.connState === "connecting" ? "Cancelar"
                  : "Conectar"

            background: Rectangle {
                radius: height / 3
                color: connectButton.pressed ? Theme.trackColor : Theme.panel
                border.color: Theme.panelBorder
                border.width: 1
            }

            contentItem: Text {
                text: connectButton.text
                color: Theme.valueColor
                font.pixelSize: Math.max(13, connectButton.height * 0.34)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: comms.requestConnect()
        }
    }
}
