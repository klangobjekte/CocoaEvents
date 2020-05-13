#ifndef INTERACTIONWINDOWCONTROLLER_H
#define INTERACTIONWINDOWCONTROLLER_H

/*
class InteractionWindowController
{
public:
    InteractionWindowController();
};

*/

#import <Cocoa/Cocoa.h>


@interface InteractionWindowController : NSWindowController {

    IBOutlet NSPopUpButton *	_actionsPopup;
    IBOutlet NSPopUpButton *	_attributesPopup;
    IBOutlet NSPopUpButton *	_elementsPopup;
    IBOutlet NSTextField *	_attributeValueTextField;
    IBOutlet NSButton *		_setAttributeButton;
    IBOutlet NSButton *		_performActionButton;

}

- (void)interactWithUIElement:(AXUIElementRef)element;

- (IBAction)attributeSelected:(id)sender;
- (IBAction)setAttributeValue:(id)sender;
- (IBAction)actionSelected:(id)sender;
- (IBAction)performAction:(id)sender;

@end



#endif // INTERACTIONWINDOWCONTROLLER_H
