#include "appleappobserver.h"
#include "uielementutilities.h"
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

#include <QApplication>
#include <QDebug>
#include <QObject>
#include <QEvent>
#include <QTimer>
#include "appleappobservercontrol.h"
#include "interactionwindowcontroller.h"
#include "inspectorwindowcontroller.h"






static QString toQString(CFStringRef str)
{
    if (!str)
        return QString();

    CFIndex length = CFStringGetLength(str);
    if (length == 0)
        return QString();

    QString string(length, Qt::Uninitialized);
    CFStringGetCharacters(str, CFRangeMake(0, length), reinterpret_cast<UniChar *>
                          (const_cast<QChar *>(string.unicode())));
    return string;
}

QString qt_mac_NSStringToQString(const NSString *nsstr)
{
    NSRange range;
    range.location = 0;
    range.length = [nsstr length];
    //QString result(range.length, QChar(0));

    unichar *chars = new unichar[range.length+1];
    [nsstr getCharacters:chars range:range];
    QString result = QString::fromUtf16(chars, range.length);
    delete[] chars;
    return result;
}



static void sApplicationSwitched( AXObserverRef observer,
                                  AXUIElementRef element,
                                  CFStringRef notificationName,
                                  void * contextData );

static QString staticFrontMostApplicationName;


class AppleAppObserverPrivate: public QObject
{

    Q_OBJECT
private:
    NSString *frontMostAppName_=nullptr;
    QString _frontApplicationName;
    QString _hoverApplicationName;
    QString _hoverWindowName;



    //AppleAppObserver *q;
    std::set<QObject*> _eventReceivers;
    NSMutableDictionary     *_observers;
    pid_t                    _currentPid;

    InspectorWindowController		    *_inspectorWindowController;
    InteractionWindowController		    *_interactionWindowController;

    AXUIElementRef			    _systemWideElement;
    NSPoint				    _lastMousePoint;
    AXUIElementRef			    _currentUIElement=NULL;
    BOOL				    _currentlyInteracting;
    BOOL				    _highlightLockedUIElement;

public slots:
    QString hoverApplicationName(){return _hoverApplicationName;}
    QString hoverWindowName(){return _hoverWindowName;}
    /**
     * @brief performTimerBasedUpdate
     * Timer to continually update the current uiElement being examined.
     */
    void performTimerBasedUpdate()
    {
        updateCurrentUIElement();
        //[NSTimer scheduledTimerWithTimeInterval:0.1 target: self
        //                                            selector:@selector(performTimerBasedUpdate)
        //                                            userInfo:nil
        //                                            repeats:NO];
        QTimer::singleShot(100, this, SLOT(performTimerBasedUpdate()));
    }


public:

    void setCurrentUIElement(AXUIElementRef uiElement)
    {
        [(id)_currentUIElement autorelease];
        _currentUIElement = (AXUIElementRef)[(id)uiElement retain];
    }


    AXUIElementRef currentUIElement()
    {
        return _currentUIElement;
    }

    void registerReceiver(QObject* obj)
    {
        _eventReceivers.insert(obj);
    }
    void unRegisterReceiver(QObject* obj)
    {
        _eventReceivers.erase(obj);
    }


    //NSString *frontMostAppName(){return frontMostAppName_;}
    //QString frontApplicationName(){return _frontApplicationName;}

    BOOL isInteractionWindowVisible()
    {
        return [[_interactionWindowController window] isVisible];
    }

    void updateCurrentUIElement()
    {
        //if (!isInteractionWindowVisible()) {

            // The current mouse position with origin at top right.
            NSPoint cocoaPoint = [NSEvent mouseLocation];

            // Only ask for the UIElement under the mouse if has moved since the last check.
            if (!NSEqualPoints(cocoaPoint, _lastMousePoint)) {

                CGPoint pointAsCGPoint = [UIElementUtilities carbonScreenPointFromCocoaScreenPoint:cocoaPoint];

                AXUIElementRef newElement = NULL;

                /* If the interaction window is not visible, but we still think we are interacting, change that */
                //if (_currentlyInteracting) {
                //    _currentlyInteracting = ! _currentlyInteracting;
                //    [_inspectorWindowController indicateUIElementIsLocked:_currentlyInteracting];
                //}

                // Ask Accessibility API for UI Element under the mouse
                // And testupdate the display if a different UIElement
                if (AXUIElementCopyElementAtPosition( _systemWideElement, pointAsCGPoint.x,
                                                      pointAsCGPoint.y,
                                                      &newElement ) == kAXErrorSuccess
                        && newElement
                        && (currentUIElement() == NULL ||
                            ! CFEqual( currentUIElement(), newElement )))
                {

                    //NSLog(@"titleOfUIElement \"%@\".", [UIElementUtilities titleOfUIElement:newElement]);
                    //NSLog(@"descriptionOfAXDescriptionOfUIElement \"%@\".", [UIElementUtilities descriptionOfAXDescriptionOfUIElement:newElement]);
                    //NSLog(@"stringDescriptionOfUIElement \"%@\".", [UIElementUtilities stringDescriptionOfUIElement:newElement]);
                    //NSLog(@"lineageDescriptionOfUIElement \"%@\".", [UIElementUtilities lineageDescriptionOfUIElement:newElement]);


                    //QString qStringDescriptionOfUIElement = qt_mac_NSStringToQString([UIElementUtilities stringDescriptionOfUIElement:newElement]);

                    //NSLog(@"descriptionForUIElement \"%@\".", [UIElementUtilities descriptionForUIElement:newElement
                    //attribute:theName beingVerbose:false]]);

                    NSString *attributeName = nil;
                    NSArray *theNames = nil;
                    Boolean theSettableFlag = false;



                    //NSLog(@"AXApplication \"%@\".", [UIElementUtilities descriptionForUIElement:newElement attribute:@"AXApplication" beingVerbose:true]);

                    NSMutableArray *lineagesOfUIElement = [[NSMutableArray alloc] init];
                    //! lineage = abstammungsgruppe
                    lineagesOfUIElement = [UIElementUtilities lineageOfUIElement:newElement];

/*
                     QJsonArray jLineagesOfUIElement;
                     QJsonObject jElement=
                     {
                         {"CHANNEL_INDEX", chIndex},
                         {"INTERLEAVE_INDEX", interleaved},
                         {"NAME", name},
                         {"FUNCTION", function},
                     };
                     */
                     for (id element in lineagesOfUIElement) {
                        NSLog(@"lineage \"%@\".", element);
                        //NSLog(@"Element AXApplication: %@", [element valueForKey:@"AXApplication"]); // or element[@"asr"]

                       QString qElement = qt_mac_NSStringToQString(element);
                       qElement.chop(1);
                       qElement.remove(0,1);
                       QStringList keyValue = qElement.split(":");
                       if(keyValue.at(0)=="AXApplication"){
                           _hoverApplicationName = keyValue.at(1);
                       //qDebug() << "_hoverApplicationMame " << _hoverApplicationName;
                       sendNotifier();
                       }
                      if(keyValue.at(0)=="AXWindow")
                           _hoverWindowName = keyValue.at(1);
                       qDebug() << "_hoverApplicationMame " << _hoverApplicationName;
                       //qDebug() << "_hoverWindowName      " << _hoverWindowName;


                     }





                    //NSLog(@"jsonlineagesOfUIElement \"%@\".", jsonlineagesOfUIElement);







//(id)valueForKey:(NSString *)key;

                   //to extract items
                     //NSDictionary *items = [[[jsonlineagesOfUIElement objectForKey:@"items"] JSONValue] objectAtIndex:0];


                    //NSLog(@"Element AXApplication: %@", [lineagesOfUIElement objectForKey:@"AXApplication"]); // or element[@"asr"]


                    //[this setCurrentUIElement:newElement];
                    setCurrentUIElement(newElement);
                    //[self updateUIElementInfoWithAnimation:NO];

                    /*

                    NSArray* attributeNames = [UIElementUtilities attributeNamesOfUIElement:newElement];
                    for (NSString *attributeName in attributeNames) {
                        //NSLog(@"attributeName \"%@\".", attributeName);

                    }
                    NSArray* actionNames = [UIElementUtilities actionNamesOfUIElement:newElement];
                    for (NSString *actionName in actionNames) {
                        //NSLog(@"actionName \"%@\".", actionName);

                    }
                    */
                }

                _lastMousePoint = cocoaPoint;
            }
        //}
    }







    /*
         Updates the current status and icon of users in iChat and "iChatStatus" window.
         Sets the user's status and icon to the fronmost application's name and icon.
         */
    void applicationSwitched()
    {

        //frontMostAppName_=nil;
        /* Get information about the current active application */
        NSRunningApplication *frontMostApp;
        frontMostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        //NSRunningApplication *frontMostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        /*
            NSArray<NSRunningApplication *> *runningApplications =  [[NSWorkspace sharedWorkspace] runningApplications];

            for (NSRunningApplication *application in runningApplications) {
                //NSLog(@"runningApplications \"%@\".", [application localizedName]);

                if([application isActive])
                {
                    frontMostApp = application;
                }
            }
*/
        /* Get the application's process id  */
        pid_t switchedPid = [frontMostApp processIdentifier];
        //NSLog(@"applicationSwitched \"%@\".", [frontMostApp localizedName]);

        /* Do not do anything if we do not have new application in the front or if are in the front ourselves */
        // if(switchedPid !=_currentPid && switchedPid != getpid())
        if(switchedPid !=_currentPid && switchedPid)

        {
            NSLog(@"applicationSwitched \"%@\".", [frontMostApp localizedName]);
            frontMostAppName_ = [frontMostApp localizedName];
            if(frontMostAppName_)
                staticFrontMostApplicationName = qt_mac_NSStringToQString(frontMostAppName_);


#define HIDE_NOW
#ifndef HIDE_NOW
            /* Only update iChat's status if it is running and the current status is set to available */
            if([_iChatApp isRunning]) {

                if ([_iChatApp status] == iChatMyStatusAvailable) {
                    /* Grab the icon of the running application as an NSImage */
                    NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[frontMostApp valueForKey:@"NSApplicationPath"]];

                    /* Set the buddy picture in iChat to the icon (using the bridged iChat application object) */
                    [_iChatApp setImage:iconImage];

                    /* Set the application's icon view in the "iChatStatus" window to the icon image */
                    [_appIconView setImage:iconImage];

                    NSString *statusString = [NSString stringWithFormat:@"Using %@", [frontMostApp objectForKey:@"NSApplicationName"]];

                    /* Set the status message in iChat to the running application (using the bridged iChat application object) */
                    [_iChatApp setStatusMessage:statusString];

                    /* Set the status message in the "iChatStatus" window */
                    [_appLabelField setStringValue:statusString];
                } else {
                    /* Current status is not set to available */
                    [_appIconView setImage:nil];
                    [_appLabelField setStringValue:@"Status is not set to available"];
                }

            } else {
                /* iChat is not running  */
                [_appIconView setImage:nil];
                [_appLabelField setStringValue:@"iChat is not running"];
            }
#endif
            /* Store this application's process id so we can compare it with the process id of the next frontmost application */
            _currentPid = switchedPid;
            sendNotifier();
        }
    }

    void sendNotifier(){
        for (auto iter= _eventReceivers.begin(); iter != _eventReceivers.end(); ++iter)
            QCoreApplication::postEvent(*iter, new SwitchEvent());


    }

    // register all running applictions to listen to the kAXApplicationActivatedNotification event
    void registerForAppSwitchNotificationFor(NSRunningApplication * application)
    {
        NSLog(@"Running application \"%@\".", [application localizedName]);

        //NSNumber *pidNumber = [application valueForKey:@"NSApplicationProcessIdentifier"];
        pid_t pid = [application processIdentifier];

        /* Don't sign up for our own switch events (that will fail). */
        if(pid != getpid()) {
            /* Check whether we are not already watching for this application's switch events */
            if(![_observers objectForKey:[NSNumber numberWithInteger:pid]]) {
                //pid_t pid = (pid_t)[pid integerValue];
                NSLog(@"observer for application %d", pid);
                /* Create an Accessibility observer for the application */
                AXObserverRef observer;
                if(AXObserverCreate(pid, sApplicationSwitched, &observer) == kAXErrorSuccess) {

                    /* Register for the application activated notification */
                    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                                       AXObserverGetRunLoopSource(observer),
                                       kCFRunLoopDefaultMode);
                    AXUIElementRef element = AXUIElementCreateApplication(pid);
                    // add the notification event:
                    OSStatus error = AXObserverAddNotification(observer, element, kAXApplicationActivatedNotification, this);
                    //OSStatus error = AXObserverAddNotification(observer, element, kAXApplicationActivatedNotification, (__bridge void * _Nullable)(self);
                    error = AXObserverAddNotification(observer, element, kAXFocusedWindowChangedNotification, this);

                    error = AXObserverAddNotification(observer, element, kAXApplicationDeactivatedNotification, this);



                    if( error != kAXErrorSuccess) // _bridge cast cause of arc clang specific
                    {
                        NSLog(@"Failed to add Notification event error %d", error);
                        NSLog(@"Failed to add Notification event for application \"%@\".", [application localizedName]);
                    } else {
                        /* Remember the observer so that we can unregister later */
                        [_observers setObject:(id)observer forKey:[NSNumber numberWithInteger:pid]];
                    }
                    /* The observers dictionary wil hold on to the observer for us */
                    CFRelease(observer);
                    /* We do not need the element any more */
                    CFRelease(element);
                } else {
                    /* We could not create an observer to watch this application's switch events */
                    NSLog(@"Failed to create observer for application \"%@\".", [application valueForKey:@"NSApplicationName"]);
                }

            } else {
                /* We are already observing this application */
                NSLog(@"Attempted to observe application \"%@\" twice.", [application valueForKey:@"NSApplicationName"]);
            }
        }
    }

    void viewDidLoad() {


        // Do any additional setup after loading the view.


        /* Check if 'Enable access for assistive devices' is enabled. */
        if(!AXAPIEnabled()) {
            /*
                 'Enable access for assistive devices' is not enabled, so we will alert the user,
                 then quit because we can't update the users status on app switch as we are meant to
                 (because we can't get notifications of application switches).
                 */
            NSRunCriticalAlertPanel(@"'Enable access for assistive devices' is not enabled.", @"iChatStatusFromApplication requires that 'Enable access for assistive devices' in the 'Universal Access' preferences panel be enabled in order to monitor application switching.", @"Quit", nil, nil);
            //[NSApp terminate:self];
        }

        //#define USE_APPLICATIONSWITCHED_CALLBACK
#ifdef USE_APPLICATIONSWITCHED_CALLBACK
        _observers = [[NSMutableDictionary alloc] init];

        /* Register for activation notifications for all currently running applications */
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        /*
             for(NSDictionary *application in [workspace launchedApplications]) {

             //[self registerForAppSwitchNotificationFor:application];
             NSLog(@"observer for application \"%@\".", [application valueForKey:@"NSApplicationName"]);

             }
             */



        NSArray<NSRunningApplication *> *runningApplications =  [workspace runningApplications];

        for (id application in runningApplications)
        {
            registerForAppSwitchNotificationFor(application);
        }

        applicationSwitched();
#endif

        _systemWideElement = AXUIElementCreateSystemWide();
        performTimerBasedUpdate();
    }

};


static void sApplicationSwitched( AXObserverRef observer,
                                  AXUIElementRef element,
                                  CFStringRef notificationName,
                                  void * contextData )
{

    return ((AppleAppObserverPrivate*) contextData)->applicationSwitched();
}


/*
AppleAppObserver::AppleAppObserver( )

{
    d = new AppleAppObserver::Private();
}
*/
/*!
    Constructs an AppleAppObserver with the given \a parent.
*/
AppleAppObserver::AppleAppObserver(QObject *parent)
    : QObject(parent)
{
    dd = new AppleAppObserverPrivate();
}

/*!
  \internal
*/
/*
AppleAppObserver::AppleAppObserver(AppleAppObserverPrivate &dd, QObject *parent)
    : QObject(dd, parent)
{
}
*/


AppleAppObserver::~AppleAppObserver(){
    delete dd;
}




QString AppleAppObserver::testForApplicationSwitched()
{
    //return staticFrontMostApplicationName;
    return dd->hoverApplicationName();
}

void AppleAppObserver::viewDidLoad(){
    dd->viewDidLoad();
}

void AppleAppObserver::registerReceiver(QObject* obj)
{
    dd->registerReceiver(obj);
}

void AppleAppObserver::unRegisterReceiver(QObject* obj)
{
    dd->unRegisterReceiver(obj);
}

//! Hack to include Q_OBJECT in cpp / mm file
//! and inform the the compiler that ther is
//! AppleAppObserverPrivate::staticMetaObject to comile
#include "appleappobserver.moc"
