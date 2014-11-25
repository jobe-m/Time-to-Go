############################################################################
#
# Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
# All rights reserved.
#
# This file is part of Time2Go.
#
# Time2Go is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Time2Go is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Time2Go. If not, see <http://www.gnu.org/licenses/>.
#
############################################################################

# Sources of the Time2Go QML plugins
include(src/dbQueryPlugin/dbQueryPlugin.pri)

# Get release version from .spec file and paste it further to c++ through a define
#isEmpty(VERSION) {
#    GIT_TAG = $$system(git describe --tags --abbrev=0)
#    GIT_VERSION = $$find(GIT_TAG, ^\\d+(\\.\\d+)?(\\.\\d+)?$)
#    isEmpty(GIT_VERSION) {
#        # Taking git tag as fallback but this shouldn't really happen
#        warning("Can't find a valid git tag version, got: $$GIT_TAG")
#        GIT_VERSION = 0.0.0
#    }
#    !isEmpty(GIT_VERSION): VERSION = $$GIT_VERSION
#}
#DEFINES += PROGRAMVERSION=\\\"$$VERSION\\\"

# The name of the app
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-time2go

CONFIG += sailfishapp

SOURCES += \
    src/main.cpp

OTHER_FILES += \
    qml/cover/CoverPage.qml \
    qml/common/InfoPopup.qml \
    rpm/harbour-time2go.changes.in \
    rpm/harbour-time2go.spec \
    rpm/harbour-time2go.yaml \
    translations/*.ts \
    harbour-time2go.desktop \
    qml/pages/MainPage.qml \
    qml/scripts/Global.js \
    qml/pages/ReportPage.qml \
    qml/common/DateTimeLine.qml \
    qml/Main.qml \
    qml/common/ReportListItem.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-time2go-de_DE.ts

