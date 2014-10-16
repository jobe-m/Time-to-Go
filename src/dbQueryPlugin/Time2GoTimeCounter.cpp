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
#include "Time2GoTimeCounter.h"
#include "QueryExecutor.h"

Time2GoTimeCounter::Time2GoTimeCounter(QObject *parent) :
    QObject(parent),
    m_dbQueryExecutor(NULL),
    m_salt(rand()),
    m_project_uid(0),
    m_work_time(),
    m_break_time()
{
    m_dbQueryExecutor = QueryExecutor::GetInstance();
    connect(m_dbQueryExecutor, SIGNAL(actionDone(QVariant)), this, SLOT(dbQueryResults(QVariant)));
}

Time2GoTimeCounter::~Time2GoTimeCounter()
{
    if (m_dbQueryExecutor) {
        delete m_dbQueryExecutor;
    }
}

// With setUid all work unit details will be loaded from database
void Time2GoTimeCounter::setProjectUid(const int value)
{
    m_project_uid = value;
    // Load work unit details from database
    QVariantMap query;
    query["salt"] = m_salt;
    query["counter"] = QueryType::Day;
    query["type"] = QueryType::LoadTimeCounter;
    query["projectuid"] = value;
    m_dbQueryExecutor->queueAction(query);
}

void Time2GoTimeCounter::dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadTimeCounter: {
            qDebug() << "GetProject: " << reply;
            if (reply["done"].toBool()) {
                if (m_project_uid != reply["projectuid"].toInt()) {
                    m_project_uid = reply["projectuid"].toInt();
                    Q_EMIT projectUidChanged();
                }
                if (m_work_time != reply["worktime"].toTime()) {
                    m_work_time = reply["worktime"].toTime();
                    Q_EMIT workTimeChanged();
                }
                if (m_break_time != reply["breaktime"].toTime()) {
                    m_break_time = reply["breaktime"].toTime();
                    Q_EMIT breakTimeChanged();
                }
            } else {
                Q_EMIT dbQueryError(reply["error"].toString());
            }
            break;
        }
        }
    }
}
