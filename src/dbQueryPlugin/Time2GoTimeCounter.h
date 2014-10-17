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

#ifndef TIME2GOTIMECOUNTER_H
#define TIME2GOTIMECOUNTER_H

#include <QObject>
#include "QueryExecutor.h"

class Time2GoTimeCounter : public QObject
{
    Q_OBJECT
public:
    Q_ENUMS()
    Q_PROPERTY(int projectUid READ projectUid WRITE setProjectUid NOTIFY projectUidChanged)
    Q_PROPERTY(int workTime READ workTime NOTIFY workTimeChanged)
    Q_PROPERTY(int breakTime READ breakTime NOTIFY breakTimeChanged)
    Q_PROPERTY(int updateInterval READ updateInterval WRITE setUpdateInterval)

    Q_INVOKABLE void reload();

    explicit Time2GoTimeCounter(QObject *parent = 0);
    virtual ~Time2GoTimeCounter();

    int projectUid() { return m_project_uid; }
    void setProjectUid(const int value);
    int workTime() { return m_work_time / 1000; }
    int breakTime() { return m_break_time / 1000; }
    int updateInterval() { return m_update_interval; }
    void setUpdateInterval(const int value);

signals:
    void uidChanged();
    void projectUidChanged();
    void workTimeChanged();
    void breakTimeChanged();
    void dbQueryError(const QString errorText);

public slots:

private slots:
    // from query executor
    void dbQueryResults(QVariant query);
    // from QTimer
    void update();

private:
    QueryExecutor* m_dbQueryExecutor;
    QTimer* m_updateTimer;
    QTime m_timer;
    int m_salt;

    // details of time counter
    int m_project_uid;
    int m_work_time; // stored in milliseconds
    int m_break_time; // stored in milliseconds
    bool m_time_running;
    int m_update_interval; // stored in milliseconds
};

#endif // TIME2GOTIMECOUNTER_H
