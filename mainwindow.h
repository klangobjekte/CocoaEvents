#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QLabel>
#include <QVBoxLayout>
class QObject;
class QEvent;
class QPoint;

class AppleAppObserver;
class QLineEdit;
class QTextEdit;
class QPushButton;
class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(AppleAppObserver *observer,QMainWindow *parent = nullptr);

    QWidget *centralWidget=nullptr;
    QTextEdit *textLabel = nullptr;
    QVBoxLayout *vBoxLayout = nullptr;
    QPushButton *testButton;
    ~MainWindow();
    virtual bool eventFilter(QObject *watched, QEvent *event);
public slots:
    void setText(QString text);
    void on_testButton_clicked(bool clicked);
private:
    AppleAppObserver *mObserver= nullptr;
    QPoint dragStartPosition;

};
#endif // MAINWINDOW_H
