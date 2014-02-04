//
//  shader.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#ifndef __OSXGLEssentials__shader__
#define __OSXGLEssentials__shader__

#include <OpenGL/OpenGL.h>
#include <string>
#include <vector>
#include "named.h"

class shader : public named {
public:
    shader(GLenum type, std::vector<std::string> sources);
    ~shader();
};



#endif /* defined(__OSXGLEssentials__shader__) */
