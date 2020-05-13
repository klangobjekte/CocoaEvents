#include "interactionwindowcontroller.h"

/*
InteractionWindowController::InteractionWindowController()
{

}
*/

#import "InteractionWindowController.h"
//#import "AppDelegate.h"
#import "appleappobserver.h"
#import "UIElementUtilities.h"

#define HIDE_TO_COMPILE

@implementation InteractionWindowController

- (void)windowDidLoad {
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

// TODO: Need a better way of making sure highlight window closes when interaction window closes
- (void)windowWillClose:(NSNotification *)note {
    [[NSApp delegate] performSelector:@selector(unlockCurrentUIElement:) withObject:nil afterDelay:0];
}

#pragma mark -

// -------------------------------------------------------------------------------
//	interactWithUIElement:uiElement
//
//	Open the interaction window which is locked onto the given uiElement.
// -------------------------------------------------------------------------------
- (void)interactWithUIElement:(AXUIElementRef)element
{
    NSArray* attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];

    // populate attributes pop-up menus
    [_attributesPopup removeAllItems];

    // reset the contents of the elements popup
    [_elementsPopup removeAllItems];
    [_elementsPopup addItemWithTitle:@"goto"];

    if (attributeNames && [attributeNames count]){

    NSMenu *attributesPopupMenu = [_attributesPopup menu];

    for (NSString *attributeName in attributeNames) {

         //   CFTypeRef	theValue;

            // Grab settable field
        BOOL isSettable = [UIElementUtilities canSetAttribute:attributeName ofUIElement:element];

            // Add name to pop-up menu
        NSMenuItem *newItem = [attributesPopupMenu addItemWithTitle:[NSString stringWithFormat:@"%@%@", attributeName, (isSettable ? @" (W)":@"")] action:nil keyEquivalent:@""];
        [newItem setRepresentedObject:attributeName];

        // If value is an AXUIElementRef, or array of them, add them to the elements popup
        id value = [UIElementUtilities valueOfAttribute:attributeName ofUIElement:element];

        if (value) {

        /* One wrinkle in our UIElementUtilities methods that wrap the underlying AX C functions.  The value returned for some attributes is another UI element - an AXUIElementRef.  Because of this, to check for whether the value is an AXUIElementRef, we use CF conventions to check for type.
        */
                if (CFGetTypeID((CFTypeRef)value) == AXUIElementGetTypeID()) {

                    NSMenuItem *item;
                    [_elementsPopup addItemWithTitle:attributeName];
                    item = [_elementsPopup lastItem];
                    [item setRepresentedObject:(id)value];
                    [item setAction:@selector(navigateToUIElement:)];
                    [item setTarget:[_elementsPopup target]];

                } else if ([value isKindOfClass:[NSArray class]]) {

                    NSArray *values = (NSArray *)value;
                    if ([values count] > 0 && CFGetTypeID((CFTypeRef)[values objectAtIndex:0]) == AXUIElementGetTypeID()) {
                        NSMenu *menu = [[NSMenu alloc] init];
            for (id element in values) {
                            NSString *role  = [UIElementUtilities roleOfUIElement:(AXUIElementRef)element];
                            NSString *title  = [UIElementUtilities titleOfUIElement:(AXUIElementRef)element];
                            NSString *itemTitle = [NSString stringWithFormat:title ? @"%@-\"%@\"" : @"%@", role, title];
                            NSMenuItem *item = [menu addItemWithTitle:itemTitle action:@selector(navigateToUIElement:) keyEquivalent:@""];
                            [item setTarget:[_elementsPopup target]];
                            [item setRepresentedObject:element];
                        }
                        [_elementsPopup addItemWithTitle:attributeName];
                        [[_elementsPopup lastItem] setSubmenu:menu];
                        [menu release];
                    }
                }
            }
        }

        [_actionsPopup setEnabled:true];
        [_elementsPopup setEnabled:true];
        [self attributeSelected:NULL];
    }
    else {
        [_attributesPopup setEnabled:false];
        [_elementsPopup setEnabled:false];
        [_attributeValueTextField setEnabled:false];
        [_setAttributeButton setEnabled:false];
    }

    // populate the popup with the actions for the element
    [_actionsPopup removeAllItems];

    NSArray *actionNames = [UIElementUtilities actionNamesOfUIElement:element];

    if (actionNames && [actionNames count]) {

    NSMenu *actionsPopupMenu = [_actionsPopup menu];
    for (NSString *actionName in actionNames) {
            NSMenuItem *newItem = [actionsPopupMenu addItemWithTitle:actionName action:nil keyEquivalent:@""];
        /* Set the action name as the represented object as well.  That way if the title changes (maybe displaying the localized action description rather than the constant's literal value), we still have the correct value as the represented object. */
        [newItem setRepresentedObject:actionName];
    }

        [_actionsPopup setEnabled:true];
        [self actionSelected:NULL];
    }
    else {
        [_actionsPopup setEnabled:false];
        [_performActionButton setEnabled:false];
    }

    // set the title of the interaction window
    {
        NSString *uiElementRole  = [UIElementUtilities roleOfUIElement:element];
        NSString *uiElementTitle  = [UIElementUtilities titleOfUIElement:element];

        if (uiElementRole) {

            if (uiElementTitle && [uiElementTitle length])
                [[self window] setTitle:[NSString stringWithFormat:@"Locked on <%@ “%@”>", uiElementRole, uiElementTitle]];
            else
                [[self window] setTitle:[NSString stringWithFormat:@"Locked on <%@>", uiElementRole]];
        }
        else
            [[self window] setTitle:@"Locked on UIElement"];

    }

    // show the window
    [[self window] orderFront:NULL];

}

#pragma mark -

#ifndef HIDE_TO_COMPILE
// -------------------------------------------------------------------------------
//	attributeSelected:sender
// -------------------------------------------------------------------------------
- (IBAction)attributeSelected:(id)sender
{
    NSString *attributeName = nil;
    NSArray *theNames = nil;
    Boolean theSettableFlag = false;

    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];

    // Set text field with value
    attributeName = [[_attributesPopup selectedItem] representedObject];
    [_attributeValueTextField setStringValue:[UIElementUtilities descriptionForUIElement:element attribute:attributeName beingVerbose:false]];

    // Update text fields and button based on settable flag
    AXUIElementIsAttributeSettable( element, (CFStringRef)attributeName, &theSettableFlag );
    [_attributeValueTextField setEnabled:theSettableFlag];
    [_attributeValueTextField setEditable:theSettableFlag];
    [_setAttributeButton setEnabled:theSettableFlag];

    [theNames release];
}

// -------------------------------------------------------------------------------
//	setAttributeValue:sender
// -------------------------------------------------------------------------------
- (IBAction)setAttributeValue:(id)sender
{
    NSString *stringValue = [_attributeValueTextField stringValue];
    NSString *attributeName = [[_attributesPopup selectedItem] representedObject];
    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];

    [UIElementUtilities setStringValue:stringValue forAttribute:attributeName ofUIElement:element];
}

// -------------------------------------------------------------------------------
//	actionSelected:sender
//
//	Enables or disables the Action popup depending on the given uiElement.
// -------------------------------------------------------------------------------
- (IBAction)actionSelected:(id)sender
{
    [_performActionButton setEnabled:true];
}

// -------------------------------------------------------------------------------
//	performAction:sender
//
//	User clicked the "Perform" button in the locked on window.
// -------------------------------------------------------------------------------
- (IBAction)performAction:(id)sender
{

    AXUIElementRef element = [(id)[NSApp delegate] currentUIElement];

   pid_t pid = 0;
    if (pid = [UIElementUtilities processIdentifierOfUIElement:element]) {
    // pull the target app forward
    NSRunningApplication *targetApp = [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
    if ([targetApp activateWithOptions:NSApplicationActivateAllWindows | NSApplicationActivateIgnoringOtherApps]) {
        // perform the action
        [UIElementUtilities performAction:[[_actionsPopup selectedItem] representedObject] ofUIElement:element];
    }
    }
}
#endif

@end
