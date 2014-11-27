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

#ifndef TIME2GOWORKUNIT_H
#define TIME2GOWORKUNIT_H

#include <QObject>
#include "QueryExecutor.h"

class Time2GoWorkUnit : public QObject
{
    Q_OBJECT
public:
    Q_ENUMS(eErrorType)
    enum eErrorType {
        LoadError,
        SaveError,
        DeleteError
    };

    Q_PROPERTY(int uid READ uid WRITE setUid NOTIFY uidChanged)
    Q_PROPERTY(int projectUid READ projectUid WRITE setProjectUid NOTIFY projectUidChanged)
    Q_PROPERTY(QDateTime start READ start WRITE setStart NOTIFY startChanged)
    Q_PROPERTY(QDateTime end READ end WRITE setEnd NOTIFY endChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)
    Q_PROPERTY(bool validStartDateTime READ validStartDateTime)
    Q_PROPERTY(bool validEndDateTime READ validEndDateTime)

    Q_INVOKABLE void save();
    Q_INVOKABLE void reset();
    Q_INVOKABLE void loadLatestWorkUnit();
    Q_INVOKABLE void deleteWorkUnit();

    explicit Time2GoWorkUnit(QObject *parent = 0);
    virtual ~Time2GoWorkUnit();

    int uid() { return m_uid; }
    void setUid(const int value);
    int projectUid() { return m_project_uid; }
    void setProjectUid(const int value);
    QDateTime start() { return m_start; }
    void setStart(const QDateTime value);
    QDateTime end() { return m_end; }
    void setEnd(const QDateTime value);
    QString notes() { return m_notes; }
    void setNotes(const QString& value);
    bool validStartDateTime() { return m_start.isValid(); }
    bool validEndDateTime() { return m_end.isValid(); }

signals:
    void uidChanged();
    void projectUidChanged();
    void startChanged();
    void endChanged();
    void notesChanged();
    void dbQueryError(int errorType, const QString errorText);
    void unfinishedWorkUnit();
    void timeChanged();

public slots:

private slots:
    // from query executor
    void dbQueryResults(QVariant query);

private:
    void saveWorkUnit();

private:
    QueryExecutor* m_dbQueryExecutor;
    int m_salt;

    // details of work unit
    int m_uid;
    int m_project_uid;
    QDateTime m_start;
    QDateTime m_end;
    QString m_notes;
};

#endif // TIME2GOWORKUNIT_H
