#include <QThreadPool>
#include <QDebug>
#include <QStandardPaths>

#include "QueryExecutor.h"

QueryExecutor::QueryExecutor(QObject *parent) :
    QObject(parent)
{
    m_worker.setCallObject(this);

    m_db = QSqlDatabase::database();
    if (!m_db.isOpen()) {
        qDebug() << "QE Opening database";
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
        m_db.exec("DROP TABLE IF EXISTS settings");
        m_db.exec("DROP TABLE IF EXISTS projects");
        m_db.exec("DROP TABLE IF EXISTS workunits");
        m_db.exec("DROP TABLE IF EXISTS breaks");
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
    qDebug() << "QE Processing query:" << query;
    if (!query.isEmpty()) {
        switch (query["type"].toInt()) {
        case QueryType::LoadProject: { loadProject(query); break; }
        case QueryType::SaveProject: { saveProject(query); break; }
        case QueryType::LoadWorkUnit: { loadWorkUnit(query); break; }
        case QueryType::SaveWorkUnit: { saveWorkUnit(query); break; }
        case QueryType::LoadLatestWorkUnit: { loadLatestWorkUnit(query); break; }
        case QueryType::LoadTimeCounter: { loadTimeCounter(query); break; }
        default: { break; }
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
        qDebug() << sql.value(0);
        query["projectuid"] = sql.value(1);
        qDebug() << sql.value(1);
        query["start"] = sql.value(2);
        qDebug() << sql.value(2);
        query["end"] = sql.value(3);
        qDebug() << sql.value(3);
        query["notes"] = sql.value(4);
        qDebug() << sql.value(4);
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
    QSqlQuery sql("SELECT start FROM workunits ORDER BY datetime(start) DESC LIMIT 1;", m_db);
}
