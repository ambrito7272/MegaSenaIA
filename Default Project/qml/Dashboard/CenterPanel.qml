// CenterPanel — instrumentos secundários em grade geométrica:
//   ZONA A (topo):    TEMP · ÓLEO
//   ZONA B (meio):    BATERIA · VÁCUO
//   ZONA C (base):    AMP (opcional, centralizado no eixo vertical)
// Mesmo diâmetro para todos, eixo vertical único, sem elementos "soltos".
import QtQuick
import "../Theme.js" as Theme
import "." as Dash

Item {
    id: root

    property bool showAmperage: true

    readonly property int rowCount: showAmperage ? 3 : 2
    readonly property real spacing: Math.min(width, height) * 0.025
    readonly property real cellSide: Math.max(
        0, Math.min(width * 0.46,
                    (height - spacing * (rowCount - 1)) / rowCount))

    Column {
        anchors.centerIn: parent
        spacing: root.spacing

        Row {
            spacing: root.spacing
            anchors.horizontalCenter: parent.horizontalCenter

            Dash.GaugeCell {
                width: root.cellSide
                height: root.cellSide
                minValue: 50
                maxValue: 150
                majorCount: 6
                title: "TEMP"
                unitLabel: "°C"
                value: vehicle && vehicle.telemetry ? vehicle.telemetry.temperature : 0
                warningStart: 105
                criticalStart: 115
            }

            Dash.GaugeCell {
                width: root.cellSide
                height: root.cellSide
                minValue: 0
                maxValue: 10
                majorCount: 6
                title: "ÓLEO"
                unitLabel: "bar"
                value: vehicle && vehicle.telemetry ? vehicle.telemetry.oilPressure : 0
            }
        }

        Row {
            spacing: root.spacing
            anchors.horizontalCenter: parent.horizontalCenter

            Dash.GaugeCell {
                width: root.cellSide
                height: root.cellSide
                minValue: 8
                maxValue: 16
                majorCount: 5
                title: "BATERIA"
                unitLabel: "V"
                valueDecimals: 1
                value: vehicle && vehicle.telemetry ? vehicle.telemetry.batteryVoltage : 0
            }

            Dash.GaugeCell {
                width: root.cellSide
                height: root.cellSide
                minValue: 0
                maxValue: 100
                majorCount: 5
                title: "VÁCUO"
                unitLabel: "kPa"
                value: vehicle && vehicle.telemetry ? vehicle.telemetry.vacuum : 0
            }
        }

        Dash.GaugeCell {
            visible: root.showAmperage
            width: root.cellSide
            height: root.cellSide
            anchors.horizontalCenter: parent.horizontalCenter
            minValue: -60
            maxValue: 60
            majorCount: 5
            title: "AMP"
            unitLabel: "A"
            value: vehicle && vehicle.telemetry ? vehicle.telemetry.amperage : 0
        }
    }
}
