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

# for optimizing string construction
DEFINES *= QT_USE_QSTRINGBUILDER
QT += sql

INCLUDEPATH += $$PWD
DEPENDPATH  += $$PWD

SOURCES += \
    src/dbQueryPlugin/QueryExecutor.cpp \
    src/dbQueryPlugin/ThreadWorker.cpp \
    src/dbQueryPlugin/Time2GoProject.cpp \
    src/dbQueryPlugin/Time2GoWorkUnit.cpp \
    src/dbQueryPlugin/Time2GoTimeCounter.cpp \
    src/dbQueryPlugin/Time2GoReportListModel.cpp

HEADERS += \
    src/dbQueryPlugin/QueryExecutor.h \
    src/dbQueryPlugin/ThreadWorker.h \
    src/dbQueryPlugin/Time2GoProject.h \
    src/dbQueryPlugin/Time2GoWorkUnit.h \
    src/dbQueryPlugin/Time2GoTimeCounter.h \
    src/dbQueryPlugin/Time2GoReportListModel.h
