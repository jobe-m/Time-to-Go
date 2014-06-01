
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
        workBeginLabel.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() + ":" +
                (sec < 10 ? "0" : "") + sec.toString()
        workBeginLabel.hour = hour
        workBeginLabel.min = min
        workBeginLabel.sec = sec
    }

    function checkOut(value) {
        state = "CHECKED_OUT"
        var date = new Date(value)
        var hour = date.getHours()
        var min = date.getMinutes()
        var sec = date.getSeconds()
        workEndLabel.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() + ":" +
                (sec < 10 ? "0" : "") + sec.toString()
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
        workBeginLabel.text = value
    }

    function setWorkEnd(value) {
        workEndLabel.text = value
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
                text: qsTr("Working begin and end")
            }

            Item {
                x: Theme.paddingLarge
                width: parent.width - Theme.paddingLarge * 2
                height: workBeginLabel.height

                Label {
                    id: workBeginLabel
                    property int hour: 0
                    property int min: 0
                    property int sec: 0
                    anchors.top: parent.top
                    anchors.left: parent.left
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "--:--:--"
                }

                IconButton {
                    anchors.left: workBeginLabel.right
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-right"
                    onClicked: {
                        var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                        hour: workBeginLabel.hour,
                                                        minute: workBeginLabel.min,
                                                        hourMode: DateTime.TwentyfourHours
                                                    })
                        dialog.accepted.connect(function() {
                            workBeginLabel.text = dialog.timeText + ":" +
                                    (workBeginLabel.sec < 10 ? "0" : "") + workBeginLabel.sec.toString()
                            workBeginLabel.hour = dialog.hour
                            workBeginLabel.min = dialog.minute
                            Global.updateWorkingStart(dialog.hour, dialog.minute)
                        })
                    }
                }

                Label {
                    id: workEndLabel
                    anchors.top: parent.top
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "--:--:--"
                }
            }

            SectionHeader {
                text: qsTr("Break begin and end")
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
