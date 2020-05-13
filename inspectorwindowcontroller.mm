#include "inspectorwindowcontroller.h"
/*
InspectorWindowController::InspectorWindowController()
{

}
*/

#import "InspectorWindowController.h"

#import "UIElementUtilities.h"

@implementation InspectorWindowController


// -------------------------------------------------------------------------------
//	updateInfoForUIElement:uiElement
//	Report to our console view the uiElement's descriptive string.
// -------------------------------------------------------------------------------
- (void)updateInfoForUIElement:(AXUIElementRef)element
{
    [_consoleView setString:[UIElementUtilities stringDescriptionOfUIElement:element]];
}


// -------------------------------------------------------------------------------
//	fontSizeSelected:sender
//
//	The use chose a new font size from the font size popup.  In turn change the
//	console view's font size.
// -------------------------------------------------------------------------------
- (IBAction)fontSizeSelected:(id)sender
{
    [_consoleView setFont:[NSFont userFontOfSize:[[sender titleOfSelectedItem] floatValue]]];
}

// -------------------------------------------------------------------------------
//	indicateUIElementIsLocked:flag
//
//	To show that we are locked into a uiElement, draw the console view's text in red.
// -------------------------------------------------------------------------------
- (void)indicateUIElementIsLocked:(BOOL)flag
{
    [_consoleView setTextColor:(flag)?[NSColor redColor]:[NSColor blackColor]];
}

/* Since all of our windows are NSPanels, we can't use the regular 'app should terminated when all windows are closed' delegate, since it will ask the delegate if all that is left onscreen are NSPanels.  So, let the window close, then terminate.
Probably should move this up to the App controller, and register for the notification there.
*/
- (void)windowWillClose:(NSNotification *)note {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0];
}

@end
