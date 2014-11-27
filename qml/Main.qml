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
import harbour.Time2Go.DatabaseQuery 1.0
import "pages"
import "cover"
import "common"
import "scripts/Global.js" as Global

ApplicationWindow
{
    id: applicationWindow

    // For accessing main page to pass further application activity status
    property MainPage mainPage: null
    property Time2GoReportListModel reportModel: null

    // application global properties and functions
    function checkIn() {
        var date = new Date()
        coverPage.checkIn(date)
        mainPage.checkIn(date)
    }

    function checkOut() {
        var date = new Date()
        coverPage.checkOut(date)
        mainPage.checkOut(date)
    }

    function startBreak() {
        var date = new Date()
        coverPage.startBreak(date)
        mainPage.startBreak(date)
    }

    function stopBreak() {
        var date = new Date()
        coverPage.stopBreak(date)
        mainPage.stopBreak(date)
    }

    function setProject(value) {
        // if no project name was given then just take next available project
        if (value === "") {
            Global.activateNextProject()
        } else {
            Global.activateProject(value);
        }
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
            activeProjectUid: 1
            Component.onCompleted: mainPage = mainPageObj
        }
    }

    CoverPage {
        id: coverPage
        activeProjectUid: 1
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
            coverPage.setBreakTime(Global.getBreakTime(), Global.getAutoBreakTime())
        }
    }

    Time2GoReportListModel {
        id: reportModelObj
        Component.onCompleted: reportModel = reportModelObj
    }

    Component.onCompleted: {
        // initialize cover page
// TODO set from settings
        coverPage.setMaxWorkingTime(60*60*10+60*45) // set to 10:45 hours in seconds
        mainPage.setMaxWorkingTime(60*60*10+60*45)
    }
}
