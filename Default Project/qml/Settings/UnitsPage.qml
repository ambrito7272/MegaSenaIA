import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Unidades"

    Column {
        id: unitsColumn

        readonly property real base: Math.min(parent ? parent.width : 400, parent ? parent.height : 400)

        width: Math.min(base * 0.85, 520)
        spacing: base * 0.035
        anchors.centerIn: parent

        Repeater {
            model: [
                { key: "metric", label: "Métrico", desc: "km/h · °C · bar · kPa" },
                { key: "imperial", label: "Imperial", desc: "mph · °F · psi · inHg" }
            ]

            delegate: ItemDelegate {
                id: optRoot

                required property var modelData
                readonly property bool selected: appSettings
                                                 ? appSettings.unitSystem === modelData.key
                                                 : false

                width: unitsColumn.width
                height: Math.max(60, unitsColumn.base * 0.14)
                onClicked: appSettings.unitSystem = modelData.key

                background: Rectangle {
                    radius: height / 4
                    color: optRoot.selected ? Theme.trackColor : Theme.panel
                    border.color: optRoot.selected ? Theme.okColor : Theme.panelBorder
                    border.width: optRoot.selected ? 2 : 1
                }

                contentItem: Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: optRoot.height * 0.25

                    Text {
                        text: optRoot.modelData.label
                        color: Theme.valueColor
                        font.pixelSize: Math.max(15, optRoot.height * 0.3)
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: optRoot.modelData.desc
                        color: Theme.titleColor
                        font.pixelSize: Math.max(12, optRoot.height * 0.22)
                    }
                }
            }
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: {
                if (!appSettings)
                    return ""
                var l = appSettings.unitLabels
                return "Velocidade " + l.speed + " · Temperatura " + l.temperature
                     + " · Óleo " + l.oilPressure + " · Vácuo " + l.vacuum
            }
            color: Theme.labelColor
            font.pixelSize: Math.max(12, unitsColumn.base * 0.03)
        }
    }
}
