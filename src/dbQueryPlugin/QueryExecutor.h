#ifndef QUERYEXECUTER_H
#define QUERYEXECUTER_H

#include <QMap>
#include <QVariantMap>
#include <QStringList>
#include <QtSql/QtSql>

#include "ThreadWorker.h"

namespace QueryType {
    enum EnumType {
        LoadProject = 1,
        LoadWorkUnit,
        LoadBreak,
        SaveProject,
        SaveWorkUnit,
        SaveBreak,
        LoadLatestWorkUnit,
        LoadTimeCounter,
        LoadReport
    };
    enum EnumCounterType {
        Day,
        Week,
        Month,
        Individual
    };
    enum EnumReportType {
        All,
        CurrentYear,
        CurrentMonth,
        CurrentWeek
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

    void loadProject(QVariantMap query);
    void saveProject(QVariantMap query);
    void loadWorkUnit(QVariantMap query);
    void saveWorkUnit(QVariantMap query);
    void loadLatestWorkUnit(QVariantMap query);
    void loadTimeCounter(QVariantMap query);
    void loadReport(QVariantMap query);

private:
    ThreadWorker m_worker;
    QSqlDatabase m_db;
};

#endif // QUERYEXECUTER_H
