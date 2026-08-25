import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    id: pageRoot

    title: "Configurações"

    readonly property var entries: [
        { key: "units", label: "Unidades", desc: "Métrico / Imperial" },
        { key: "brightness", label: "Brilho", desc: (appSettings ? appSettings.brightness : 100) + "%" },
        { key: "parameters", label: "Parâmetros", desc: "Limites e alertas" },
        { key: "systemInfo", label: "Informações do sistema", desc: "Versões e ambiente" }
    ]

    ListView {
        id: list
        anchors.fill: parent
        anchors.margins: Math.max(12, parent.width * 0.04)
        anchors.verticalCenterOffset: 0
        clip: true
        spacing: height * 0.02

        model: pageRoot.entries

        delegate: ItemDelegate {
            id: entryRoot

            required property var modelData
            required property int index

            width: list.width
            height: Math.max(56, list.height * 0.14)
            onClicked: pageRoot.navigateRequested(entryRoot.modelData.key)

            background: Rectangle {
                radius: entryRoot.height / 4
                color: entryRoot.pressed ? Theme.trackColor : Theme.panel
                border.color: Theme.panelBorder
                border.width: 1
            }

            contentItem: Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: entryRoot.height * 0.3

                Text {
                    text: entryRoot.modelData.label
                    color: Theme.valueColor
                    font.pixelSize: Math.max(14, entryRoot.height * 0.32)
                    font.weight: Font.DemiBold
                }

                Text {
                    text: entryRoot.modelData.desc
                    color: Theme.titleColor
                    font.pixelSize: Math.max(11, entryRoot.height * 0.22)
                }
            }

            Text {
                text: "\u203A"
                color: Theme.titleColor
                font.pixelSize: Math.max(16, entryRoot.height * 0.5)
                anchors.right: parent.right
                anchors.rightMargin: entryRoot.height * 0.35
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
