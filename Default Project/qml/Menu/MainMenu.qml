// MainMenu — painel lateral deslizante com os 8 itens do menu.
// Implementação própria (scrim + painel) para comportamento idêntico
// em desktop e Android, sem depender de estilos de Controls.
import QtQuick
import "../Theme.js" as Theme

Item {
    id: root

    property bool open: false
    signal entrySelected(string key)

    readonly property var entries: [
        { key: "settings", label: "Configurações" },
        { key: "units", label: "Unidades" },
        { key: "calibration", label: "Calibração" },
        { key: "brightness", label: "Brilho" },
        { key: "communication", label: "Comunicação" },
        { key: "diagnostics", label: "Diagnóstico" },
        { key: "parameters", label: "Parâmetros" },
        { key: "systemInfo", label: "Informações do sistema" }
    ]

    visible: opacity > 0.01
    opacity: open ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
    }

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: "#000000"
        opacity: 0.55 * root.opacity

        TapHandler {
            onTapped: root.open = false
        }
    }

    Rectangle {
        id: panel
        width: Math.min(root.width * 0.72, 360)
        height: parent.height
        x: root.open ? 0 : -width
        color: Theme.panel
        border.color: Theme.panelBorder
        border.width: 1

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: parent.width * 0.07

            Item {
                width: parent.width
                height: parent.height * 0.09

                Text {
                    text: "NEODRIVE"
                    color: Theme.valueColor
                    font.pixelSize: Math.max(16, parent.height * 0.6)
                    font.weight: Font.Bold
                    font.letterSpacing: parent.width * 0.02
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.panelBorder
            }

            Item {
                width: parent.width
                height: parent.height * 0.03
            }

            Repeater {
                model: root.entries

                delegate: Item {
                    id: entryRoot

                    required property var modelData
                    required property int index

                    width: menuColumn.width
                    height: Math.max(44, panel.height * 0.062)

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 3
                        color: entryMouse.pressed ? Theme.trackColor : "transparent"
                    }

                    Text {
                        text: entryRoot.modelData.label
                        color: Theme.labelColor
                        font.pixelSize: Math.max(13, entryRoot.height * 0.36)
                        font.weight: Font.Medium
                        anchors.left: parent.left
                        anchors.leftMargin: parent.height * 0.25
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: parent.width - parent.height * 0.5
                    }

                    MouseArea {
                        id: entryMouse
                        anchors.fill: parent
                        onClicked: {
                            root.open = false
                            root.entrySelected(entryRoot.modelData.key)
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: parent.height * 0.05
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.panelBorder
            }

            Item {
                id: footer
                width: parent.width
                height: parent.height * 0.08

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.height * 0.15
                    width: parent.height * 0.22
                    height: width
                    radius: width / 2
                    color: Theme.tickMinor
                }

                Text {
                    text: "ESP32 — Não conectado"
                    color: Theme.titleColor
                    font.pixelSize: Math.max(11, footer.height * 0.38)
                    anchors.left: parent.left
                    anchors.leftMargin: parent.height * 0.55
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
