#include <QThreadPool>
#include <QDebug>
#include <QStandardPaths>

#include "QueryExecutor.h"

QueryExecutor::QueryExecutor(QObject *parent) :
    QObject(parent)
{
    m_worker.setCallObject(this);

    db = QSqlDatabase::database();
    if (!db.isOpen()) {
        qDebug() << "QE Opening database";
        db = QSqlDatabase::addDatabase("QSQLITE");

        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QString dataFile = QString("%1/database.db").arg(dataDir);

        QDir dir(dataDir);
        if (!dir.exists())
            dir.mkpath(dataDir);
        qDebug() << "DB Dir:" << dataDir;
        db.setDatabaseName(dataFile);
        qDebug() << "DB Name:" << db.databaseName();
        if (db.open())
            qDebug() << "QE opened database";
        else
            qWarning() << "QE failed to open database";
    }
    else {
        qWarning() << "QE used existing DB connection!";
    }

    if (db.isOpen()) {
        if (!db.tables().contains("projects")) {
            db.exec("CREATE TABLE projects (id INTEGER PRIMARY KEY, name TEXT);");
        }
        if (!db.tables().contains("workunits")) {
            db.exec("CREATE TABLE workunits (id INTEGER PRIMARY KEY, "
                    "project INTEGER, start DATE, end DATE, notes TEXT);");
        }
        if (!db.tables().contains("breaks")) {
            db.exec("CREATE TABLE breaks (id INTEGER PRIMARY KEY, "
                    "workunit INTEGER, start DATE, end DATE, notes TEXT);");
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
        case QueryType::SetWorkUnit: {
            setWorkUnit(query);
            break;
        }
        default: {
            break;
        }
        }
    }
}

void QueryExecutor::setWorkUnit(QVariantMap &query)
{
    QSqlQuery sql(db);
    query["done"] = false;
    int id = query["id"].toInt();
    if (0 == id) {
        // Create new work unit
        sql.prepare("INSERT INTO contacts VALUES (NULL, :project, :start, :end, :notes);");
        sql.bindValue(":project", query["project"]);
        sql.bindValue(":start", query["start"]);
        sql.bindValue(":end", query["end"]);
        sql.bindValue(":notes", query["notes"]);
        sql.exec();
        if (sql.lastError().type() == QSqlError::NoError ) {
            // Update id in query
            query["id"] = sql.lastInsertId();
            // or if not working do: "SELECT max(id) FROM workunits;"
            query["done"] = true;
        } else {
            query["error"] = sql.lastError().text();
        }
    } else {
        // Update existing work unit
        sql.prepare("UPDATE workunits SET project=(:project), start=(:start), end=(:end), notes=(:notes)  WHERE id=(:id);");
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
