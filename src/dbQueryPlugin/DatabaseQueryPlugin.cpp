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

#include <QDebug>
#include "DatabaseQueryPlugin.h"

QObject * DatabaseQueryPlugin::m_instance = 0;

DatabaseQueryPlugin::DatabaseQueryPlugin(QObject* parent) :
    QObject(parent),
    m_dbQueryExecutor(NULL)
{
    m_dbQueryExecutor = QueryExecutor::GetInstance();
    connect(m_dbQueryExecutor, SIGNAL(actionDone(QVariant)), this, SLOT(dbQueryResults(QVariant)));
}

DatabaseQueryPlugin::~DatabaseQueryPlugin()
{
    if (m_dbQueryExecutor) delete m_dbQueryExecutor;
}

void DatabaseQueryPlugin::saveProject(QVariantMap data)
{
}

void DatabaseQueryPlugin::saveWorkUnit(QVariantMap data)
{
    data["type"] = QueryType::SetWorkUnit;
    qDebug() << "saveWorkUnit: " << data;
    m_dbQueryExecutor->queueAction(data);
}

void DatabaseQueryPlugin::loadLatestWorkUnit()
{
    QVariantMap data;
    data["type"] = QueryType::GetLatestWorkUnit;
    m_dbQueryExecutor->queueAction(data);
}

void DatabaseQueryPlugin::dbQueryResults(QVariant data)
{
    QVariantMap reply = data.toMap();
    int type = reply["type"].toInt();

    switch (type) {
    case QueryType::SetWorkUnit: {
        Q_EMIT workUnitSaved(reply);
        break;
    }
    case QueryType::GetLatestWorkUnit: {
        Q_EMIT latestWorkUnitLoaded(reply);
        break;
    }
    }
}
