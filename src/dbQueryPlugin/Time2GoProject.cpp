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
#include "Time2GoProject.h"
#include "QueryExecutor.h"

Time2GoProject::Time2GoProject(QObject *parent) :
    QObject(parent),
    m_backgroundThread(NULL),
    m_salt(rand()),
    m_uid(0),
    m_name("")
{
    // database loading is done in background do not disrupt the QML main thread
    m_backgroundThread = BackgroundThread::getInstance();
    connect(this, SIGNAL(processDbQuery(QVariant)), m_backgroundThread->getWorker(), SLOT(slot_processDbQuery(QVariant)));
    connect(m_backgroundThread->getWorker(), SIGNAL(dbQueryResults(QVariant)), this, SLOT(slot_dbQueryResults(QVariant)));
}

// With setUid all project details will be loaded from database
void Time2GoProject::setUid(const int value)
{
    m_uid = value;
    // Load project details from database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::LoadProject;
    query["uid"] = value;
    Q_EMIT processDbQuery(QVariant(query));
}

void Time2GoProject::setName(const QString &value)
{
    m_name = value;
    // store project details to database
    QVariantMap query;
    query["salt"] = m_salt;
    query["type"] = QueryType::SaveProject;
    query["uid"] = m_uid;
    query["name"] = m_name;
    Q_EMIT processDbQuery(QVariant(query));
}

void Time2GoProject::slot_dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadProject: {
//            qDebug() << "GetProject: " << reply;
            if (reply["done"].toBool()) {
                m_uid = reply["uid"].toInt();
                m_name = reply["name"].toString();
                Q_EMIT uidChanged();
                Q_EMIT nameChanged();
            } else {
                Q_EMIT dbQueryError(reply["error"].toString());
            }
            break;
        }
        case QueryType::SaveProject: {
            if (!reply["done"].toBool()) {
                Q_EMIT dbQueryError(reply["error"].toString());
            }
            break;
        }
        }
    }
}
