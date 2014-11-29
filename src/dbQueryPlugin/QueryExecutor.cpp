#include <QThreadPool>
#include <QDebug>
#include <QStandardPaths>

#include "QueryExecutor.h"
#include "Time2GoReportListModel.h"

QueryExecutor::QueryExecutor(QObject *parent) :
    QObject(parent)
{
    m_worker.setCallObject(this);

    m_db = QSqlDatabase::database();
    if (!m_db.isOpen()) {
        m_db = QSqlDatabase::addDatabase("QSQLITE");

        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QString dataFile = QString("%1/database.db").arg(dataDir);

        QDir dir(dataDir);
        if (!dir.exists())
            dir.mkpath(dataDir);
        qDebug() << "DB Dir:" << dataDir;
        m_db.setDatabaseName(dataFile);
        qDebug() << "DB Name:" << m_db.databaseName();
        if (m_db.open())
            qDebug() << "QE opened database";
        else
            qWarning() << "QE failed to open database";
    }
    else {
        qWarning() << "QE used existing DB connection!";
    }

    if (m_db.isOpen()) {
/*
        // DEBUG: delete outdated database tables
        m_db.exec("DROP TABLE IF EXISTS settings;");
        m_db.exec("DROP TABLE IF EXISTS projects;");
        m_db.exec("DROP TABLE IF EXISTS workunits;");
        m_db.exec("DROP TABLE IF EXISTS breaks;");
*/
        if (!m_db.tables().contains("settings")) {
            m_db.exec("CREATE TABLE settings (uid INTEGER PRIMARY KEY, project INTEGER, type INTEGER,"
                    "setting INTEGER);");
        }
        if (!m_db.tables().contains("projects")) {
            m_db.exec("CREATE TABLE projects (uid INTEGER PRIMARY KEY, name TEXT, "
                      "reserved INTEGER);");
            // create one default group
            m_db.exec("INSERT INTO projects VALUES (NULL, \"my awesome project\", 0);");
        }
        if (!m_db.tables().contains("workunits")) {
            m_db.exec("CREATE TABLE workunits (uid INTEGER PRIMARY KEY, projectuid INTEGER, "
                    "start DATE, end DATE, notes TEXT, reserved INTEGER);");
        }
        if (!m_db.tables().contains("breaks")) {
            m_db.exec("CREATE TABLE breaks (uid INTEGER PRIMARY KEY, workunit INTEGER, "
                    "start DATE, end DATE, notes TEXT, reserved INTEGER);");
        }
    }
}

void QueryExecutor::queueAction(QVariant msg, int priority) {
    m_worker.queueAction(msg, priority);
}

void QueryExecutor::processAction(QVariant message) {
    processQuery(message);
}

void QueryExecutor::processQuery(const QVariant &msg)
{
    QVariantMap query = msg.toMap();
    if (!query.isEmpty()) {
        switch (query["type"].toInt()) {
        case QueryType::LoadProject: { loadProject(query); break; }
        case QueryType::SaveProject: { saveProject(query); break; }
        case QueryType::LoadWorkUnit: { loadWorkUnit(query); break; }
        case QueryType::SaveWorkUnit: { saveWorkUnit(query); break; }
        case QueryType::DeleteWorkUnit: { deleteWorkUnit(query); break; }
        case QueryType::LoadLatestWorkUnit: { loadLatestWorkUnit(query); break; }
        case QueryType::LoadTimeCounter: { loadTimeCounter(query); break; }
        case QueryType::LoadReport: { loadReport(query); break; }
        default:
            // Request out of range, do nothing
            return;
        }
    }
}

void QueryExecutor::loadProject(QVariantMap query)
{
    QSqlQuery sql(m_db);
    query["done"] = false;
    if (0 != query["uid"].toInt()) {
        sql.prepare("SELECT * FROM projects WHERE uid=(:uid);");
        sql.bindValue(":uid", query["uid"].toInt());
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            if (sql.next()) {
                // Update query with project details
                query["uid"] = sql.value(0).toInt();
                query["name"] = sql.value(1).toString();
                query["done"] = true;
            } else {
                query["error"] = QString("Project with UID %1 not found in database. Strange.").arg(query["uid"].toInt());
            }
        } else {
            query["error"] = sql.lastError().text();
        }
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

void QueryExecutor::saveProject(QVariantMap query)
{
    QSqlQuery sql(m_db);
    // Set response to not done
    query["done"] = false;
    // id is used to determine if we need to create a new table entry or if we should modify an existing table entry
    int uid = query["uid"].toInt();
    if (0 == uid) {
        // Create new project
        sql.prepare("INSERT INTO projects VALUES (NULL, :name, 0);");
        sql.bindValue(":name", query["name"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            // Update uid in query
            query["uid"] = sql.lastInsertId();
            // or if lastInsertId is not working do: "SELECT max(uid) FROM workunits;"
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    } else {
        // Update existing project
        sql.prepare("UPDATE projects SET name=(:name), reserved=0 WHERE uid=(:uid);");
        sql.bindValue(":name", query["name"]);
        sql.bindValue("uid", query["uid"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError) {
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

void QueryExecutor::loadWorkUnit(QVariantMap query)
{

}

void QueryExecutor::deleteWorkUnit(QVariantMap query)
{
    QSqlQuery sql(m_db);
    query["done"] = false;
    int uid = query["uid"].toInt();
    if (0 != uid) {
        // Delete work unit
        sql.prepare("DELETE FROM workunits WHERE uid=:uid;");
        sql.bindValue(":uid", uid);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

void QueryExecutor::saveWorkUnit(QVariantMap query)
{
    QSqlQuery sql(m_db);
    query["done"] = false;
    int uid = query["uid"].toInt();
    if (0 == uid) {
        // Create new work unit
        sql.prepare("INSERT INTO workunits VALUES (NULL, :projectuid, :start, :end, :notes, 0);");
        sql.bindValue(":projectuid", query["projectuid"]);
        sql.bindValue(":start", query["start"]);
        sql.bindValue(":end", query["end"]);
        sql.bindValue(":notes", query["notes"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            // Update uid in query
            query["uid"] = sql.lastInsertId();
            // or if lastInsertId is not working do: "SELECT max(id) FROM workunits;"
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    } else {
        // Update existing work unit
        sql.prepare("UPDATE workunits SET projectuid=(:projectuid), start=(:start), end=(:end), notes=(:notes), reserved=0  WHERE uid=(:uid);");
        sql.bindValue(":projectuid", query["projectuid"]);
        sql.bindValue(":start", query["start"]);
        sql.bindValue(":end", query["end"]);
        sql.bindValue(":notes", query["notes"]);
        sql.bindValue(":uid", query["uid"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError) {
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

void QueryExecutor::loadLatestWorkUnit(QVariantMap query)
{
    QSqlQuery sql("SELECT * FROM workunits ORDER BY datetime(start) DESC LIMIT 1;", m_db);
    if (sql.next()) {
        query["uid"] = sql.value(0);
//        qDebug() << sql.value(0);
        query["projectuid"] = sql.value(1);
//        qDebug() << sql.value(1);
        query["start"] = sql.value(2);
//        qDebug() << sql.value(2);
        query["end"] = sql.value(3);
//        qDebug() << sql.value(3);
        query["notes"] = sql.value(4);
//        qDebug() << sql.value(4);
        query["done"] = true;
    } else {
        query["done"] = false;
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

QueryExecutor* QueryExecutor::GetInstance()
{
    static QueryExecutor* singleton = NULL;
    if (!singleton) {
        singleton = new QueryExecutor(0);
    }
    return singleton;
}

void QueryExecutor::loadTimeCounter(QVariantMap query)
{
    QString start;
    QString end;
    int seconds = 0;
    int counterType = query["counter"].toInt();
    query["running"] = false;

    switch (counterType) {
    case CounterType::Day:
//        qDebug() << "day";
        start = "'now'";
        end = "'now','+2 hour'";
//        sqlQuery = "select start, end from workunits where (projectuid=) and (start > date('now') or end > date('now','+2 hour'));";
        break;
    case CounterType::Week:
        qDebug() << "Week";
        start = "'now','weekday 1','-7 days'";
        end = "'now','weekday 1','-7 days'";
//        sqlQuery = "select start, end from workunits where () and (start > date('now','weekday 1','-7 days') or end > date('now','weekday 1', '-7 days'));";
        break;
    case CounterType::Month:
//        qDebug() << "month";
        start = "'now','start of month'";
        end = "'now','start of month'";
//        sqlQuery = "select start, end from workunits where () and (start > date('now','start of month') or end > date('now','start of month'));";
        break;
    case CounterType::Individual:
        break;
    default:
        // Request out of range, to nothing
        qDebug() << "ERROR: Request out of range";
        return;
    }

    QSqlQuery sql(QString("SELECT start, end FROM workunits WHERE (projectuid=%1) and (start > date(%2) or end > date(%3));")
                  .arg(query["projectuid"].toInt())
                  .arg(start)
                  .arg(end),
                  m_db);
    qDebug() << sql.lastQuery();
    if (sql.lastError().type() == QSqlError::NoError ) {
        while (sql.next()) {
            if (counterType == CounterType::Week)
                qDebug() << "work unit start: " << sql.value(0).toString() << " end: " << sql.value(1).toString();
            QDateTime start = sql.value(0).toDateTime();
            QTime startTime = start.time();
            // Sanity check for validity and start date from future -> discard this work unit
            if (!start.date().isValid() || start.date() > QDate::currentDate()) {
                continue;
            }
            // If day counter: Check start date if it is before today
            // If yes -> set to midnight
            if ((counterType == CounterType::Day) && (start.date() < QDate::currentDate())) {
                startTime = QTime(0, 0, 0, 0);
            }
//            qDebug() << "start time: " << startTime.toString();

            QDateTime end = sql.value(1).toDateTime();
            QTime endTime = end.time();
            // Check if end date is set otherwise the work unit is still running
            if (!end.date().isValid()) {
                query["running"] = true;
                endTime = QTime::currentTime();
            } else
                // If day counter: Sanity check for end date from any day before today -> discard this work unit
                if ((counterType == CounterType::Day) && (end.date() < QDate::currentDate())) {
                    continue;
                } else
                    // If day counter: Check if end date is after today
                    // If yes -> set to one second before next midnight
                    if ((counterType == CounterType::Day) && (end.date() > QDate::currentDate())) {
                        endTime = QTime(23,59,59,999);
                    }
//            qDebug() << "end time: " << endTime.toString();

            seconds += startTime.msecsTo(endTime);
//            qDebug() << "Milliseconds: " << seconds;
        }
        query["worktime"] = seconds;
        // Send result back to QML world

        // TODO: calculate break time
        query["breaktime"] = 0;

        query["done"] = true;
    } else {
        qDebug() << "ERROR";
        query["done"] = false;
        query["error"] = sql.lastError().text();
    }

    Q_EMIT actionDone(query);
}

void QueryExecutor::loadReport(QVariantMap query)
{
//    QSqlQuery sql("SELECT * FROM workunits WHERE start > date('now','start of month') OR end > date('now','start of month') ORDER BY datetime(start) DESC;", m_db);
    QSqlQuery sql("SELECT * FROM workunits ORDER BY datetime(start) DESC;", m_db);
    if (!sql.isValid()) {
        query["done"] = false;
        Q_EMIT actionDone(query);
    }
    while (sql.next()) {
        int workSeconds = 0;
        int breakSeconds = 0;
        QDateTime start = sql.value(2).toDateTime();
        QDateTime end = sql.value(3).toDateTime();
        workSeconds += start.secsTo(end);

// TODO: calculate break time

        query["done"] = true;
        query["uid"] = sql.value(0).toInt();
        query["projectuid"] = sql.value(1).toInt();
        if (workSeconds < (60*60*24)) {
            query["day"] = start.toString("dddd, d. MMMM yyyy");
        } else {
            query["day"] = QString("%1 - %2")
                    .arg(start.toString("dddd, d. MMM yyyy"))
                    .arg(end.toString("dddd, d. MMM yyyy"));
        }
        query["starttime"] = start.toString("hh:mm");
        if (end.isValid()) {
            query["endtime"] = end.toString("hh:mm");
            if (breakSeconds > 0) {
                query["breaktime"] = QString("%1m").arg(0);
            } else {
                query["breaktime"] = QString("-");
            }
            query["worktime"] = QString("%1h %2m")
                    .arg(workSeconds / (60*60), 2, 10, QLatin1Char('0'))
                    .arg((workSeconds/60) % 60, 2, 10, QLatin1Char('0'));
        } else {
            query["endtime"] = QString("--:--");
            query["breaktime"] = QString("-");
            query["worktime"] = QString("-");
        }
        Q_EMIT actionDone(query);
    }
}
