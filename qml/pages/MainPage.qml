
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.Time2Go.DatabaseQuery 1.0
import "../common"
import "../scripts/Global.js" as Global


Page {
    id: mainPage

    property alias activeProjectUid: time2GoActiveProject.uid

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

//    function setActiveProject(value) {
//        activeProjectLabel.text = value
//    }

    function setWorkBegin(value) {
        beginTime.text = value
    }

    function setWorkEnd(value) {
        endTime.text = value
    }

    // This function set working time in seconds
    function setWorkingTime(value) {
        if (state === "CHECKED_IN") {
            __workingTime = value
            var sec = value
            var min = (sec/60).toFixedDown(0)
            var hour = (min/60).toFixedDown(0)
            workingTimeDay.text = (hour < 10 ? "0" : "") + (hour).toString() + ":" +
                    (min%60 < 10 ? "0" : "") + (min%60).toString() + ":" +
                    (sec%60 < 10 ? "0" : "") + (sec%60).toString()
        }
    }

    // This function set break time in seconds
    function setBreakTime(value, automaticBreakTime) {
        // Check if cover needs to change to auto break state
        if ((automaticBreakTime > 0 && automaticBreakTime < 60*60*0.5) ||
                (automaticBreakTime > 60*60*0.5 && automaticBreakTime < 60*60*0.75)) {
            startAutoBreak()
        } else if (automaticBreakTime > 0) {
            stopAutoBreak()
        }

        if (state === "PAUSED" || state === "AUTO_PAUSED") {
            var sec = value
            var min = (sec/60).toFixedDown(0)
            var hour = (min/60).toFixedDown(0)
            breakTimeDay.text = (hour < 10 ? "0" : "") + (hour).toString() + ":" +
                    (min%60 < 10 ? "0" : "") + (min%60).toString() + ":" +
                    (sec%60 < 10 ? "0" : "") + (sec%60).toString()
        }
    }

    // This function changes the main page into automatic paused state.
    function startAutoBreak() {
        if (state === "CHECKED_IN") {
            state = "AUTO_PAUSED"
        }
    }

    // This function recovers the main page from automatic paused and sets it back to checked in state.
    function stopAutoBreak() {
        if (state === "AUTO_PAUSED") {
            state = "CHECKED_IN"
        }
    }

    // internal
    property int __maxWorkingTime: 60*60*9999 // in seconds
    property int __workingTime: 0 // in seconds

    Time2GoProject {
        id: time2GoActiveProject

        onDbQueryError: {
            console.log("Time2GoProject error: " + errorText)
        }
    }

//    Time2GoWorkUnit {
//        id: time2GoWorkUnit
//        activeProject: time2GoActiveProject.uid
//    }

//    Time2GoBreaksListModel {
//        id: time2GoBreaksListModel
//        activeWorkUnit: time2GoWorkUnit.uid
//    }

//    Time2GoWorkingTimeDay {
//    }

//    Time2GoWorkingTimeWeek {
//    }

//    Time2GoWorkingTimeMonth {
//    }

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
                text: time2GoActiveProject.name
            }

            SectionHeader {
                text: qsTr("Time spend on active project")
            }

            Item {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge * 2
                height: dayLabel.height + workingTimeDay.height + breakTimeDay.height

                Label {
                    id: dayLabel
                    anchors.top: parent.top
                    anchors.left: parent.left
                    width: parent.width * 2/3
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Day")
                }

                Label {
                    id: workingTimeDay
                    anchors.top: dayLabel.bottom
                    anchors.left: parent.left
                    anchors.right: dayLabel.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "--:--:--"
                    color: __workingTime > __maxWorkingTime ?
                               "red" : (mainPage.state === "CHECKED_IN" ?
                                            Theme.primaryColor : Theme.secondaryColor)
                }

                Label {
                    id: breakTimeDay
                    anchors.top: workingTimeDay.bottom
                    anchors.left: parent.left
                    anchors.right: dayLabel.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "--:--:--"
                }

                Label {
                    id: weekLabel
                    anchors.top: parent.top
                    anchors.left: dayLabel.right
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Week")
                }

                Label {
                    id: workingTimeWeek
                    anchors.top: weekLabel.bottom
                    anchors.left: weekLabel.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "13:20"
                }

                Label {
                    id: monthLabel
                    anchors.top: workingTimeWeek.bottom
                    anchors.left: weekLabel.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    text: qsTr("Month")
                }

                Label {
                    id: workingTimeMonth
                    anchors.top: monthLabel.bottom
                    anchors.left: weekLabel.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "124:37"
                }
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
