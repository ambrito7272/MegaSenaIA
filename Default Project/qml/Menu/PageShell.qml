// PageShell — moldura comum das páginas do menu: cabeçalho com voltar,
// título e corpo. Páginas concretas preenchem bodyText ou conteúdo próprio.
import QtQuick
import QtQuick.Controls
import "../Theme.js" as Theme

Page {
    id: root

    signal backRequested()
    signal navigateRequested(string key)

    property string bodyText: ""

    background: Rectangle {
        color: Theme.background
    }

    header: ToolBar {
        background: Rectangle {
            color: Theme.panel
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: parent.height * 0.2
            spacing: parent.height * 0.35

            Item {
                id: backButton
                width: parent.height * 0.8
                height: width
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: backButtonMouse.pressed ? Theme.trackColor : "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u2039"
                    color: Theme.valueColor
                    font.pixelSize: parent.width * 0.7
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: backButtonMouse
                    anchors.fill: parent
                    onClicked: root.backRequested()
                }
            }

            Text {
                text: root.title
                color: Theme.valueColor
                font.pixelSize: Math.max(15, parent.height * 0.42)
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width - x - parent.height * 0.3
            }
        }
    }

    Text {
        visible: root.bodyText !== ""
        text: root.bodyText
        color: Theme.labelColor
        font.pixelSize: Math.max(13, Math.min(22, root.width * 0.04))
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.85, implicitWidth)
    }
}
