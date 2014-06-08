
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../common"
import "../scripts/Global.js" as Global


Page {
    id: mainPage

    function checkIn(value) {
        state = "CHECKED_IN"
        var date = new Date(value)
        var hour = date.getHours()
        var min = date.getMinutes()
        var sec = date.getSeconds()
        var day = date.getDate()
        var month = date.getMonth() + 1
        var year = date.getFullYear()

        workDateTimeLine.setBeginDate(year, month, day)
        workDateTimeLine.setBeginTime(hour, min, sec)
    }

    function checkOut(value) {
        state = "CHECKED_OUT"
        var date = new Date(value)
        var hour = date.getHours()
        var min = date.getMinutes()
        var sec = date.getSeconds()
        var day = date.getDate()
        var month = date.getMonth() + 1
        var year = date.getFullYear()

        workDateTimeLine.setEndDate(year, month, day)
        workDateTimeLine.setEndTime(hour, min, sec)
    }

    function startBreak() {
        state = "PAUSED"
    }

    function stopBreak() {
        state = "CHECKED_IN"
    }

    function setActiveProject(value) {
        activeProjectLabel.text = value
    }

    function setWorkBegin(value) {
        beginTime.text = value
    }

    function setWorkEnd(value) {
        endTime.text = value
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

            SectionHeader {
                text: qsTr("Active project")
            }

            Label {
                id: activeProjectLabel
                x: Theme.paddingLarge
                width: (parent ? parent.width : Screen.width) - Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            SectionHeader {
                text: qsTr("Begin and end of work unit")
            }

            DateTimeLine {
                id: workDateTimeLine

                onBeginDateChanged: {
                    Global.updateWorkingStartDate(year, month, day)
                }

                onBeginTimeChanged: {
                    Global.updateWorkingStartTime(hour, minute)
                }

                onEndDateChanged: {
                    Global.updateWorkingEndDate(year, month, day)
                }

                onEndTimeChanged: {
                    Global.updateWorkingEndTime(hour, minute)
                }
            }

            SectionHeader {
                text: qsTr("Begin and end of break(s)")
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
