/***************************************************************************
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

#include <QtQuick>
#include <sailfishapp.h>
#include "Time2GoProject.h"
#include "Time2GoWorkUnit.h"

int main(int argc, char *argv[])
{
    const QString orgName("tisno.de");
    const QString appName("harbour-time2go");
//    const QString settingsFilePath(QStandardPaths::standardLocations(QStandardPaths::ConfigLocation)[0] +
//                                   "/" + appName + "/settings.ini");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    app->setOrganizationName(orgName);
    app->setApplicationName(appName);

    // @uri harbour.Time2Go.DatabaseQuery
    const char* uri("harbour.Time2Go.DatabaseQuery");
    // make the following classes available in QML
//    qmlRegisterSingletonType<Time2GoDbSettings>(uri, 1, 0, "Time2GoDbSettings", Time2GoDbSettings::qmlInstance);
    qmlRegisterType<Time2GoProject>(uri, 1, 0, "Time2GoProject");
    qmlRegisterType<Time2GoWorkUnit>(uri, 1, 0, "Time2GoWorkUnit");
//    qmlRegisterType<Time2GoWorkUnitsListModel>(uri, 1, 0, "Time2GoWorkUnitsListModel");
//    qmlRegisterType<Time2GoBreaksListModel>(uri, 1, 0, "Time2GoBreaksListModel");
//    qmlRegisterType<Time2GoWorkingTimeDay>(uri, 1, 0, "Time2GoWorkingTimeDay");
//    qmlRegisterType<Time2GoWorkingTimeWeek>(uri, 1, 0, "Time2GoWorkingTimeWeek");
//    qmlRegisterType<Time2GoWorkingTimeMonth>(uri, 1, 0, "Time2GoWorkingTimeMonth");

    // Setup some class as context properties and make them accessible in QML
//    QScopedPointer<Time2GoHelper> helper(new Time2GoHelper());
//    view->rootContext()->setContextProperty("time2GoHelper", helper.data());
//    QScopedPointer<settingsPublic::Time2GoSettings> time2GoSettings(new settingsPublic::Time2GoSettings(settingsFilePath, helper.data()));
//    view->rootContext()->setContextProperty("ownKeepassSettings", okpSettings.data());

    // Set main QML file and go ahead
    view->setSource(SailfishApp::pathTo("qml/Main.qml"));
    view->show();

    // Check settings version after QML is loaded because it might want to show an info popup in QML
//    time2GoSettings->checkSettingsVersion();

    return app->exec();
}
