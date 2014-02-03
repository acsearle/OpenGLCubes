/*
 Window controller class. Necessary to switch back and forth between a fullscreen and non-fullscreen window.
 The window property on NSWindowController is connected to the window in the NIB (via Interface Builder).
 */

#import <Cocoa/Cocoa.h>
#import "GLEssentialsGLView.h"

@interface GLEssentialsWindowController : NSWindowController {

	// IBOutlet must be used so that, in Inteface Builder,
	// we can connect the view in the NIB to windowedView
	IBOutlet GLEssentialsGLView *view;
}

@end
