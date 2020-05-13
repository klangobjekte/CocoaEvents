#include "mainwindow.h"
#include "appleappobservercontrol.h"
#include "appleappobserver.h"
#include <QDebug>
#include <QEvent>
#include <QMouseEvent>
#include <QPoint>
#include <QDrag>
#include <QMimeData>
#include <QApplication>

MainWindow::MainWindow(QMainWindow *parent)
    : QMainWindow(parent)
{
    centralWidget = new QWidget(this);
    centralWidget->show();
    setCentralWidget(centralWidget);

    textLabel = new QLabel(centralWidget);
    textLabel->setText("                             ");
    textLabel->show();
    observer = new AppleAppObserver();
    //observer->viewDidLoad();
    observer->registerReceiver(this);




    observer->viewDidLoad();

    this->setText(QStringLiteral("newTest"));


    installEventFilter(this);

}

MainWindow::~MainWindow()
{
    observer->unRegisterReceiver(this);
}



bool MainWindow::eventFilter(QObject *watched, QEvent *event){
    //qDebug() << watched << event;
    setText(observer->testForApplicationSwitched());


if(event->type() == 1100){
    qDebug() << watched << event;

    setText(observer->testForApplicationSwitched());

}

    if(event->type() == QEvent::ActivationChange)
    {
        setText(observer->testForApplicationSwitched());

    }

    if(event->type() == QEvent::WindowDeactivate)
    {
        setText(observer->testForApplicationSwitched());

    }

    if(event->type() == QEvent::DragEnter)
    {
        setText(observer->testForApplicationSwitched());

    }

    if(event->type() == QEvent::DragMove)
    {
        setText(observer->testForApplicationSwitched());

    }
    if(event->type() == QEvent::DragLeave)
    {
        setText(observer->testForApplicationSwitched());

    }

    if (event->type() == QEvent::MouseButtonPress)
    {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        dragStartPosition = mouseEvent->pos();
        return false;
    }
    if (event->type() == QEvent::MouseButtonPress)
    {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        dragStartPosition = mouseEvent->pos();
        return false;
    }
    if (event->type() == QEvent::MouseMove)
    {
        QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
        qDebug() << observer->testForApplicationSwitched();
        setText(observer->testForApplicationSwitched());

        int distance = (mouseEvent->pos() - dragStartPosition).manhattanLength();
        if (distance >= QApplication::startDragDistance())
        {
            QDrag *drag = new QDrag(this);
            QMimeData *mimeData = new QMimeData();
            mimeData->setText(QString("test"));
            drag->setMimeData(mimeData);
            Qt::DropAction dropAction = drag->exec(Qt::CopyAction);
        }



        return false;

    }
    return false;
}


void MainWindow::setText(QString text){
    //qDebug() << "setText: ";
    textLabel->setText(text);
}

