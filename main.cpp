#include "mainwindow.h"
#include <QApplication>

#ifdef Q_OS_MAC
#include "cocoainitializer.h"


//#include "SparkleAutoUpdater.h"
#endif

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);


    MainWindow w;
    w.show();

#ifdef Q_OS_MAC
    CocoaInitializer initializer;
#endif
    return a.exec();
}
