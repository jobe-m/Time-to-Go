#ifndef QUERYEXECUTER_H
#define QUERYEXECUTER_H

#include <QMap>
#include <QVariantMap>
#include <QStringList>
#include <QtSql/QtSql>

#include "ThreadWorker.h"

namespace QueryType {
    enum EnumType {
        GetProject = 1,
        SetProject,
        GetWorkUnit,
        SetWorkUnit,
        GetBreak,
        SetBreak,
        GetLatestWorkUnit,
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

    void getProject(QVariantMap query);
    void setProject(QVariantMap query);
    void setWorkUnit(QVariantMap query);
    void getLatestWorkUnit(QVariantMap query);

private:
    ThreadWorker m_worker;
    QSqlDatabase m_db;
};

#endif // QUERYEXECUTER_H
