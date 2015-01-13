import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property string hours: "--"
    property string minutes: "--"
    property string seconds: "--"
    property bool showSeconds: false
    property int margin: 0
    property int textSize: Theme.fontSizeHuge
    property int symbolSize: Theme.fontSizeMedium
    property color textColor: Theme.primaryColor

    width: hoursLabel.width + hoursSymbol.width +
           minutesLabel.width + minutesSymbol.width +
           (showSeconds ? secondsLabel.width + secondsSymbol.width : 0)
    height: hoursLabel.height

    Label {
        id: hoursLabel
        anchors.left: parent.left
        anchors.top: parent.top
        font.family: Theme.fontFamily
        font.pixelSize: textSize
        text: hours
        color: textColor
    }

    Label {
        id: hoursSymbol
        visible: hoursLabel.text !== "--"
        anchors.left: hoursLabel.right
        anchors.baseline: hoursLabel.baseline
        font.family: Theme.fontFamily
        font.pixelSize: symbolSize
        text: "h"
        color: textColor
    }

    Label {
        id: minutesLabel
        anchors.left: hoursSymbol.right
        anchors.leftMargin: parent.margin
        anchors.baseline: hoursLabel.baseline
        font.family: Theme.fontFamily
        font.pixelSize: textSize
        text: minutes
        color: textColor
    }

    Label {
        id: minutesSymbol
        visible: minutesLabel.text !== "--"
        anchors.left: minutesLabel.right
        anchors.baseline: minutesLabel.baseline
        font.family: Theme.fontFamily
        font.pixelSize: symbolSize
        text: "m"
        color: textColor
    }

    Label {
        id: secondsLabel
        enabled: showSeconds
        visible: showSeconds
        anchors.left: minutesSymbol.right
        anchors.leftMargin: parent.margin
        anchors.baseline: hoursLabel.baseline
        font.family: Theme.fontFamily
        font.pixelSize: textSize
        text: seconds
        color: textColor
    }

    Label {
        id: secondsSymbol
        enabled: showSeconds
        visible: showSeconds && secondsLabel.text !== "--"
        anchors.left: secondsLabel.right
        anchors.baseline: hoursLabel.baseline
        font.family: Theme.fontFamily
        font.pixelSize: symbolSize
        text: "s"
        color: textColor
    }
}
