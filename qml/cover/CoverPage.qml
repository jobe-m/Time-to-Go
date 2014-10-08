
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: coverPage

    signal checkedIn()
    signal checkedOut()
    signal breakStarted()
    signal breakStopped()
    signal projectChanged()

    // This function set max working hours per day in seconds
    function setMaxWorkingTime(value) {
        __maxWorkingTime = value
    }

    // This function set active project name
    function setActiveProject(value) {
        if (state === "CHECKED_OUT") {
            projectName.text = value
        }
    }

    // This function set working time in seconds
    function setWorkingTime(value) {
        if (state === "CHECKED_IN") {
            __workingTime = value
            var sec = value
            var min = (sec/60).toFixedDown(0)
            var hour = (min/60).toFixedDown(0)
            workingTime.text = (hour < 10 ? "0" : "") + (hour).toString() + ":" +
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
            breakTime.text = (hour < 10 ? "0" : "") + (hour).toString() + ":" +
                    (min%60 < 10 ? "0" : "") + (min%60).toString() + ":" +
                    (sec%60 < 10 ? "0" : "") + (sec%60).toString()
        }
    }

    // This function changes the cover into check in state.
    function checkIn() {
        state = "CHECKED_IN"
        __showInfoText("Checked in now")
    }

    // This function changes the cover into checked out state.
    function checkOut() {
        state = "CHECKED_OUT"
        __showInfoText("Checked out now")
    }

    // This function changes the cover into paused state.
    function startBreak() {
        if (state === "CHECKED_IN") {
            state = "PAUSED"
            __showInfoText("start break now")
        }
    }

    // This function recovers the cover from paused and sets it back to checked in state.
    function stopBreak() {
        if (state === "PAUSED") {
            state = "CHECKED_IN"
            __showInfoText("continue with work now")
        }
    }

    // This function changes the cover into automatic paused state.
    function startAutoBreak() {
        if (state === "CHECKED_IN") {
            state = "AUTO_PAUSED"
            __showInfoText("start automatic break now")
        }
    }

    // This function recovers the cover from automatic paused and sets it back to checked in state.
    function stopAutoBreak() {
        if (state === "AUTO_PAUSED") {
            state = "CHECKED_IN"
            __showInfoText("automatic break finished")
        }
    }

    // internal stuff following here
    property string __prev_state: ""
    property int __maxWorkingTime: 60*60*9999 // in seconds
    property int __workingTime: 0 // in seconds

    // This function shows an info text on the cover which will fade out after 2 seconds.
    function __showInfoText(value) {
        infoTextView.text = value
        timeTrackerView.opacity = 0.0
        infoTextView.opacity = 1.0
        infoTextTimer.restart()
    }

    anchors.centerIn: parent
    width: Theme.coverSizeLarge.width
    height: Theme.coverSizeLarge.height

    Image {
        width: parent.width * 0.85
        height: width
        anchors.top: parent.top
        anchors.right: parent.right
// TODO add background image
//        source: "../../wallicons/cover-clock.png"
        opacity: 0.2
    }

    Timer {
        id: infoTextTimer
        repeat: false
        interval: 2000
        onTriggered: {
            infoTextFadeOut.start()
            entryDetailsFadeIn.start()
        }
    }

    NumberAnimation {
        id: infoTextFadeOut
        target: infoTextView
        property: "opacity"
        duration: 500
        to: 0.0
    }
    NumberAnimation {
        id: entryDetailsFadeIn
        target: timeTrackerView
        property: "opacity"
        duration: 500
        to: 1.0
    }

    Item {
        anchors.fill: parent

        Label {
            id: appName
            y: Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.secondaryColor
            opacity: 0.7
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            text: "Time2Go"
        }

        Label {
            id: projectName
            anchors.top: appName.bottom
            anchors.topMargin: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.primaryColor
            horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
            wrapMode: Text.NoWrap
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
        }

        OpacityRampEffect {
            enabled: projectName.implicitWidth > projectName.width
            sourceItem: projectName
            slope: 2.0
            offset: 0.5
        }

        Item {
            id: timeTrackerView
            anchors.top: projectName.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.paddingSmall
                spacing: 0

                Label {
                    id: workingTime
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeHuge
                    text: "--:--:--"
                    color: __workingTime > __maxWorkingTime ?
                               "red" : (coverPage.state === "CHECKED_IN" ?
                                            Theme.primaryColor : Theme.secondaryColor)
                    opacity: coverPage.state === "CHECKED_IN" ? 1.0 : 0.6
                }

                Label {
                    id: breakTime
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "--:--:--"
                }
            }
        }

        Item {
            id: infoTextView
            property alias text: infoTextLabel.text
            opacity: 0.0
            anchors.top: projectName.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Label {
                id: infoTextLabel
                anchors.centerIn: parent
                width: parent.width - 2 * Theme.paddingLarge
                height: width
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }

    CoverActionList {
        iconBackground: false

        CoverAction {
            id: leftAction
            onTriggered: {
                switch (coverPage.state) {
                case "CHECKED_OUT":
                    // send signal to application
                    projectChanged()
                    break
                case "CHECKED_IN":
                    // send signal to application
                    breakStarted()
                    break
                case "PAUSED":
                    // send signal to application
                    breakStopped()
                    break
                }
            }
        }

        CoverAction {
            id: rightAction
            onTriggered: {
                switch (coverPage.state) {
                case "CHECKED_OUT":
                    // send signal to application
                    checkedIn()
                    break
                case "PAUSED":
                    // send signal to application
                    breakStopped()
                    // fall through
                case "CHECKED_IN":
                    // send signal to application
                    checkedOut()
                    break
                }
            }
        }
    }

    state: "CHECKED_OUT"

    states: [
        State {
            name: "CHECKED_OUT"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-play" } // "../../icons/icon-cover-check-in.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-next" } // "../../icons/icon-cover-project.png" }
            PropertyChanges { target: breakTime; color: Theme.secondaryColor; opacity: 0.6 }
        },
        State {
            name: "CHECKED_IN"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-pause" } // "../../icons/icon-cover-start-break.png" }
            PropertyChanges { target: breakTime; color: Theme.secondaryColor; opacity: 0.6 }
        },
        State {
            name: "PAUSED"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-play" } // "../../icons/icon-cover-stop-break.png" }
            PropertyChanges { target: breakTime; color: Theme.primaryColor; opacity: 1.0 }
        },
        State {
            name: "AUTO_PAUSED"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-pause" } // "../../icons/icon-cover-start-break.png" }
            PropertyChanges { target: breakTime; color: Theme.primaryColor; opacity: 1.0 }
        }
    ]
}


