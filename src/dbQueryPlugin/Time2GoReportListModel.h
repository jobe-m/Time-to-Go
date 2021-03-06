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

#ifndef TIME2GOREPORTLISTMODEL_H
#define TIME2GOREPORTLISTMODEL_H

#include <QAbstractListModel>
#include <QStringList>
#include <QDate>

#include "QueryExecutor.h"

static const int baseRole = Qt::UserRole + 1;

class ReportItem
{
public:
    ReportItem(int uid, int projectUid, QString day, QString workStart, QString workEnd,
               QString breakTimeHours, QString breakTimeMinutes, QString workTimeHours, QString workTimeMinutes)
        : m_uid(uid),
          m_project_uid(projectUid),
          m_day(day),
          m_work_start(workStart),
          m_work_end(workEnd),
          m_break_time_hours(breakTimeHours),
          m_break_time_minutes(breakTimeMinutes),
          m_work_time_hours(workTimeHours),
          m_work_time_minutes(workTimeMinutes)
    {}
    virtual ~ReportItem() {}

    QVariant get(const int role) const;
    static QHash<int, QByteArray> createRoles();

    int m_uid;
    int m_project_uid;
    QString m_day;
    QString m_work_start;
    QString m_work_end;
    QString m_break_time_hours;
    QString m_break_time_minutes;
    QString m_work_time_hours;
    QString m_work_time_minutes;
};

class Time2GoReportListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    Q_ENUMS(eWeekDayType)
    enum eWeekDayType {
        Sunday = 0,
        Monday,
        Tuesday,
        Wednesday,
        Thursday,
        Friday,
        Saturday
    };

    Q_PROPERTY(bool isEmpty READ isEmpty NOTIFY isEmptyChanged)

public:
    Q_INVOKABLE void loadReport();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void deleteItem(int uid);

public:
    Time2GoReportListModel(QObject *parent = 0);
    virtual ~Time2GoReportListModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    bool isEmpty() { return m_items.isEmpty(); }
    void clearListModel() { clear(); }
    void addItemToListModel(const ReportItem& item);

    // Overwrite function to set role names
    virtual QHash<int, QByteArray> roleNames() const { return ReportItem::createRoles(); }
signals:
    // signals to QML
    void modelDataChanged();

    // signal for property
    void isEmptyChanged();

private slots:
    // from query executor
    void slot_dbQueryResults(QVariant query);

private:
    QueryExecutor *m_dbQueryExecutor;
    int m_salt;
    bool m_report_requested;

    QList<ReportItem> m_items;
};

// inline implementations
inline QVariant ReportItem::get(const int role) const
{
    switch (role) {
    case baseRole:
        return m_uid;
    case baseRole + 1:
        return m_project_uid;
    case baseRole + 2:
        return m_day;
    case baseRole + 3:
        return m_work_start;
    case baseRole + 4:
        return m_work_end;
    case baseRole + 5:
        return m_break_time_hours;
    case baseRole + 6:
        return m_break_time_minutes;
    case baseRole + 7:
        return m_work_time_hours;
    case baseRole + 8:
        return m_work_time_minutes;
    }
    return QVariant();
}

inline QHash<int, QByteArray> ReportItem::createRoles()
{
    QHash<int, QByteArray> roles;
    roles[baseRole]     = "uid";
    roles[baseRole + 1] = "projectuid";
    roles[baseRole + 2] = "day";
    roles[baseRole + 3] = "workstart";
    roles[baseRole + 4] = "workend";
    roles[baseRole + 5] = "breaktimehours";
    roles[baseRole + 6] = "breaktimeminutes";
    roles[baseRole + 7] = "worktimehours";
    roles[baseRole + 8] = "worktimeminutes";
    return roles;
}

#endif // TIME2GOREPORTLISTMODEL_H
