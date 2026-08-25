// DashboardView — grade única do painel:
//   ZONA 2 (principal): VELOCÍMETRO | secundários | TACÔMETRO (iguais)
//   ZONA 4 (rodapé):    TRIP · COMBUSTÍVEL · RELÓGIO alinhados na mesma linha
// Paisagem: linha; Retrato: pilha (velocímetro/tacômetro no topo).
import QtQuick
import QtQuick.Layouts
import "../Theme.js" as Theme
import "../Gauges"
import "." as Dash

Item {
    id: root

    readonly property bool landscape: width >= height
    readonly property real margin: Math.min(width, height) * 0.03
    readonly property var t: vehicle ? vehicle.telemetry : null
    readonly property real footerHeight: Math.max(30, height * 0.065)

    Loader {
        id: clusterLoader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.margins: root.margin
        sourceComponent: root.landscape ? landscapeCluster : portraitCluster
    }

    Component {
        id: landscapeCluster

        RowLayout {
            anchors.fill: parent
            spacing: parent.width * 0.02

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: Math.min(parent.height * 0.92, parent.width * 0.34)

                Dash.GaugeCell {
                    anchors.centerIn: parent
                    side: Math.min(parent.width, parent.height)
                    minValue: 0
                    maxValue: 220
                    majorCount: 12
                    title: "VELOCIDADE"
                    unitLabel: "km/h"
                    value: root.t ? root.t.speed : 0
                    warningStart: 140
                    criticalStart: 180
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Dash.CenterPanel {
                    anchors.fill: parent
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: Math.min(parent.height * 0.92, parent.width * 0.34)

                Dash.GaugeCell {
                    anchors.centerIn: parent
                    side: Math.min(parent.width, parent.height)
                    minValue: 0
                    maxValue: 8000
                    majorCount: 9
                    title: "RPM"
                    unitLabel: "rpm"
                    value: root.t ? root.t.rpm : 0
                    warningStart: 5000
                    criticalStart: 6500
                }
            }
        }
    }

    Component {
        id: portraitCluster

        ColumnLayout {
            anchors.fill: parent
            spacing: parent.height * 0.02

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(parent.width * 0.48, parent.height * 0.42)

                RowLayout {
                    anchors.fill: parent
                    spacing: parent.width * 0.02

                    Dash.GaugeCell {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        minValue: 0
                        maxValue: 220
                        majorCount: 12
                        title: "VELOCIDADE"
                        unitLabel: "km/h"
                        value: root.t ? root.t.speed : 0
                        warningStart: 140
                        criticalStart: 180
                    }

                    Dash.GaugeCell {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        minValue: 0
                        maxValue: 8000
                        majorCount: 9
                        title: "RPM"
                        unitLabel: "rpm"
                        value: root.t ? root.t.rpm : 0
                        warningStart: 5000
                        criticalStart: 6500
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Dash.CenterPanel {
                    anchors.fill: parent
                }
            }
        }
    }

    // ZONA 4 — rodapé alinhado: TRIP · combustível · relógio
    Item {
        id: footer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: root.margin
        height: root.footerHeight

        Text {
            text: root.t ? ("TRIP  " + root.t.trip.toFixed(1) + " km") : ""
            color: Theme.labelColor
            font.pixelSize: Math.max(12, footer.height * 0.42)
            font.weight: Font.Medium
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Dash.FuelBar {
            width: Math.min(parent.width * 0.3, 260)
            height: parent.height * 0.62
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            level: root.t ? root.t.fuel : 0
        }

        Text {
            text: root.t ? root.t.clock : ""
            color: Theme.valueColor
            font.pixelSize: Math.max(14, footer.height * 0.62)
            font.weight: Font.Bold
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        id: alertBanner
        visible: vehicle ? vehicle.alertLevel > 0 : false
        readonly property int level: vehicle ? vehicle.alertLevel : 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: root.margin
        width: Math.min(parent.width * 0.7, alertText.implicitWidth + parent.height * 0.06)
        height: Math.max(28, parent.height * 0.055)
        radius: height / 2
        color: level >= 2 ? Theme.zoneCritical : Theme.zoneWarning
        opacity: 0.92

        Text {
            id: alertText
            anchors.centerIn: parent
            width: Math.min(implicitWidth, alertBanner.width - alertBanner.height * 0.4)
            text: vehicle ? vehicle.alertText : ""
            color: "#101216"
            font.pixelSize: Math.max(12, alertBanner.height * 0.45)
            font.weight: Font.Bold
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
