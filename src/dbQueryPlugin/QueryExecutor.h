
#ifndef QUERYEXECUTER_H
#define QUERYEXECUTER_H

#include <QMap>
#include <QVariantMap>
#include <QStringList>
#include <QtSql/QtSql>

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
    explicit QueryExecutor(QObject* parent = 0);

public slots:
    void slot_processDbQuery(QVariant msg);

signals:
    void dbQueryResults(QVariant msg);

private:
    void loadProject(QVariantMap query);
    void saveProject(QVariantMap query);
    void loadWorkUnit(QVariantMap query);
    void saveWorkUnit(QVariantMap query);
    void deleteWorkUnit(QVariantMap query);
    void loadLatestWorkUnit(QVariantMap query);
    void loadTimeCounter(QVariantMap query);
    void loadReport(QVariantMap query);

private:
    QSqlDatabase m_db;
};

#endif // QUERYEXECUTER_H
