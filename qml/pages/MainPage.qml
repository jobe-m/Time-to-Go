
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../scripts/Global.js" as Global


Page {
    id: mainPage

    function checkIn() {
        state = "CHECKED_IN"
    }

    function checkOut() {
        state = "CHECKED_OUT"
    }

    function startBreak() {
        state = "PAUSED"
    }

    function stopBreak() {
        state = "CHECKED_IN"
    }

    function setActiveProject(value) {
// TODO
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                enabled: mainPage.state === "CHECKED_OUT"
                visible: enabled
                text: qsTr("Check in")
                onClicked: {
                    applicationWindow.checkIn()
                }
            }

            MenuItem {
                enabled: mainPage.state === "CHECKED_IN"
                visible: enabled
                text: qsTr("Start break")
                onClicked: {
                    applicationWindow.startBreak()
                }
            }

            MenuItem {
                enabled: mainPage.state === "CHECKED_IN" || mainPage.state === "PAUSED"
                visible: enabled
                text: qsTr("Check out")
                onClicked: {
                    if (mainPage.state === "PAUSED") {
                        applicationWindow.stopBreak()
                    }
                    applicationWindow.checkOut()
                }
            }

            MenuItem {
                enabled: mainPage.state === "PAUSED"
                visible: enabled
                text: qsTr("Stop break")
                onClicked: {
                    applicationWindow.stopBreak()
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {}
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: {}
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: mainPage.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Time2Go")
            }

        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached(Qt.resolvedUrl("ReportPage.qml"))
        }
    }

    Component.onCompleted: {
    }

    state: "CHECKED_OUT"

    states: [
        State {
            name: "CHECKED_OUT"
        },
        State {
            name: "CHECKED_IN"
        },
        State {
            name: "PAUSED"
        },
        State {
            name: "AUTO_PAUSED"
        }
    ]
}
