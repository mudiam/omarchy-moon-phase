import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "Moon.js" as Moon

BarWidget {
    id: root
    moduleName: "jeffmtb.moon-phase"
    property date now: new Date()
    readonly property var moon: Moon.state(now)
    readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
    readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

    function open() {
        if (panelLoader.item)
            panelLoader.item.open();
    }
    function close() {
        if (panelLoader.item)
            panelLoader.item.close();
    }
    function toggle() {
        if (panelLoader.item)
            panelLoader.item.toggle();
    }
    function closeForPopoutSwitch() {
        if (panelLoader.item)
            panelLoader.item.closeForPopoutSwitch();
    }
    function refresh() {
        now = new Date();
    }
    function injectPanel() {
        if (!panelLoader.item)
            return;
        panelLoader.item.bar = root.bar;
        panelLoader.item.anchorItem = button;
        panelLoader.item.hostWidget = root;
    }

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight
    onBarChanged: injectPanel()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: root.now = date
    }
    Loader {
        id: panelLoader
        active: true
        source: Qt.resolvedUrl("Panel.qml")
        visible: false
        onLoaded: {
            root.injectPanel();
            Qt.callLater(root.injectPanel);
        }
    }

    WidgetButton {
        id: button
        anchors.fill: parent
        bar: root.bar
        labelVisible: false
        hasVisualContent: true
        implicitWidth: vertical ? barSize : contentRow.implicitWidth + scaledHorizontalMargin * 2
        implicitHeight: vertical ? barSize : Math.max(barSize, contentRow.implicitHeight + scaledVerticalPadding * 2)
        tooltipText: root.moon.name
        onPressed: root.toggle()

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.space(4)

            MoonIcon {
                width: Style.bar.iconCanvas
                height: width
                fraction: root.moon.fraction
                illuminatedColor: button.foreground
            }
        }
    }
}
