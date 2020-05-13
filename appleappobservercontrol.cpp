#include "appleappobservercontrol.h"
#include "appleappobserver.h"

AppleAppObserverControl::AppleAppObserverControl(QObject *parent) : QObject(parent)
{
#ifdef Q_OS_MAC


#endif
}

AppleAppObserverControl::~AppleAppObserverControl(){

}

void AppleAppObserverControl::setNotifierSignal(QString text)
{
    //
}
void AppleAppObserverControl::sendNotifierSignal()
{
emit switched();
}
