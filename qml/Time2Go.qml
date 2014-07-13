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
    property MainPage mainPage: null

    // application global properties and functions
    function checkIn() {
        Global.setWorkingStart()
        coverPage.checkIn()
        mainPage.checkIn(Global.getWorkBeginTime())
        uiUpdateTimer.restart()
    }

    function checkOut() {
        Global.setWorkingEnd()
        coverPage.checkOut()
        mainPage.checkOut(Global.getWorkEndTime())
        uiUpdateTimer.stop()
    }

    function startBreak() {
        Global.setBreakStart()
        coverPage.startBreak()
        mainPage.startBreak()
    }

    function stopBreak() {
        Global.setBreakEnd()
        coverPage.stopBreak()
        mainPage.stopBreak()
    }

    function setProject(value) {
        // if no project name was given then just take next available project
        if (value === "") {
            Global.activateNextProject()
        } else {
            Global.activateProject(value);
        }
        coverPage.setActiveProject(Global.getActiveProject())
        mainPage.setActiveProject(Global.getActiveProject())
    }

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
            id: mainPageObj
            Component.onCompleted: mainPage = mainPageObj
        }
    }

    CoverPage {
        id: coverPage
        onCheckedIn: applicationWindow.checkIn()
        onCheckedOut: applicationWindow.checkOut()
        onBreakStarted: applicationWindow.startBreak()
        onBreakStopped: applicationWindow.stopBreak()
        onProjectChanged: applicationWindow.setProject("")
    }

    Timer {
        id: uiUpdateTimer
        interval: Global.ms
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            coverPage.setWorkingTime(Global.getWorkingTime())
            mainPage.setWorkingTime(Global.getWorkingTime())
            coverPage.setBreakTime(Global.getBreakTime(), Global.getAutoBreakTime())
        }
    }

    Component.onCompleted: {
        // initialize cover page
// TODO set from settings
        coverPage.setMaxWorkingTime(60*60*10) // set to 10 hours
        coverPage.setActiveProject(Global.getActiveProject())
        coverPage.setWorkingTime(Global.getWorkingTime())
        coverPage.setBreakTime(Global.getBreakTime())
        mainPage.setActiveProject(Global.getActiveProject())
    }
}
