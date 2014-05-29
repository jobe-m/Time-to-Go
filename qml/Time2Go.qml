/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of Time2Go.
**
** Time2Go is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Time2Go is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Time2Go. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"
import "common"
import "scripts/Global.js" as Global

ApplicationWindow
{
    id: applicationWindow

    // For accessing main page to pass further application activity status
    property MainPage mainPageRef: null
    // For accessing info popup from everywhere make it global for the application
    property InfoPopup infoPopupRef: infoPopup

    // application global properties
    property string databaseUiName: ""

    initialPage: mainPageContainer
    cover: coverPage

    // Place info popup outside of page stack so that it is shown over all
    // application UI elements
    InfoPopup {
        id: infoPopup
    }

    Component {
        id: mainPageContainer
        MainPage {
            id: mainPage
            Component.onCompleted: mainPageRef = mainPage
        }
    }

    CoverPage {
        id: coverPage
        onCheckedIn: {
            Global.setWorkingStart()
            uiUpdateTimer.restart()
        }
        onCheckedOut: {
            Global.setWorkingEnd()
            uiUpdateTimer.stop()
            // update one last time cover page
            coverPage.updateWorkingTime(Global.getWorkingTime())
            coverPage.updateBreakTime(Global.getBreakTime())
        }
        onBreakStarted: {
            Global.setBreakStart()
        }
        onBreakStopped: {
            Global.setBreakEnd()
        }
        onProjectRotated: {}
    }

    Timer {
        id: uiUpdateTimer
        interval: 1000
        repeat: true
        onTriggered: {
            coverPage.updateWorkingTime(Global.getWorkingTime())
            coverPage.updateBreakTime(Global.getBreakTime())
        }
    }

    onApplicationActiveChanged: {
        // Application goes into background or returns to active focus again
        if (applicationActive) {
        } else {
        }
    }

    Component.onCompleted: {
        // initialize cover page
        coverPage.updateProject(Global.getActiveProject())
        coverPage.updateWorkingTime(Global.getWorkingTime())
        coverPage.updateBreakTime(Global.getBreakTime())
    }
}
