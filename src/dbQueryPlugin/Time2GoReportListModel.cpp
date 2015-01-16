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

#include "Time2GoReportListModel.h"

Time2GoReportListModel::Time2GoReportListModel(QObject *parent)
    : QAbstractListModel(parent),
      m_backgroundThread(NULL),
      m_salt(rand()),
//      m_report_requested(false),
      m_items()
{
    // database loading is done in background do not disrupt the QML main thread
    m_backgroundThread = BackgroundThread::getInstance();
    connect(this, SIGNAL(processDbQuery(QVariant)), m_backgroundThread->getWorker(), SLOT(slot_processDbQuery(QVariant)));
    connect(m_backgroundThread->getWorker(), SIGNAL(dbQueryResults(QVariant)), this, SLOT(slot_dbQueryResults(QVariant)));
}

int Time2GoReportListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_items.count();
}

QVariant Time2GoReportListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_items.count()) {
        return QVariant();
    }
    return m_items[index.row()].get(role);
}

void Time2GoReportListModel::clear()
{
//    m_report_requested = false;

    beginResetModel();
    m_items.clear();
    endResetModel();

    // signal to QML and for property update
    Q_EMIT modelDataChanged();
    Q_EMIT isEmptyChanged();
}

void Time2GoReportListModel::loadReport()
{
    // clear and change salt so that an already requested load of data will not be taken over into the list model
    m_salt = rand();
    clear();

    // load work unit details from database
//    if (!m_report_requested) {
//        m_report_requested = true;
        QVariantMap query;
        query["salt"] = m_salt;
        query["type"] = QueryType::LoadReport;
        Q_EMIT processDbQuery(QVariant(query));
//    }
}

void Time2GoReportListModel::slot_dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadReport: {
            if (reply["done"].toBool()) {
                ReportItem item(reply["uid"].toInt(),
                        reply["projectuid"].toInt(),
                        reply["day"].toString(),
                        reply["starttime"].toString(),
                        reply["endtime"].toString(),
                        reply["breaktimehours"].toString(),
                        reply["breaktimeminutes"].toString(),
                        reply["worktimehours"].toString(),
                        reply["worktimeminutes"].toString());
                addItemToListModel(item);
            }
            break;
        }
        }
    }
}

void Time2GoReportListModel::addItemToListModel(const ReportItem &item)
{
//    qDebug() << item.m_work_start << item.m_work_end;
    // append new entry to end of list
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_items << item;
    endInsertRows();

    // emit isEmptyChanged signal if list view was empty before
    if (m_items.length() == 1) {
        Q_EMIT isEmptyChanged();
    }

    // signal to QML
    Q_EMIT modelDataChanged();
}

void Time2GoReportListModel::deleteItem(int uid)
{
    // look at each item in list model
    for (int i = 0; i < m_items.count(); i++) {
        if (m_items[i].m_uid == uid) {
            // found it, delete it from list model
            beginRemoveRows(QModelIndex(), i, i);
            m_items.removeAt(i);
            endRemoveRows();
            // signal to property to update itself in QML
            Q_EMIT modelDataChanged();
            // emit isEmptyChanged signal if last item was deleted
            if (m_items.isEmpty()) {
                Q_EMIT isEmptyChanged();
            }
        }
    }
}
