import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Diagnóstico"

    Column {
        id: headerInfo

        readonly property real base: Math.min(parent ? parent.width : 300, 520)

        width: parent.width * 0.9
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.02
        spacing: base * 0.01

        Text {
            text: (diag ? diag.outOfRangeCount : 0) === 0
                  ? "Todos os sinais dentro da faixa"
                  : (diag ? diag.outOfRangeCount : 0) + " sinal(is) fora da faixa"
            color: (diag && diag.outOfRangeCount > 0) ? Theme.warnColor : Theme.okColor
            font.pixelSize: Math.max(13, headerInfo.base * 0.033)
            font.weight: Font.DemiBold
        }

        Text {
            text: "Valores já calibrados · unidades base · atualização contínua"
            color: Theme.titleColor
            font.pixelSize: Math.max(11, headerInfo.base * 0.026)
        }
    }

    ListView {
        id: rowsList
        anchors.top: headerInfo.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Math.max(12, parent.width * 0.04)
        anchors.topMargin: parent.height * 0.02
        clip: true
        spacing: height * 0.012
        model: diag ? diag.rows : []

        delegate: Item {
            id: rowRoot

            required property var modelData

            width: rowsList.width
            height: Math.max(46, rowsList.height * 0.085)

            Rectangle {
                anchors.fill: parent
                radius: height / 4
                color: Theme.panel
                border.color: Theme.panelBorder
                border.width: 1

                Rectangle {
                    x: parent.height * 0.25
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height * 0.22
                    height: width
                    radius: width / 2
                    color: rowRoot.modelData.ok ? Theme.okColor : Theme.dangerColor
                }

                Text {
                    text: rowRoot.modelData.label
                    color: Theme.valueColor
                    font.pixelSize: Math.max(13, rowRoot.height * 0.32)
                    font.weight: Font.Medium
                    anchors.left: parent.left
                    anchors.leftMargin: parent.height * 0.65
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.42
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: rowRoot.modelData.value
                    color: rowRoot.modelData.ok ? Theme.labelColor : Theme.dangerColor
                    font.pixelSize: Math.max(13, rowRoot.height * 0.34)
                    font.weight: Font.Bold
                    anchors.right: rangeText.left
                    anchors.rightMargin: parent.width * 0.05
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: rangeText
                    text: "faixa " + rowRoot.modelData.range
                    color: Theme.titleColor
                    font.pixelSize: Math.max(10, rowRoot.height * 0.24)
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height * 0.3
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
