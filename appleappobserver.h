#ifndef APPLEAPPOBSERVER_H
#define APPLEAPPOBSERVER_H
#include <QString>
#include <QObject>
#include <QEvent>
#include <set>

const int SwitchEventID = QEvent::User + 100;
class SwitchEvent : public QEvent
{
public:
    SwitchEvent()
        : QEvent(QEvent::Type(SwitchEventID))
          {}


};
class AppleAppObserverPrivate;


class AppleAppObserver: public QObject
{
Q_OBJECT
public:
    AppleAppObserver(QObject *parent = nullptr);
    ~AppleAppObserver();
    void viewDidLoad();
    AppleAppObserverPrivate *appleAppObserverPrivate(){
        return dd;
    }

    QString testForApplicationSwitched();
    void registerReceiver(QObject* obj);
    void unRegisterReceiver(QObject* obj);



signals:


private:
    //class Private;
    //Private* d;
    AppleAppObserverPrivate *dd;
    QString _switchedApplication;


};

#endif // APPLEAPPOBSERVER_H
