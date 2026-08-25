// ArcGauge — "GaugePainter" do NEODRIVE, estilo cluster digital premium.
//
// Anel de gradiente ESTÁTICO (amarelo→laranja→vermelho) cobrindo toda a
// escala, formado por micro-segmentos de cor interpolada (matiz via Qt.hsla
// com S/L fixos — luminosidade constante). A zona crítica (criticalStart)
// é pintada em vermelho pleno, integrada ao gradiente. O ponteiro indica o
// valor; o número grande central domina o instrumento.
//
// Geometria única: início 225°, varredura 270° horária visual; ticks e
// rótulos via GaugeScale (seno/cosseno).
import QtQuick
import QtQuick.Shapes
import "../Theme.js" as Theme

Item {
    id: root

    property real minValue: 0
    property real maxValue: 100
    property real value: 0
    property string title: ""
    property string unitLabel: ""
    property int valueDecimals: 0
    property int majorCount: 9
    property real warningStart: NaN
    property real criticalStart: NaN

    readonly property real _ringRatio: 0.86
    readonly property real _ringRadius: Math.min(width, height) / 2 * _ringRatio
    readonly property real _stroke: Math.max(6, _ringRadius * 0.34)
    readonly property real _innerRadius: _ringRadius - _stroke
    readonly property real _innerRatio: _innerRadius / (Math.min(width, height) / 2)

    readonly property real _criticalFrac: isNaN(criticalStart)
        ? 0.75
        : Math.max(0.05, Math.min(0.74, (criticalStart - minValue) / (maxValue - minValue)))

    function rampColor(frac) {
        var f = Math.max(0, Math.min(1, frac))
        if (f >= _criticalFrac)
            return Theme.zoneCritical
        var hue = 0.155 * (1.0 - f / Math.max(_criticalFrac, 0.0001))
        return Qt.hsla(hue, 1.0, 0.5, 1.0)
    }

    function needleRotation(v) {
        var span = maxValue - minValue
        var frac = span <= 0 ? 0 : Math.max(0, Math.min(1, (v - minValue) / span))
        return startAngleDeg + sweepDeg * frac
    }

    readonly property real startAngleDeg: 225
    readonly property real sweepDeg: 270

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: "transparent"

            fillGradient: ConicalGradient {
                centerX: root.width / 2
                centerY: root.height / 2
                angle: -45
                stops: [
                    GradientStop { position: 0;     color: "#f7d038" },
                    GradientStop { position: 0.375; color: "#ff9f2e" },
                    GradientStop { position: root._criticalFrac; color: "#ff2d20" },
                    GradientStop { position: 0.75;  color: "#c40e0e" }
                ]
            }

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._ringRadius
                radiusY: root._ringRadius
                startAngle: root.startAngleDeg
                sweepAngle: -root.sweepDeg
            }

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._innerRadius
                radiusY: root._innerRadius
                startAngle: root.startAngleDeg - root.sweepDeg
                sweepAngle: root.sweepDeg
                moveToStart: false
            }
        }
    }

    Text {
        text: root.title
        color: Theme.titleColor
        font.pixelSize: Math.max(9, root._ringRadius * Theme.titleRatio * 0.8)
        font.weight: Font.DemiBold
        font.letterSpacing: root._ringRadius * 0.02
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height / 2 - height - root._ringRadius * 0.30
    }

    Text {
        id: valueText
        text: root.value.toFixed(root.valueDecimals)
        color: Theme.valueColor
        font.pixelSize: Math.max(18, root._ringRadius * Theme.valueRatio * 1.15)
        font.weight: Font.Bold
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height / 2 - height / 2 + root._ringRadius * 0.10
    }

    Text {
        text: root.unitLabel
        color: Theme.titleColor
        font.pixelSize: Math.max(9, root._ringRadius * Theme.unitRatio)
        font.weight: Font.Medium
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        y: valueText.y + valueText.height + root._ringRadius * 0.03
    }

    GaugeScale {
        anchors.fill: parent
        minValue: Math.round(root.minValue)
        maxValue: Math.round(root.maxValue)
        majorCount: root.majorCount
        tickRadiusRatio: root._innerRatio * 0.92
        labelRadiusRatio: root._innerRatio * 0.60
        tickLengthRatio: 0.075
    }

    Needle {
        anchors.centerIn: parent
        width: root.width
        height: root.height
        lengthRatio: root._innerRatio * 1.02
        targetRotation: root.needleRotation(root.value)
    }

    Rectangle {
        anchors.centerIn: parent
        width: root._ringRadius * 0.24
        height: width
        radius: width / 2
        color: Theme.hubColor
        border.color: Theme.hubBorder
        border.width: Math.max(1, root._ringRadius * 0.012)

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.42
            height: width
            radius: width / 2
            color: root.rampColor(
                Math.max(0, Math.min(1, (root.value - root.minValue) / Math.max(root.maxValue - root.minValue, 0.001))))
            opacity: 0.9
        }
    }
}
