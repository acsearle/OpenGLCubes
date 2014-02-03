/*
 The GLEssentialsGLView class creates an OpenGL context and delegates to the OpenGLRenderer class for creating and drawing the shaders.
  */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CVDisplayLink.h>


#import "imageUtil.h"

@interface GLEssentialsGLView : NSOpenGLView {
	CVDisplayLinkRef displayLink;
}

@end
