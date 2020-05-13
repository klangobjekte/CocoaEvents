#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QVBoxLayout>
class QObject;
class QEvent;
class QPoint;

class AppleAppObserver;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QMainWindow *parent = nullptr);
    QWidget *centralWidget=nullptr;
    QLabel *textLabel = nullptr;
    QVBoxLayout *vBoxLayout = nullptr;
    ~MainWindow();
    virtual bool eventFilter(QObject *watched, QEvent *event);
public slots:
    void setText(QString text);
private:
    AppleAppObserver *observer= nullptr;
    QPoint dragStartPosition;

};
#endif // MAINWINDOW_H
