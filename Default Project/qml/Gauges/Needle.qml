// Ponteiro vetorial premium: base grossa, corpo afunilado, ponta fina.
// - Interpolação suave (90 ms) sem movimentos bruscos.
// - Rastro luminoso discreto: cópia fantasma com atraso maior (260 ms)
//   que só aparece durante o movimento e some ao estabilizar.
// - Brilho discreto: contorno translúcido acompanhando o corpo.
import QtQuick
import QtQuick.Shapes
import "../Theme.js" as Theme

Item {
    id: root

    property real lengthRatio: 0.80
    property real targetRotation: 0
    readonly property real _needleLen: Math.min(width, height) / 2 * lengthRatio
    readonly property real _scale: _needleLen / 160.0

    component NeedleGeometry : Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            fillColor: Theme.needleBase
            strokeColor: "transparent"

            startX: -7 * root._scale + root.width / 2
            startY: 18 * root._scale + root.height / 2

            PathLine { x: -1.6 * root._scale + root.width / 2; y: -root._needleLen * 0.82 + root.height / 2 }
            PathLine { x: 1.6 * root._scale + root.width / 2;  y: -root._needleLen * 0.82 + root.height / 2 }
            PathLine { x: 7 * root._scale + root.width / 2;    y: 18 * root._scale + root.height / 2 }
            PathLine { x: -7 * root._scale + root.width / 2;   y: 18 * root._scale + root.height / 2 }
        }

        ShapePath {
            fillColor: Theme.needleBody
            strokeColor: Qt.rgba(1, 1, 1, 0.16)
            strokeWidth: Math.max(1, 1.6 * root._scale)

            startX: -3.2 * root._scale + root.width / 2
            startY: 10 * root._scale + root.height / 2

            PathLine { x: -1.1 * root._scale + root.width / 2; y: -root._needleLen + root.height / 2 }
            PathLine { x: 1.1 * root._scale + root.width / 2;  y: -root._needleLen + root.height / 2 }
            PathLine { x: 3.2 * root._scale + root.width / 2;  y: 10 * root._scale + root.height / 2 }
            PathLine { x: -3.2 * root._scale + root.width / 2;  y: 10 * root._scale + root.height / 2 }
        }

        ShapePath {
            fillColor: Theme.needleTip
            strokeColor: "transparent"

            startX: -1.1 * root._scale + root.width / 2
            startY: -root._needleLen * 0.86 + root.height / 2

            PathLine { x: 0 + root.width / 2;                  y: -root._needleLen + root.height / 2 }
            PathLine { x: 1.1 * root._scale + root.width / 2;  y: -root._needleLen * 0.86 + root.height / 2 }
            PathLine { x: -1.1 * root._scale + root.width / 2;  y: -root._needleLen * 0.86 + root.height / 2 }
        }
    }

    NeedleGeometry {
        id: trail
        opacity: 0.12
        visible: Math.abs(rotation - root.targetRotation) > 0.5
        rotation: root.targetRotation

        Behavior on rotation {
            NumberAnimation { duration: 260; easing.type: Easing.OutQuad }
        }
    }

    NeedleGeometry {
        id: mainNeedle
        rotation: root.targetRotation

        Behavior on rotation {
            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
        }
    }
}
