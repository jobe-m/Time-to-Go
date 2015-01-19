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

Time2GoWorkUnit::Time2GoWorkUnit(QObject *parent) :
    QObject(parent),
    m_backgroundThread(NULL),
    m_salt(rand()),
    m_uid(0),
    m_project_uid(0),
    m_start(),
    m_end(),
    m_break_time(0),
    m_notes("")
{
    // database loading is done in background do not disrupt the QML main thread
    m_backgroundThread = BackgroundThread::getInstance();
    connect(this, SIGNAL(processDbQuery(QVariant)), m_backgroundThread->getWorker(), SLOT(slot_processDbQuery(QVariant)));
    connect(m_backgroundThread->getWorker(), SIGNAL(dbQueryResults(QVariant)), this, SLOT(slot_dbQueryResults(QVariant)));
}

// With setUid all work unit details will be loaded from database
void Time2GoWorkUnit::setUid(const int value)
{
    m_uid = value;
    // Load work unit details from database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::LoadWorkUnit;
    query["uid"] = value;
    emit processDbQuery(QVariant(query));
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

void Time2GoWorkUnit::setBreakTime(const int value)
{
    m_break_time = value;
}

void Time2GoWorkUnit::save()
{
    saveWorkUnit();
}

void Time2GoWorkUnit::deleteWorkUnit()
{
    // send deletion request to database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::DeleteWorkUnit;
    query["uid"] = m_uid;
    emit processDbQuery(QVariant(query));
}

// With setWorkUnit all work unit details will be saved to database
void Time2GoWorkUnit::saveWorkUnit()
{
    // store work unit details to database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::SaveWorkUnit;
    query["uid"] = m_uid;
    query["projectuid"] = m_project_uid;
    query["start"] = m_start;
    query["end"] = m_end;
    query["breaktime"] = m_break_time;
    query["notes"] = m_notes;
    emit processDbQuery(QVariant(query));
}

void Time2GoWorkUnit::slot_dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
//        qDebug() << "result: " << reply;
        switch (reply["type"].toInt()) {
        case QueryType::LoadLatestWorkUnit:
            if (reply["done"].toBool() && !reply["end"].toDateTime().isValid()) {
                emit unfinishedWorkUnit();
            } else {
                emit finishedWorkUnit();
            }
        case QueryType::LoadWorkUnit: {
            if (reply["done"].toBool()) {
                m_uid = reply["uid"].toInt();
                m_project_uid = reply["projectuid"].toInt();
                m_start = reply["start"].toDateTime();
                m_end = reply["end"].toDateTime();
                m_break_time = reply["breaktime"].toInt();
                m_notes = reply["notes"].toString();
                emit timeChanged();
            } else {
                emit dbQueryError(LoadError, reply["error"].toString());
            }
            break;
        }
        case QueryType::SaveWorkUnit: {
            if (reply["done"].toBool()) {
                // Save uid of object stored in database, so that next time saving we can rever to it
                m_uid = reply["uid"].toInt();
                emit timeChanged();
            } else {
                emit dbQueryError(SaveError, reply["error"].toString());
            }
            break;
        }
        case QueryType::DeleteWorkUnit: {
            if (reply["done"].toBool()) {
                // reset this object
                reset();
            } else {
                emit dbQueryError(DeleteError, reply["error"].toString());
            }
        }
        }
    }
}

void Time2GoWorkUnit::reset()
{
    m_uid = 0;
    m_project_uid = 0;
    m_start = QDateTime();
    m_end = QDateTime();
    m_break_time = 0;
    m_notes = "";
}

void Time2GoWorkUnit::loadLatestWorkUnit()
{
    // Load latest work unit details from database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::LoadLatestWorkUnit;
    emit processDbQuery(QVariant(query));
}
