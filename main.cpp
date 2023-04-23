#include "appleappobserver.h"
#include "mainwindow.h"
#include <QApplication>

#ifdef Q_OS_MAC
#include "cocoainitializer.h"


//#include "SparkleAutoUpdater.h"
#endif

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    AppleAppObserver o;
    MainWindow w(&o);
    w.setGeometry(-100,100,640,320);
    w.show();

#ifdef Q_OS_MAC
    CocoaInitializer initializer;
#endif
    return a.exec();
}
