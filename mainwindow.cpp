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
#include <QLineEdit>
#include <QTextEdit>
#include <QPushButton>
#include <QFileDialog>
#include <QString>

MainWindow::MainWindow(AppleAppObserver *observer, QMainWindow *parent)
    : QMainWindow(parent),
    mObserver(observer)
{
    centralWidget = new QWidget(this);
    centralWidget->setMinimumWidth(500);

        vBoxLayout = new QVBoxLayout(this);
    centralWidget->setLayout(vBoxLayout);

    setCentralWidget(centralWidget);


   // vBoxLayout->addWidget(centralWidget);

    textLabel = new QTextEdit(centralWidget);
    textLabel->setMinimumWidth(500);
    textLabel->setMinimumHeight(600);

    testButton = new QPushButton(centralWidget);

    vBoxLayout->addWidget(textLabel);
    vBoxLayout->addWidget(testButton);

  textLabel->show();


    //mObserver = new AppleAppObserver();
    //observer->viewDidLoad();
    mObserver->registerReceiver(this);
    mObserver->viewDidLoad();

    this->setText(QStringLiteral("newTest"));

    centralWidget->show();
    installEventFilter(this);

    connect(testButton,SIGNAL(clicked(bool)),
     this,SLOT(on_testButton_clicked(bool)));

}

MainWindow::~MainWindow()
{
    mObserver->unRegisterReceiver(this);
}

void MainWindow::on_testButton_clicked(bool clicked){
    QString d = "/Users/Admin/";

    QFileDialog dialog(this);
    dialog.setAccessibleName("FileDialog");
    dialog.setObjectName("FileDialog");
    dialog.setAccessibleDescription("FileDialog");
    dialog.setAcceptMode(QFileDialog::AcceptOpen);
    dialog.setFileMode(QFileDialog::AnyFile);

    QString s =  dialog.getExistingDirectory(        this,
        "FileDialog",
        d);

    /*
    QString s = QFileDialog::getExistingDirectory(
        this,
        "Select where to copy exported files",
        d);
    */
    if (s.length() > 0){
        //ui->targetProjectLineEdit->setText(s);
        qDebug() << "Directory choosen" << s;
    }

    //! to avoid that the window
    //! is behind mainwindow if
    //! it is not modal
    //this->raise();

}



bool MainWindow::eventFilter(QObject *watched, QEvent *event){
    //qDebug() << watched << event->type();

    //qDebug() << observer->testForApplicationSwitched();


    if(event->type() != QEvent::UpdateRequest && event->type() != QEvent::Paint){
        //qDebug() << watched << event->type();
        //setText(mObserver->testForApplicationSwitched() +" everyEvent " + event->type() );
    }

    if(event->type() == 1100){
        //qDebug() << watched << event;
        qDebug()<< "mObserver->testForApplicationSwitched():" << mObserver->testForApplicationSwitched();// << event->type();
        setText(mObserver->testForApplicationSwitched()+" 1100");

    }

    if(event->type() == QEvent::ActivationChange)
    {
        setText(mObserver->testForApplicationSwitched()+" ActivationChange");

    }

    if(event->type() == QEvent::WindowDeactivate)
    {
        setText(mObserver->testForApplicationSwitched()+"WindowDeactivate");

    }

    if(event->type() == QEvent::DragEnter)
    {
        setText(mObserver->testForApplicationSwitched()+"DragEnter");

    }

    if(event->type() == QEvent::DragMove)
    {
        setText(mObserver->testForApplicationSwitched()+"DragMove");

    }
    if(event->type() == QEvent::DragLeave)
    {
        setText(mObserver->testForApplicationSwitched()+"DragLeave");

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
        qDebug() << mObserver->testForApplicationSwitched();
        setText(mObserver->testForApplicationSwitched()+"MouseMove");

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
    //textLabel->setText(text);
    textLabel->append(text);
}

