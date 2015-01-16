
#ifndef BACKGROUNDTHREAD_H
#define BACKGROUNDTHREAD_H

#include <QObject>
#include <QThread>
#include "QueryExecutor.h"

class BackgroundThread : public QObject
{
    Q_OBJECT

public:
    virtual ~BackgroundThread();

    static BackgroundThread* getInstance();

    // access to internal worker needed to connect to its slots
    QueryExecutor* getWorker() { return &m_worker; }

private:
    // Prevent object creation, it will be created as singleton object
    BackgroundThread(QObject* parent = 0);
    Q_DISABLE_COPY(BackgroundThread)

    QThread m_workerThread;
    QueryExecutor m_worker;
    static BackgroundThread* m_Instance;
};


#endif // BACKGROUNDTHREAD_H
