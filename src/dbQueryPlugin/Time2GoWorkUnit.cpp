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
#include "Time2GoWorkUnit.h"
#include "QueryExecutor.h"

Time2GoWorkUnit::Time2GoWorkUnit(QObject *parent) :
    QObject(parent),
    m_dbQueryExecutor(NULL),
    m_salt(rand()),
    m_uid(0),
    m_project_uid(0),
    m_start(),
    m_end(),
    m_notes("")
{
    m_dbQueryExecutor = QueryExecutor::GetInstance();
    connect(m_dbQueryExecutor, SIGNAL(actionDone(QVariant)), this, SLOT(dbQueryResults(QVariant)));
}

Time2GoWorkUnit::~Time2GoWorkUnit()
{
    if (m_dbQueryExecutor) {
        delete m_dbQueryExecutor;
    }
}

// With setUid all workunit details will be loaded from database
void Time2GoWorkUnit::setUid(const int value)
{
    m_uid = value;
    // Load project details from database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::LoadWorkUnit;
    query["uid"] = value;
    m_dbQueryExecutor->queueAction(query);
}

void Time2GoWorkUnit::setProjectUid(const int value)
{
    m_project_uid = value;
}

void Time2GoWorkUnit::setStart(const QDateTime value)
{
    m_start = value;
}

void Time2GoWorkUnit::setEnd(const QDateTime value)
{
    m_end = value;
}

void Time2GoWorkUnit::setNotes(const QString& value)
{
    m_notes = value;
}

void Time2GoWorkUnit::save()
{
    saveWorkUnit();
}

// With setWorkUnit all workunit details will be saved to database
void Time2GoWorkUnit::saveWorkUnit()
{
    // store workunit details to database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::SaveWorkUnit;
    query["uid"] = m_uid;
    query["projectuid"] = m_project_uid;
    query["start"] = m_start;
    query["end"] = m_end;
    query["notes"] = m_notes;
    m_dbQueryExecutor->queueAction(query);
}

void Time2GoWorkUnit::dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadWorkUnit: {
            qDebug() << "GetProject: " << reply;
            if (reply["done"].toBool()) {
                m_uid = reply["uid"].toInt();
                m_project_uid = reply["projectuid"].toInt();
                m_start = reply["start"].toDateTime();
                m_end = reply["end"].toDateTime();
                m_notes = reply["notes"].toString();
                Q_EMIT uidChanged();
                Q_EMIT projectUidChanged();
                Q_EMIT startChanged();
                Q_EMIT endChanged();
                Q_EMIT notesChanged();
            } else {
                Q_EMIT dbQueryError(reply["error"].toString());
            }
            break;
        }
        case QueryType::SaveWorkUnit: {
            if (reply["done"].toBool()) {
                // Save uid of object stored in database, so that next time saving we can rever to it
                m_uid = reply["uid"].toInt();
                Q_EMIT saved(0, "");
            } else {
//                Q_EMIT dbQueryError(reply["error"].toString());
                Q_EMIT saved(1, reply["error"].toString());
            }
            break;
        }
        }
    }
}
