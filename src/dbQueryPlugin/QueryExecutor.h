#ifndef QUERYEXECUTER_H
#define QUERYEXECUTER_H

#include <QMap>
#include <QVariantMap>
#include <QStringList>
#include <QtSql/QtSql>

#include "ThreadWorker.h"

namespace QueryType {
enum eType {
    enumMin = 0,
    LoadProject,
    LoadWorkUnit,
    DeleteWorkUnit,
    LoadBreak,
    SaveProject,
    SaveWorkUnit,
    SaveBreak,
    LoadLatestWorkUnit,
    LoadTimeCounter,
    LoadReport,
    enumMax
};
}

namespace CounterType {
enum eCounterType {
    enumMin = 0,
    Day,
    Week,
    Month,
    All,
    Individual,
    enumMax
};
}

namespace ReportType {
enum eReportType {
    enumMin,
    All,
    CurrentYear,
    CurrentMonth,
    CurrentWeek,
    enumMax
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
    void deleteWorkUnit(QVariantMap query);
    void loadLatestWorkUnit(QVariantMap query);
    void loadTimeCounter(QVariantMap query);
    void loadReport(QVariantMap query);

private:
    ThreadWorker m_worker;
    QSqlDatabase m_db;
};

#endif // QUERYEXECUTER_H
