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
      m_dbQueryExecutor(NULL),
      m_salt(rand()),
      m_report_loaded(false),
      m_items()
{
      m_dbQueryExecutor = QueryExecutor::GetInstance();
      connect(m_dbQueryExecutor, SIGNAL(actionDone(QVariant)), this, SLOT(slot_dbQueryResults(QVariant)));
}

Time2GoReportListModel::~Time2GoReportListModel()
{
    if (m_dbQueryExecutor) {
        delete m_dbQueryExecutor;
    }
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
    beginResetModel();
    m_items.clear();
    endResetModel();

    // signal to QML and for property update
    emit modelDataChanged();
    emit isEmptyChanged();
}

void Time2GoReportListModel::loadReport()
{
    // load work unit details from database
    if (!m_report_loaded) {
        QVariantMap query;
        query["salt"] = m_salt;
        query["type"] = QueryType::LoadReport;
        m_dbQueryExecutor->queueAction(query);
    }
}

void Time2GoReportListModel::slot_dbQueryResults(QVariant query)
{
    QVariantMap reply = query.toMap();
    // Check if reply details are for us
    if (m_salt == reply["salt"].toInt()) {
        switch (reply["type"].toInt()) {
        case QueryType::LoadReport: {
            if (reply["done"].toBool()) {
                m_report_loaded = true;
                ReportItem item(reply["uid"].toInt(),
                        reply["projectuid"].toInt(),
                        reply["starttime"].toTime(),
                reply["endtime"].toTime(),
                reply["breaktime"].toInt(),
                reply["worktime"].toInt());
                addItemToListModel(item);
            }
            break;
        }
        }
    }
}

void Time2GoReportListModel::addItemToListModel(const ReportItem &item)
{
    qDebug() << item.m_work_start << item.m_work_end;
    // append new entry to end of list
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_items << item;
    endInsertRows();

    // emit isEmptyChanged signal if list view was empty before
    if (m_items.length() == 1) {
        emit isEmptyChanged();
    }

    // signal to QML
    emit modelDataChanged();
}
