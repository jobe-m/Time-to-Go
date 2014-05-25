/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Cover {
    id: coverPage

    signal checkedIn()
    signal checkedOut()
    signal breakStarted()
    signal breakStopped()
    signal projectRotated()

    function updateProject(projectName) {
        // project can be only changed if not checked in
        if (state === "CHECKED_OUT") {
            projectLabel.text = projectName
        }
    }

    function updateWorkingTime(value) {

    }

    function updateBreakTime(value) {

    }

    function checkIn() {
        state = "CHECKED_IN"
        __showInfoText("Checked in now")
    }

    function checkOut() {
        state = "CHECKED_OUT"
        __showInfoText("Checked out now")
    }

    function startBreak() {
        state = "PAUSED"
        __showInfoText("start break now")
    }

    function stopBreak() {
        state = "CHECKED_IN"
        __showInfoText("continue with work now")
    }

    // internal stuff following here
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
            id: projectLabel
            anchors.top: appName.bottom
            anchors.topMargin: -Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 2 * Theme.paddingSmall
            color: Theme.primaryColor
            horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
            wrapMode: Text.NoWrap
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
        }

        OpacityRampEffect {
            enabled: projectLabel.implicitWidth > projectLabel.width
            sourceItem: projectLabel
            slope: 2.0
            offset: 0.5
        }

        Item {
            id: timeTrackerView
            anchors.top: projectLabel.bottom
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3 * Theme.paddingLarge

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 2 * Theme.paddingSmall
                spacing: 0

                Label {
                    id: coverTextLabel
                    enabled: text !== ""
                    visible: enabled
                    width: parent.width
                    color: Theme.secondaryColor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }

        Item {
            id: infoTextView
            property alias text: infoTextLabel.text
            opacity: 0.0
            anchors.top: projectLabel.bottom
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
        },
        State {
            name: "CHECKED_IN"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-pause" } // "../../icons/icon-cover-start-break.png" }
        },
        State {
            name: "PAUSED"
            PropertyChanges { target: rightAction; iconSource: "image://theme/icon-cover-timer" } // "../../icons/icon-cover-check-out.png" }
            PropertyChanges { target: leftAction; iconSource: "image://theme/icon-cover-play" } // "../../icons/icon-cover-stop-break.png" }
        }
    ]
}


