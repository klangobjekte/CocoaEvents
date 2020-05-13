#ifndef INSPECTORWINDOWCONTROLLER_H
#define INSPECTORWINDOWCONTROLLER_H

/*
class InspectorWindowController
{
public:
    InspectorWindowController();
};
*/

#import <Cocoa/Cocoa.h>

@interface InspectorWindowController : NSWindowController {
    IBOutlet NSTextView* _consoleView;
}

- (void)updateInfoForUIElement:(AXUIElementRef)uiElement;

- (void)indicateUIElementIsLocked:(BOOL)flag;

- (IBAction)fontSizeSelected:(id)sender;

@end




#endif // INSPECTORWINDOWCONTROLLER_H
