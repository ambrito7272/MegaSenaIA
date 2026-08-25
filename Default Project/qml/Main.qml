// NEODRIVE — janela principal: dashboard + menu de navegação.
import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme
import "Menu"
import "Dashboard"

ApplicationWindow {
    id: window

    visible: true
    visibility: Window.Maximized
    color: Theme.background
    title: "NEODRIVE"

    readonly property var pageSources: ({
        "settings": "Settings/SettingsPage.qml",
        "units": "Settings/UnitsPage.qml",
        "calibration": "Calibration/CalibrationPage.qml",
        "brightness": "Settings/BrightnessPage.qml",
        "communication": "Communication/CommunicationPage.qml",
        "diagnostics": "Diagnostics/DiagnosticsPage.qml",
        "parameters": "Settings/ParametersPage.qml",
        "systemInfo": "Settings/SystemInfoPage.qml"
    })

    property string currentPageKey: ""

    function closePage() {
        currentPageKey = ""
    }

    DashboardView {
        id: dashboard
        anchors.fill: parent
        visible: window.currentPageKey === ""
    }

    Rectangle {
        id: brightnessOverlay
        visible: opacity > 0.01
        opacity: (100 - (appSettings ? appSettings.brightness : 100)) / 100 * 0.65
        color: "#000000"
        anchors.fill: parent
        enabled: false
        z: 999
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        active: window.currentPageKey !== ""
        source: window.currentPageKey !== ""
                ? window.pageSources[window.currentPageKey] || ""
                : ""
        onLoaded: {
            if (item && item.backRequested)
                item.backRequested.connect(window.closePage)
            if (item && item.navigateRequested)
                item.navigateRequested.connect(function (key) {
                    window.currentPageKey = key
                })
        }
    }

    Rectangle {
        id: menuButton
        visible: window.currentPageKey === ""
        width: Math.max(38, Math.min(48, window.height * 0.06))
        height: width
        radius: width * 0.28
        color: Theme.glassFill
        border.color: Theme.glassBorder
        border.width: 1
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Math.max(10, window.width * 0.012)

        Column {
            spacing: menuButton.height * 0.16
            anchors.centerIn: parent

            Repeater {
                model: 3

                delegate: Rectangle {
                    required property int index
                    width: menuButton.width * 0.48
                    height: Math.max(2, menuButton.height * 0.065)
                    radius: height / 2
                    color: Theme.labelColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mainMenu.open = true
        }
    }

    MainMenu {
        id: mainMenu
        anchors.fill: parent
        onEntrySelected: (key) => window.currentPageKey = key
    }
}
