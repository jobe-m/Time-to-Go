
#include "BackgroundThread.h"

// Global static pointer used to ensure a single instance of the class
// It is used by Time2Go QML objects like Time2GoWorkUnit plugin class to access data of the sql database
BackgroundThread* BackgroundThread::m_Instance = new BackgroundThread;

BackgroundThread::BackgroundThread(QObject *parent)
    : QObject(parent),
      m_workerThread(),
      m_worker() // worker has got no parent because it must be moved to another thread.
{
    m_worker.moveToThread(&m_workerThread);
    m_workerThread.start();
}

BackgroundThread::~BackgroundThread()
{
    if (m_workerThread.isRunning()) {
        m_workerThread.quit();
        m_workerThread.wait();
        m_workerThread.terminate();
    }
}

BackgroundThread* BackgroundThread::getInstance()
{
    Q_ASSERT(m_Instance);
    return m_Instance;
}
