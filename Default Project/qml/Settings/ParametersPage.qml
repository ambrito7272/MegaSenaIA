import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Parâmetros"

    ListView {
        id: paramList

        readonly property var specs: [
            { key: "warnTemp", label: "Alerta de temperatura", unit: "°C", step: 1, decimals: 0 },
            { key: "critTemp", label: "Crítico de temperatura", unit: "°C", step: 1, decimals: 0 },
            { key: "reserveFuel", label: "Reserva de combustível", unit: "%", step: 1, decimals: 0 },
            { key: "oilMin", label: "Pressão mínima de óleo", unit: "bar", step: 0.1, decimals: 1 }
        ]

        anchors.fill: parent
        anchors.margins: Math.max(12, parent.width * 0.05)
        clip: true
        spacing: height * 0.03
        model: specs

        delegate: Item {
            id: paramRoot

            required property var modelData

            width: paramList.width
            height: Math.max(70, paramList.height * 0.18)

            readonly property real lo: (appSettings && appSettings.parameterSpecs[paramRoot.modelData.key])
                                       ? appSettings.parameterSpecs[paramRoot.modelData.key][0] : 0
            readonly property real hi: (appSettings && appSettings.parameterSpecs[paramRoot.modelData.key])
                                       ? appSettings.parameterSpecs[paramRoot.modelData.key][1] : 100
            readonly property real current: (appSettings && appSettings.parameters[paramRoot.modelData.key] !== undefined)
                                            ? appSettings.parameters[paramRoot.modelData.key]
                                            : lo

            Column {
                width: parent.width
                spacing: parent.height * 0.08

                Item {
                    width: parent.width
                    height: Math.max(18, paramRoot.height * 0.3)

                    Text {
                        text: paramRoot.modelData.label
                        color: Theme.labelColor
                        font.pixelSize: Math.max(13, parent.height * 0.8)
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: paramRoot.current.toFixed(paramRoot.modelData.decimals) + " " + paramRoot.modelData.unit
                        color: Theme.valueColor
                        font.pixelSize: Math.max(13, parent.height * 0.8)
                        font.weight: Font.Bold
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Slider {
                    width: parent.width
                    from: paramRoot.lo
                    to: paramRoot.hi
                    stepSize: paramRoot.modelData.step
                    value: paramRoot.current

                    onMoved: appSettings.setParameter(paramRoot.modelData.key, value)
                }
            }
        }
    }
}
