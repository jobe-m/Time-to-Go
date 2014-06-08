
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: dateTimeLine

    property bool showSec: false

    signal beginDateChanged(int year, int month, int day)
    signal beginTimeChanged(int hour, int minute)
    signal endDateChanged(int year, int month, int day)
    signal endTimeChanged(int hour, int minute)

    function setBeginDate(year, month, day) {
        beginYear = year
        beginMonth = month
        beginDay = day
        beginDate.text = (day < 10 ? "0" : "") + day.toString() + "/" +
                (month < 10 ? "0" : "") + month.toString()
    }

    function setBeginTime(hour, min, sec) {
        beginHour = hour
        beginMin = min
        beginSec = sec
        beginTime.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() +
                (showSec ? ":" + (sec < 10 ? "0" : "") + sec.toString() : "")
    }

    function setEndDate(year, month, day) {
        endYear = year
        endMonth = month
        endDay = day
        endDate.text = (day < 10 ? "0" : "") + day.toString() + "/" +
                (month < 10 ? "0" : "") + month.toString()
    }

    function setEndTime(hour, min, sec) {
        endHour = hour
        endMin = min
        endSec = sec
        endTime.text = (hour < 10 ? "0" : "") + hour.toString() + ":" +
                (min < 10 ? "0" : "") + min.toString() +
                (showSec ? ":" + (sec < 10 ? "0" : "") + sec.toString() : "")
    }

    // internal
    property int beginDay: 0
    property int beginMonth: 0
    property int beginYear: 0
    property int beginHour: 0
    property int beginMin: 0
    property int beginSec: 0
    property int endDay: 0
    property int endMonth: 0
    property int endYear: 0
    property int endHour: 0
    property int endMin: 0
    property int endSec: 0

    x: Theme.paddingLarge
    width: parent.width - Theme.paddingLarge * 2
    height: beginDate.height

    Label {
        id: beginDate
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        text: "--/--"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: new Date(dateTimeLine.beginYear + "/" +
                                                               dateTimeLine.beginMonth + "/" +
                                                               dateTimeLine.beginDay)
                                            })
                dialog.accepted.connect(function() {
                    dateTimeLine.setBeginDate(dialog.year, dialog.month, dialog.day)
                    beginDateChanged(dialog.year, dialog.month, dialog.day)
                })
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
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                                date: new Date(dateTimeLine.endYear + "/" +
                                                               dateTimeLine.endMonth + "/" +
                                                               dateTimeLine.endDay)
                                            })
                dialog.accepted.connect(function() {
                    dateTimeLine.setEndDate(dialog.year, dialog.month, dialog.day)
                    endDateChanged(dialog.year, dialog.month, dialog.day)
                })
            }
        }
    }

    Label {
        id: beginTime
        anchors.right: timeIcon.left
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: Theme.fontSizeMedium
        text: dateTimeLine.showSec ? "--:--:--" : "--:--"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                hour: dateTimeLine.beginHour,
                                                minute: dateTimeLine.beginMin,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    dateTimeLine.setBeginTime(dialog.hour, dialog.minute, dateTimeLine.beginSec)
                    beginTimeChanged(dialog.hour, dialog.minute)
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
                                                hour: dateTimeLine.endHour,
                                                minute: dateTimeLine.endMin,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    dateTimeLine.setEndTime(dialog.hour, dialog.minute, dateTimeLine.beginSec)
                    endTimeChanged(dialog.hour, dialog.minute)
                })
            }
        }
    }
}
