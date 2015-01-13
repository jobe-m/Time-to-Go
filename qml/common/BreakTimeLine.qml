
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: breakTimeLine

    property alias textColor: breakTime.textColor

    signal breakTimeChanged(int seconds)

    function setTime(seconds) {
        __hours = (seconds/(60*60)).toFixedDown(0)
        __minutes = (seconds/60 % 60).toFixedDown(0)
    }

    function reset() {
        __hours = 0
        __minutes = 0
    }

    // internal
    property int __hours: 0
    property int __minutes: 0

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
        hours: __hours.toString()
        minutes: __minutes.toString()
        anchors.right: parent.right
        showSeconds: false
        margin: Theme.paddingSmall
        textSize: Theme.fontSizeMedium
        symbolSize: Theme.fontSizeExtraSmall

        MouseArea {
            anchors.fill: parent
            enabled: breakTimeLine.enabled
            onClicked: {
                var dialog = pageStack.push("Sailfish.Silica.TimePickerDialog", {
                                                hour: __hours,
                                                minute: __minutes,
                                                hourMode: DateTime.TwentyfourHours
                                            })
                dialog.accepted.connect(function() {
                    __hours = dialog.hour
                    __minutes = dialog.minute
                    // Check if date was already set. If not set it to current date
                    breakTimeChanged((60 * __minutes) + (60 * 60 * __hours))
                })
            }
        }
    }
}
