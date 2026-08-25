import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Calibração"

    ListView {
        id: calList

        readonly property real gainMin: calibration ? calibration.meta.gainMin : 0.9
        readonly property real gainMax: calibration ? calibration.meta.gainMax : 1.1

        anchors.fill: parent
        anchors.margins: Math.max(12, parent.width * 0.04)
        clip: true
        spacing: height * 0.018
        model: calibration ? calibration.meta.fields : []

        delegate: Item {
            id: fieldRoot

            required property var modelData

            width: calList.width
            height: Math.max(120, calList.height * 0.22)

            readonly property string key: modelData.key
            readonly property var entry: (calibration && calibration.calibration[key])
                                         ? calibration.calibration[key]
                                         : { offset: 0, gain: 1 }
            readonly property real liveValue: (vehicle && vehicle.telemetry[key] !== undefined)
                                              ? vehicle.telemetry[key] : 0

            Rectangle {
                anchors.fill: parent
                radius: height / 6
                color: Theme.panel
                border.color: Theme.panelBorder
                border.width: 1
            }

            Column {
                anchors.fill: parent
                anchors.margins: parent.height * 0.08
                spacing: parent.height * 0.05

                Item {
                    width: parent.width
                    height: Math.max(20, fieldRoot.height * 0.16)

                    Text {
                        text: fieldRoot.modelData.label
                        color: Theme.valueColor
                        font.pixelSize: Math.max(14, parent.height * 0.85)
                        font.weight: Font.DemiBold
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "agora: " + fieldRoot.liveValue
                              + "   ·   offset " + fieldRoot.entry.offset.toFixed(2)
                              + "   ·   ganho " + fieldRoot.entry.gain.toFixed(2)
                        color: Theme.titleColor
                        font.pixelSize: Math.max(11, parent.height * 0.62)
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width: parent.width
                    spacing: parent.width * 0.03

                    Text {
                        text: "ganho"
                        color: Theme.titleColor
                        font.pixelSize: Math.max(10, parent.height * 0.55)
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.12
                    }

                    Slider {
                        id: gainSlider
                        width: parent.width * 0.72
                        from: calList.gainMin
                        to: calList.gainMax
                        stepSize: 0.01
                        value: fieldRoot.entry.gain

                        onMoved: calibration.setGain(fieldRoot.key, value)
                    }

                    Text {
                        text: "×" + gainSlider.value.toFixed(2)
                        color: Theme.labelColor
                        font.pixelSize: Math.max(11, parent.height * 0.6)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width: parent.width
                    spacing: parent.width * 0.03

                    Text {
                        text: "offset"
                        color: Theme.titleColor
                        font.pixelSize: Math.max(10, parent.height * 0.55)
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * 0.12
                    }

                    Slider {
                        id: offsetSlider
                        width: parent.width * 0.72
                        from: -fieldRoot.modelData.offsetLimit
                        to: fieldRoot.modelData.offsetLimit
                        stepSize: fieldRoot.modelData.offsetLimit / 20
                        value: fieldRoot.entry.offset

                        onMoved: calibration.setOffset(fieldRoot.key, value)
                    }

                    Text {
                        text: (offsetSlider.value >= 0 ? "+" : "") + offsetSlider.value.toFixed(2)
                        color: Theme.labelColor
                        font.pixelSize: Math.max(11, parent.height * 0.6)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Button {
                    id: resetButton
                    width: parent.width * 0.4
                    height: Math.max(30, parent.height * 0.18)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Redefinir"

                    readonly property bool pristine: fieldRoot.entry.offset === 0
                                                     && fieldRoot.entry.gain === 1.0

                    background: Rectangle {
                        radius: height / 3
                        color: resetButton.pressed || resetButton.pristine
                               ? Theme.trackColor : Theme.panel
                        border.color: Theme.panelBorder
                        border.width: 1
                    }

                    contentItem: Text {
                        text: resetButton.text
                        color: Theme.labelColor
                        font.pixelSize: Math.max(11, resetButton.height * 0.36)
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: calibration.resetField(fieldRoot.key)
                }
            }
        }
    }
}
