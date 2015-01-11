
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: breakTimeLine

    property alias textColor: breakTime.textColor

    signal breakTimeChanged(int seconds)

    function reset() {
        hours = 0
        minutes = 0
    }

    // internal
    property int hours: 0
    property int minutes: 0

    x: Theme.paddingLarge
    width: parent.width - Theme.paddingLarge * 2
    height: breakTime.height

    IconButton {
        id: timeIcon
        anchors.right: breakTime.left
        anchors.verticalCenter: parent.verticalCenter
        icon.source: "image://theme/icon-s-time"
        highlighted: true
    }

    HourMinutesSeconds {
        id: breakTime
        hours: parent.hours.toString()
        minutes: parent.minutes.toString()
        anchors.right: parent.right
        showSeconds: false
        textSize: Theme.fontSizeMedium
        symbolSize: Theme.fontSizeExtraSmall

        MouseArea {
            anchors.fill: parent
            enabled: breakTimeLine.enabled
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                hour: breakTimeLine.hours,
                                                minute: breakTimeLine.minutes,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    breakTimeLine.hours = dialog.hour
                    breakTimeLine.minutes = dialog.minute
                    // Check if date was already set. If not set it to current date
                    breakTimeChanged((60 * breakTimeLine.minutes) + (60 * 60 * breakTimeLine.hours))
                })
            }
        }
    }
}
