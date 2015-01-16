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

#ifndef TIME2GOPROJECT_H
#define TIME2GOPROJECT_H

#include <QObject>
#include "BackgroundThread.h"

class Time2GoProject : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(int uid READ uid WRITE setUid NOTIFY uidChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    explicit Time2GoProject(QObject *parent = 0);

    int uid() { return m_uid; }
    void setUid(const int value);
    const QString name() { return m_name; }
    void setName(const QString &value);

signals:
    // to QML
    void uidChanged();
    void nameChanged();
    void dbQueryError(const QString errorText);
    // to background thread
    void processDbQuery(QVariant query);

public slots:

private slots:
    // from background thread
    void slot_dbQueryResults(QVariant query);

private:
    BackgroundThread* m_backgroundThread;
    int m_salt;

    int m_uid;
    QString m_name;
};

#endif // TIME2GOPROJECT_H
