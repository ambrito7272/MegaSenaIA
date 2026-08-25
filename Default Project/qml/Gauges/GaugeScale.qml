// Escala de manômetro: ticks maiores/menores e rótulos numéricos.
// Convenção geométrica: ângulos em graus, sentido HORÁRIO a partir das 12h.
import QtQuick
import "../Theme.js" as Theme

Item {
    id: root

    property int minValue: 0
    property int maxValue: 100
    property int majorCount: 9
    property int minorPerMajor: 4
    property real startAngleDeg: 225
    property real sweepDeg: 270
    property real tickRadiusRatio: 1.0
    property real labelRadiusRatio: 0.72
    property real tickLengthRatio: 0.11
    property bool showLabels: true

    readonly property real _cx: width / 2
    readonly property real _cy: height / 2
    readonly property real _radius: Math.min(width, height) / 2

    function pointAt(frac, radiusRatio) {
        var deg = startAngleDeg + sweepDeg * frac
        var rad = (deg - 90) * Math.PI / 180
        return Qt.point(
            _cx + _radius * radiusRatio * Math.cos(rad),
            _cy + _radius * radiusRatio * Math.sin(rad)
        )
    }

    function rotationAt(frac) {
        return startAngleDeg + sweepDeg * frac
    }

    Repeater {
        model: root.majorCount

        delegate: Item {
            id: majorTick
            required property int index
            readonly property real frac: index / Math.max(1, root.majorCount - 1)
            readonly property var pos: root.pointAt(frac, root.tickRadiusRatio)
            readonly property real len: root._radius * root.tickLengthRatio
            readonly property real thick: Math.max(2, root._radius * 0.014)

            x: pos.x - width / 2
            y: pos.y - height / 2
            width: thick
            height: len
            rotation: root.rotationAt(frac)

            Rectangle {
                anchors.fill: parent
                radius: parent.thick / 2
                color: Theme.tickMajor
                antialiasing: true
            }

            Text {
                visible: root.showLabels
                readonly property var lpos: root.pointAt(parent.frac, root.labelRadiusRatio)
                x: lpos.x - width / 2 - parent.x
                y: lpos.y - height / 2 - parent.y
                text: Math.round(root.minValue + (root.maxValue - root.minValue) * parent.frac)
                color: Theme.labelColor
                font.pixelSize: Math.max(10, root._radius * 0.115)
                font.weight: Font.DemiBold
            }
        }
    }

    Repeater {
        model: (root.majorCount - 1) * root.minorPerMajor

        delegate: Item {
            id: minorTick
            required property int index
            readonly property real frac: index / Math.max(1, (root.majorCount - 1) * root.minorPerMajor)
            readonly property var pos: root.pointAt(frac, root.tickRadiusRatio)
            readonly property real len: root._radius * root.tickLengthRatio * 0.5
            readonly property real thick: Math.max(1, root._radius * 0.008)

            x: pos.x - width / 2
            y: pos.y - height / 2
            width: thick
            height: len
            rotation: root.rotationAt(frac)

            Rectangle {
                anchors.fill: parent
                radius: parent.thick / 2
                color: Theme.tickMinor
                antialiasing: true
            }
        }
    }
}
