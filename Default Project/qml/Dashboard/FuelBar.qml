// FuelBar — indicador de combustível premium:
// E · barra proporcional com borda, brilho interno sutil · F
// Horizontal quando o contêiner é mais largo que alto; vertical caso contrário.
import QtQuick
import "../Theme.js" as Theme

Item {
    id: root

    property real level: 50
    property bool showLabels: true

    readonly property real _clamped: Math.max(0, Math.min(100, level))
    readonly property bool _horizontal: width >= height
    readonly property color _fillColor: {
        if (_clamped <= 15)
            return Theme.fuelDanger
        if (_clamped <= 25)
            return Theme.fuelWarn
        return Theme.fuelOk
    }

    component FuelLabel : Text {
        visible: root.showLabels
        color: Theme.titleColor
        font.weight: Font.DemiBold
    }

    Row {
        id: hLayout
        visible: root._horizontal
        anchors.fill: parent
        spacing: root.height * 0.35

        FuelLabel {
            id: hLabelE
            text: "E"
            color: root._clamped <= 15 ? Theme.fuelDanger : Theme.titleColor
            font.pixelSize: Math.max(9, root.height * 0.42)
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            id: hTrackHost
            height: parent.height
            width: Math.max(0, parent.width - parent.spacing * 2
                            - (root.showLabels ? hLabelE.width : 0)
                            - (root.showLabels ? hLabelF.width : 0))

            Rectangle {
                id: hGlow
                anchors.fill: hTrack
                anchors.margins: -hTrack.height * 0.10
                radius: hTrack.height / 2
                color: "transparent"
                border.color: Qt.rgba(root._fillColor.r, root._fillColor.g,
                                      root._fillColor.b, 0.18)
                border.width: Math.max(2, hTrack.height * 0.16)
            }

            Rectangle {
                id: hTrack
                anchors.fill: parent
                radius: height / 2
                color: Theme.trackColor
                border.color: Theme.panelBorder
                border.width: 1
            }

            Rectangle {
                id: hFill
                anchors.top: hTrack.top
                anchors.bottom: hTrack.bottom
                anchors.margins: hTrack.height * 0.14
                anchors.left: hTrack.left
                width: Math.max(height, (hTrack.width - hTrack.height * 0.28)
                                * root._clamped / 100 + hTrack.height * 0.14)
                radius: height / 2
                color: root._fillColor

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: parent.height * 0.18
                    height: parent.height * 0.22
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

                Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        FuelLabel {
            id: hLabelF
            text: "F"
            color: Theme.labelColor
            font.pixelSize: Math.max(9, root.height * 0.42)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Column {
        id: vLayout
        visible: !root._horizontal
        anchors.fill: parent
        spacing: root.width * 0.30

        FuelLabel {
            id: vLabelF
            text: "F"
            color: Theme.labelColor
            font.pixelSize: Math.max(9, root.width * 0.42)
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id: vTrackHost
            width: parent.width
            height: Math.max(0, parent.height - parent.spacing * 2
                             - (root.showLabels ? vLabelF.height : 0)
                             - (root.showLabels ? vLabelE.height : 0))

            Rectangle {
                id: vTrack
                anchors.fill: parent
                radius: width / 2
                color: Theme.trackColor
                border.color: Theme.panelBorder
                border.width: 1
            }

            Rectangle {
                anchors.left: vTrack.left
                anchors.right: vTrack.right
                anchors.margins: vTrack.width * 0.14
                anchors.bottom: vTrack.bottom
                width: vTrack.width - vTrack.width * 0.28
                height: Math.max(width, (vTrack.height - vTrack.width * 0.28)
                                 * root._clamped / 100 + vTrack.width * 0.14)
                radius: width / 2
                color: root._fillColor

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: parent.width * 0.18
                    height: parent.height * 0.04
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

                Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        FuelLabel {
            id: vLabelE
            text: "E"
            color: Theme.fuelDanger
            font.pixelSize: Math.max(9, root.width * 0.42)
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
