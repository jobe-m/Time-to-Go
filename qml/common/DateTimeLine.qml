
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: dateTimeLine

    property bool showSec: false

    signal startChanged(date dateTime)
    signal endChanged(date dateTime)

    function setStartDateTime(value) {
        startYear = value.getFullYear()
        startMonth = value.getMonth() + 1
        startDay = value.getDate()
        startHour = value.getHours()
        startMin = value.getMinutes()
        startSec = value.getSeconds()
        updateStartDate()
        updateStartTime()
    }

    function setEndDateTime(value) {
        endYear = value.getFullYear()
        endMonth = value.getMonth() + 1
        endDay = value.getDate()
        endHour = value.getHours()
        endMin = value.getMinutes()
        endSec = value.getSeconds()
        updateEndDate()
        updateEndTime()
    }

    function updateStartDate() {
        startDate.text = (startDay < 10 ? "0" : "") + startDay.toString() + "/" +
                (startMonth < 10 ? "0" : "") + startMonth.toString()
    }

    function updateStartTime() {
        startTime.text = (startHour < 10 ? "0" : "") + startHour.toString() + ":" +
                (startMin < 10 ? "0" : "") + startMin.toString() +
                (showSec ? ":" + (startSec < 10 ? "0" : "") + startSec.toString() : "")
    }

    function updateEndDate() {
        endDate.text = (endDay < 10 ? "0" : "") + endDay.toString() + "/" +
                (endMonth < 10 ? "0" : "") + endMonth.toString()
    }

    function updateEndTime() {
        endTime.text = (endHour < 10 ? "0" : "") + endHour.toString() + ":" +
                (endMin < 10 ? "0" : "") + endMin.toString() +
                (showSec ? ":" + (endSec < 10 ? "0" : "") + endSec.toString() : "")
    }

    // internal
    property int startYear: 0
    property int startMonth: 0
    property int startDay: 0
    property int startHour: 0
    property int startMin: 0
    property int startSec: 0
    property int endYear: 0
    property int endMonth: 0
    property int endDay: 0
    property int endHour: 0
    property int endMin: 0
    property int endSec: 0

    x: Theme.paddingLarge
    width: parent.width - Theme.paddingLarge * 2
    height: startDate.height

    Label {
        id: startDate
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        text: "--/--"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: (startDay === 0 || startMonth === 0 || startYear === 0) ?
                                                          new Date()
                                                        : new Date(startYear + "/" + startMonth + "/" + startDay)
                                            })
                dialog.accepted.connect(function() {
                    startYear = dialog.year
                    startMonth = dialog.month
                    startDay = dialog.day
                    updateStartDate()
                    startChanged(new Date(startYear, startMonth, startDay, startHour, startMin, startSec, 0))
                })
            }
        }
    }

    IconButton {
        id: dateIcon
        anchors.left: startDate.right
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
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: (endDay === 0 || endMonth === 0 || endYear === 0) ?
                                                          new Date()
                                                        : new Date(endYear + "/" + endMonth + "/" + endDay)
                                            })
                dialog.accepted.connect(function() {
                    endYear = dialog.year
                    endMonth = dialog.month
                    endDay = dialog.day
                    updateEndDate()
                    endChanged(new Date(endYear, endMonth, endDay, endHour, endMin, endSec, 0))
                })
            }
        }
    }

    Label {
        id: startTime
        anchors.right: timeIcon.left
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        text: dateTimeLine.showSec ? "--:--:--" : "--:--"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                hour: startHour,
                                                minute: startMin,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    startHour = dialog.hour
                    startMin = dialog.minute
                    // Check if date was already set. If not set it to current date
                    if (startDay === 0 || startMonth === 0 || startYear === 0) {
                        var now = new Date()
                        startYear = now.getFullYear()
                        startMonth = now.getMonth() + 1
                        startDay = now.getDate()
                        updateStartDate()
                    }
                    updateStartTime()
                    startChanged(new Date(startYear, startMonth, startDay, startHour, startMin, startSec, 0))
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
        property int hour: 0
        property int min: 0
        property int sec: 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        text: dateTimeLine.showSec ? "--:--:--" : "--:--"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                hour: endHour,
                                                minute: endMin,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    endHour = dialog.hour
                    endMin = dialog.minute
                    // Check if date was already set. If not set it to current date
                    if (endDay === 0 || endMonth === 0 || endYear === 0) {
                        var now = new Date()
                        endYear = now.getFullYear()
                        endMonth = now.getMonth() + 1
                        endDay = now.getDate()
                        updateEndDate()
                    }
                    updateEndTime()
                    endChanged(new Date(endYear, endMonth, endDay, endHour, endMin, endSec, 0))
                })
            }
        }
    }
}
