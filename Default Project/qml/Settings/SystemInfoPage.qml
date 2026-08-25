import QtQuick
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Informações do sistema"

    Column {
        id: infoColumn

        readonly property var rows: {
            if (!systemInfo)
                return []
            return [
                ["Aplicativo", systemInfo.info.appName],
                ["Versão", systemInfo.info.appVersion],
                ["Qt", systemInfo.info.qtVersion],
                ["PySide6", systemInfo.info.pysideVersion],
                ["Python", systemInfo.info.pythonVersion],
                ["Plataforma", systemInfo.info.platform],
                ["Fonte de dados", systemInfo.info.provider]
            ]
        }

        width: Math.min(parent.width * 0.85, 520)
        spacing: parent.height * 0.018
        anchors.centerIn: parent

        Repeater {
            model: parent.rows

            delegate: Item {
                id: rowRoot

                required property var modelData

                width: infoColumn.width
                height: Math.max(24, infoColumn.height * 0.05)

                Text {
                    text: rowRoot.modelData[0]
                    color: Theme.titleColor
                    font.pixelSize: Math.max(12, rowRoot.height * 0.55)
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: rowRoot.modelData[1]
                    color: Theme.valueColor
                    font.pixelSize: Math.max(12, rowRoot.height * 0.55)
                    font.weight: Font.Medium
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideMiddle
                    maximumLineCount: 1
                }
            }
        }
    }
}
