#ifndef APPLEAPPOBSERVERCONTROL_H
#define APPLEAPPOBSERVERCONTROL_H

#include <QObject>
class AppleAppObserver;

class AppleAppObserverControl : public QObject
{
    Q_OBJECT
public:
    explicit AppleAppObserverControl(QObject *parent = nullptr);
    ~AppleAppObserverControl();

    void setNotifierSignal(QString text);
    void sendNotifierSignal();

signals:
    void switched();

public slots:

private:

};

#endif // APPLEAPPOBSERVERCONTROL_H
