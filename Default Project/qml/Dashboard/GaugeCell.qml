// GaugeCell — contêiner quadrado que mantém o manômetro sempre dentro
// do espaço disponível (evita corte em proporções extremas).
import QtQuick
import "../Theme.js" as Theme
import "../Gauges"

Item {
    id: root

    property real side: Math.min(width, height)
    property real minValue: 0
    property real maxValue: 100
    property int majorCount: 9
    property string title: ""
    property string unitLabel: ""
    property int valueDecimals: 0
    property real value: 0
    property real warningStart: NaN
    property real criticalStart: NaN

    ArcGauge {
        width: root.side
        height: root.side
        anchors.centerIn: parent
        minValue: root.minValue
        maxValue: root.maxValue
        majorCount: root.majorCount
        title: root.title
        unitLabel: root.unitLabel
        valueDecimals: root.valueDecimals
        value: root.value
        warningStart: root.warningStart
        criticalStart: root.criticalStart
    }
}
