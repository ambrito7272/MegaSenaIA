import QtQuick
import QtQuick.Controls
import "../Menu"
import "../Theme.js" as Theme

PageShell {
    title: "Brilho"

    Column {
        id: brightnessColumn

        readonly property real base: Math.min(parent ? parent.width : 400, parent ? parent.height : 300)

        width: Math.min(base * 0.85, 520)
        spacing: base * 0.05
        anchors.centerIn: parent

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: (appSettings ? appSettings.brightness : 100) + "%"
            color: Theme.valueColor
            font.pixelSize: Math.max(28, brightnessColumn.base * 0.09)
            font.weight: Font.Bold
        }

        Slider {
            id: slider
            width: parent.width
            from: 20
            to: 100
            stepSize: 1
            value: appSettings ? appSettings.brightness : 100

            onMoved: appSettings.brightness = Math.round(value)
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: "O brilho é aplicado como atenuação do painel.\nControle direto da tela será usado no Android."
            color: Theme.titleColor
            font.pixelSize: Math.max(12, brightnessColumn.base * 0.032)
        }
    }
}
