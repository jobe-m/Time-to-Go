
import QtQuick 2.0
import Sailfish.Silica 1.0

Cover {
    id: coverPage

    signal checkedIn()
    signal checkedOut()
    signal breakStarted()
    signal breakStopped()
    signal projectRotated()

    // This function sets the project name which is visible on the cover page.
    // It can be only changed if not checked in.
    function updateProject(value) {
        if (state === "CHECKED_OUT") {
            projectName.text = value
        }
    }

    // This function sets the working time on the cover page.
    // It has to be invoked regularly to update the working time on the cover page.
    function updateWorkingTime(value) {
        workingTime.text = value
    }

    // This function sets the break time on the cover page..
    // It has to be invoked regularly to update the break time on the cover page.
    function updateBreakTime(value) {
        breakTime.text = value
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
        state = "PAUSED"
        __showInfoText("start break now")
    }

    // This function recovers the cover from paused and sets it back to checked in state.
    function stopBreak() {
        state = "CHECKED_IN"
        __showInfoText("continue with work now")
    }

    // internal stuff following here

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

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightColor, 0.2)

        Image {
            width: parent.width * 0.85
            height: width
            anchors.top: parent.top
            anchors.right: parent.right
// TODO add background image
//            source: "../../wallicons/cover-clock.png"
            opacity: 0.2
        }
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
            font.pixelSize: Theme.fontSizeMedium
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
                    font.pixelSize: Theme.fontSizeExtraLarge
                }

                Label {
                    id: breakTime
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
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
                    projectRotated()
                    break
                case "CHECKED_IN":
                    startBreak()
                    // send signal to application
                    breakStarted()
                    break
                case "PAUSED":
                    stopBreak()
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
                    checkIn()
                    // send signal to application
                    checkedIn()
                    break
                case "PAUSED":
                    // send signal to application
                    breakStopped()
                    // fall through
                case "CHECKED_IN":
                    checkOut()
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
            PropertyChanges { target: workingTime; color: Theme.secondaryColor; opacity: 0.6 }
            PropertyChanges { target: breakTime; color: Theme.secondaryColor; opacity: 0.6 }
        },
        State {
            name: "CHECKED_IN"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-pause" } // "../../icons/icon-cover-start-break.png" }
            PropertyChanges { target: workingTime; color: Theme.primaryColor; opacity: 1.0 }
            PropertyChanges { target: breakTime; color: Theme.secondaryColor; opacity: 0.6 }
        },
        State {
            name: "PAUSED"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-play" } // "../../icons/icon-cover-stop-break.png" }
            PropertyChanges { target: workingTime; color: Theme.secondaryColor; opacity: 0.6 }
            PropertyChanges { target: breakTime; color: Theme.primaryColor; opacity: 1.0 }
        }
    ]
}


