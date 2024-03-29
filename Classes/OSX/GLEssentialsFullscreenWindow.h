/*
 Fullscreen window class.
 All logic here could have been done in the window controller except that, by default, borderless windows cannot be made key and input cannot go to them.
 Therefore, this class exists to override canBecomeKeyWindow allowing this borderless window to accept inputs.
 This class is not part of the NIB and entirely managed in code by the window controller.
 */

#import <Cocoa/Cocoa.h>

@interface GLEssentialsFullscreenWindow : NSWindow

@end
