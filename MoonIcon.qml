import QtQuick

// A projected lunar disk: the terminator is an ellipse whose width is set by
// the phase angle, rather than a fixed set of Unicode symbols.
Item {
    id: root

    property real fraction: 0
    property color illuminatedColor: "#ffffff"
    property color shadowColor: Qt.rgba(illuminatedColor.r,
                                        illuminatedColor.g,
                                        illuminatedColor.b,
                                        0.24)

    readonly property real phase: Math.max(0, Math.min(1, fraction))
    readonly property bool waxing: phase < 0.5
    readonly property real terminatorOffset: (waxing ? 1 : -1) * Math.cos(phase * 2 * Math.PI)

    implicitWidth: 16
    implicitHeight: 16

    Canvas {
        id: moonCanvas
        anchors.fill: parent
        antialiasing: true

        function paintMoon() {
            var size = Math.min(width, height)
            if (size <= 0)
                return

            var context = getContext("2d")
            var radius = size / 2
            var center = radius
            var terminatorRadius = Math.abs(root.terminatorOffset) * radius
            var side = root.terminatorOffset >= 0 ? 1 : -1
            var kappa = 0.5522847498
            var left = (width - size) / 2
            var top = (height - size) / 2

            context.clearRect(0, 0, width, height)
            context.save()
            context.translate(left, top)

            // The unlit hemisphere is a dim disk, so the icon still reads at
            // new moon and the illuminated area can be measured against it.
            context.beginPath()
            context.arc(center, center, radius, 0, 2 * Math.PI, false)
            context.fillStyle = root.shadowColor
            context.fill()

            // Trace the visible outer limb, then return along the projected
            // terminator. A half-ellipse is approximated by two Bezier arcs.
            context.beginPath()
            context.moveTo(center, 0)
            context.arc(center, center, radius, -Math.PI / 2, Math.PI / 2, !root.waxing)
            context.bezierCurveTo(center + side * kappa * terminatorRadius,
                                  size,
                                  center + side * terminatorRadius,
                                  center + kappa * radius,
                                  center + side * terminatorRadius,
                                  center)
            context.bezierCurveTo(center + side * terminatorRadius,
                                  center - kappa * radius,
                                  center + side * kappa * terminatorRadius,
                                  0,
                                  center,
                                  0)
            context.closePath()
            context.fillStyle = root.illuminatedColor
            context.fill()

            context.restore()
        }

        onPaint: paintMoon()
    }

    onFractionChanged: moonCanvas.requestPaint()
    onIlluminatedColorChanged: moonCanvas.requestPaint()
    onShadowColorChanged: moonCanvas.requestPaint()
    onWidthChanged: moonCanvas.requestPaint()
    onHeightChanged: moonCanvas.requestPaint()
}
