#ifndef QUERYEXECUTER_H
#define QUERYEXECUTER_H

#include <QMap>
#include <QVariantMap>
#include <QStringList>
#include <QtSql/QtSql>

#include "ThreadWorker.h"

namespace QueryType {
    enum EnumType {
        SetProject = 1,
        SetWorkUnit,
        SetBreak,
    };
}

class QueryExecutor : public QObject
{
    Q_OBJECT
public:
    explicit QueryExecutor(QObject *parent);
    static QueryExecutor *GetInstance();

public slots:
    void queueAction(QVariant msg, int priority = 0);
    void processAction(QVariant msg);

signals:
    void actionDone(QVariant msg);

private:
    void processQuery(const QVariant &msg);

    void setWorkUnit(QVariantMap &query);

private:
    ThreadWorker m_worker;
    QSqlDatabase db;
};

#endif // QUERYEXECUTER_H
