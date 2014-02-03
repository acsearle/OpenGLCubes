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

class shader {
    GLuint name;
    shader(const shader&);
public:
    shader(GLenum type, std::vector<std::string> sources);
    ~shader();
    operator GLint();
};



#endif /* defined(__OSXGLEssentials__shader__) */
