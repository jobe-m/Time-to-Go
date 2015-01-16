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

Time2GoTimeCounter::Time2GoTimeCounter(QObject *parent) :
    QObject(parent),
    m_backgroundThread(NULL),
    m_updateTimer(NULL),
    m_timer(),
    m_salt(rand()),
    m_project_uid(0),
    m_work_time(),
    m_break_time(),
    m_type(Day),
    m_time_running(false),
    m_update_interval(1000)
{
    // database loading is done in background do not disrupt the QML main thread
    m_backgroundThread = BackgroundThread::getInstance();
    connect(this, SIGNAL(processDbQuery(QVariant)), m_backgroundThread->getWorker(), SLOT(slot_processDbQuery(QVariant)));
    connect(m_backgroundThread->getWorker(), SIGNAL(dbQueryResults(QVariant)), this, SLOT(slot_dbQueryResults(QVariant)));

    m_updateTimer = new QTimer(this);
    connect(m_updateTimer, SIGNAL(timeout()), this, SLOT(slot_update()));
}

Time2GoTimeCounter::~Time2GoTimeCounter()
{
    if (m_updateTimer) {
        delete m_updateTimer;
    }
}

// With setUid all work unit details will be loaded from database
void Time2GoTimeCounter::setProjectUid(const int value)
{
    m_project_uid = value;
}

void Time2GoTimeCounter::slot_dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadTimeCounter: {
//            qDebug() << "LoadTimeCounter: " << reply;
            if (m_project_uid != reply["projectuid"].toInt()) {
                m_project_uid = reply["projectuid"].toInt();
                Q_EMIT projectUidChanged();
            }
            if (m_work_time != reply["worktime"].toInt()) {
                m_work_time = reply["worktime"].toInt();
                Q_EMIT workTimeChanged();
            }
            if (m_break_time != reply["breaktime"].toInt()) {
                m_break_time = reply["breaktime"].toInt();
                Q_EMIT breakTimeChanged();
            }
            m_time_running = reply["running"].toBool();
            if (m_time_running) {
                m_updateTimer->start(m_update_interval);
                m_timer.start();
            } else {
                m_updateTimer->stop();
            }
            break;
        }
        }
    }
}

void Time2GoTimeCounter::slot_update()
{
    m_work_time += m_timer.restart();
    Q_EMIT workTimeChanged();
}

void Time2GoTimeCounter::setUpdateInterval(const int value)
{
    m_update_interval = value;
    m_updateTimer->setInterval(value);
}

void Time2GoTimeCounter::setType(const int value)
{
    if ((value > enumMIN) && (value < enumMAX)) {
        m_type = value;
    }
}

void Time2GoTimeCounter::reload()
{
    // Load work unit details from database
    QVariantMap query;
    query["salt"] = m_salt;
    switch (m_type) {
    case Day:
        query["counter"] = CounterType::Day;
        break;
    case Week:
        query["counter"] = CounterType::Week;
        break;
    case Month:
        query["counter"] = CounterType::Month;
        break;
    case All:
        query["counter"] = CounterType::All;
        break;
    default:
        query["counter"] = CounterType::Individual;
        break;
    }
    query["type"] = QueryType::LoadTimeCounter;
    query["projectuid"] = m_project_uid;
    Q_EMIT processDbQuery(QVariant(query));
}
