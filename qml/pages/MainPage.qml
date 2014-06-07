
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../scripts/Global.js" as Global


Page {
    id: mainPage

    function checkIn(value) {
        state = "CHECKED_IN"
        var date = new Date(value)
        var hour = date.getHours()
        var min = date.getMinutes()
        var sec = date.getSeconds()
        beginTime.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() /*+ ":" +
                (sec < 10 ? "0" : "") + sec.toString()*/
        beginTime.hour = hour
        beginTime.min = min
        beginTime.sec = sec
    }

    function checkOut(value) {
        state = "CHECKED_OUT"
        var date = new Date(value)
        var hour = date.getHours()
        var min = date.getMinutes()
        var sec = date.getSeconds()
        endTime.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() /*+ ":" +
                (sec < 10 ? "0" : "") + sec.toString()*/
        endTime.hour = hour
        endTime.min = min
        endTime.sec = sec
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

            Item {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge * 2
                height: beginDate.height

                Label {
                    id: beginDate
                    property int hour: 0
                    property int min: 0
                    property int sec: 0
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "--/--"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        }
                    }
                }

                IconButton {
                    id: dateIcon
                    anchors.left: beginDate.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-s-date"
                    highlighted: true
                }

                Label {
                    id: endDate
                    anchors.left: dateIcon.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "--/--"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        }
                    }
                }

                Label {
                    id: beginTime
                    property int hour: 0
                    property int min: 0
                    property int sec: 0
                    anchors.right: timeIcon.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "--:--" /* + ":--"*/

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                            hour: beginTime.hour,
                                                            minute: beginTime.min,
                                                            hourMode: DateTime.TwentyfourHours
                                                        })
                            dialog.accepted.connect(function() {
                                beginTime.text = dialog.timeText /*+ ":" +
                                        (beginTime.sec < 10 ? "0" : "") + beginTime.sec.toString()*/
                                beginTime.hour = dialog.hour
                                beginTime.min = dialog.minute
                                Global.updateWorkingStart(dialog.hour, dialog.minute)
                            })
                        }
                    }
                }

                IconButton {
                    id: timeIcon
                    anchors.right: endTime.left
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-s-time"
                    highlighted: true
                }

                Label {
                    id: endTime
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: "--:--" /* + ":--"*/

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                            hour: endTime.hour,
                                                            minute: endTime.min,
                                                            hourMode: DateTime.TwentyfourHours
                                                        })
                            dialog.accepted.connect(function() {
                                endTime.text = dialog.timeText /*+ ":" +
                                        (endTime.sec < 10 ? "0" : "") + endTime.sec.toString()*/
                                endTime.hour = dialog.hour
                                endTime.min = dialog.minute
                                Global.updateWorkingStart(dialog.hour, dialog.minute)
                            })
                        }
                    }
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
