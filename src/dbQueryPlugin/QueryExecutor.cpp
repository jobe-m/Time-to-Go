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
            m_db.exec("CREATE TABLE settings (id INTEGER PRIMARY KEY, project INTEGER, type INTEGER,"
                    "setting INTEGER);");
        }
        if (!m_db.tables().contains("projects")) {
            m_db.exec("CREATE TABLE projects (id INTEGER PRIMARY KEY, name TEXT, "
                      "reserved INTEGER);");
            // create one default group
            m_db.exec("INSERT INTO projects VALUES (NULL, \"my awesome project\", 0);");
        }
        if (!m_db.tables().contains("workunits")) {
            m_db.exec("CREATE TABLE workunits (id INTEGER PRIMARY KEY, project INTEGER, "
                    "start DATE, end DATE, notes TEXT, reserved INTEGER);");
        }
        if (!m_db.tables().contains("breaks")) {
            m_db.exec("CREATE TABLE breaks (id INTEGER PRIMARY KEY, workunit INTEGER, "
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
    qDebug() << "QE Processing query:" << query["type"];
    if (!query.isEmpty()) {
        switch (query["type"].toInt()) {
        case QueryType::GetProject: { getProject(query); break; }
        case QueryType::SetProject: { setProject(query); break; }
        case QueryType::SetWorkUnit: { setWorkUnit(query); break; }
        case QueryType::GetLatestWorkUnit: { getLatestWorkUnit(query); break; }
        default: { break; }
        }
    }
}

void QueryExecutor::getProject(QVariantMap query)
{
    QSqlQuery sql(m_db);
    query["done"] = false;
    if (0 != query["id"].toInt()) {
        sql.prepare("SELECT * FROM projects WHERE id=(:id);");
        sql.bindValue(":id", query["id"].toInt());
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            if (sql.next()) {
                // Update query with project details
                query["id"] = sql.value(0).toInt();
                query["name"] = sql.value(1).toString();
                query["done"] = true;
            } else {
                query["error"] = QString("Project with UID %1 not found in database. Strange.").arg(query["id"].toInt());
            }
        } else {
            query["error"] = sql.lastError().text();
        }
    }
    // Send result back to QML world
    Q_EMIT actionDone(query);
}

void QueryExecutor::setProject(QVariantMap query)
{
    QSqlQuery sql(m_db);
    // Set response to not done
    query["done"] = false;
    // id is used to determine if we need to create a new table entry or if we should modify an existing table entry
    int id = query["id"].toInt();
    if (0 == id) {
        // Create new project
        sql.prepare("INSERT INTO projects VALUES (NULL, :name, 0);");
        sql.bindValue(":name", query["name"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            // Update id in query
            query["id"] = sql.lastInsertId();
            // or if lastInsertId is not working do: "SELECT max(id) FROM workunits;"
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    } else {
        // Update existing project
        sql.prepare("UPDATE projects SET name=(:name), reserved=0 WHERE id=(:id);");
        sql.bindValue(":name", query["name"]);
        sql.bindValue("id", query["id"]);
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

void QueryExecutor::setWorkUnit(QVariantMap query)
{
    QSqlQuery sql(m_db);
    query["done"] = false;
    int id = query["id"].toInt();
    if (0 == id) {
        // Create new work unit
        sql.prepare("INSERT INTO workunits VALUES (NULL, :project, :start, :end, :notes, 0);");
        sql.bindValue(":project", query["project"]);
        sql.bindValue(":start", query["start"]);
        sql.bindValue(":end", query["end"]);
        sql.bindValue(":notes", query["notes"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            // Update id in query
            query["id"] = sql.lastInsertId();
            // or if lastInsertId is not working do: "SELECT max(id) FROM workunits;"
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    } else {
        // Update existing work unit
        sql.prepare("UPDATE workunits SET project=(:project), start=(:start), end=(:end), notes=(:notes), reserved=0  WHERE id=(:id);");
        sql.bindValue(":project", query["project"]);
        sql.bindValue(":start", query["start"]);
        sql.bindValue(":end", query["end"]);
        sql.bindValue(":notes", query["notes"]);
        sql.bindValue(":id", query["id"]);
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

void QueryExecutor::getLatestWorkUnit(QVariantMap query)
{
    QSqlQuery sql("SELECT * FROM workunits ORDER BY datetime(start) DESC LIMIT 1;", m_db);
    if (sql.next()) {
        query["id"] = sql.value(0);
        qDebug() << sql.value(0);
        query["project"] = sql.value(1);
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
