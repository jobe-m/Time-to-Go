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

#ifndef DATABASEQUERYPLUGIN_H
#define DATABASEQUERYPLUGIN_H

#include <QObject>
#include <QQmlEngine>
#include "QueryExecutor.h"

class DatabaseQueryPlugin: public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(DatabaseQueryPlugin)

public:
    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine) {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        if(!m_instance) {
            m_instance = new DatabaseQueryPlugin();
        }
        return m_instance;
    }

    virtual ~DatabaseQueryPlugin();

signals:
    void workUnitSaved(QVariantMap &data);

public slots:
    // in QML call with saveWorkUnit({id: 0, project: 1, start: xxx, end: 0, notes: ""})
    void saveWorkUnit(QVariantMap &data);

private slots:
    void dbQueryResults(QVariant &data);

private:
    DatabaseQueryPlugin(QObject* parent = 0);

private:
    static QObject* m_instance;
    QueryExecutor* m_dbQueryExecutor;
};

#endif
