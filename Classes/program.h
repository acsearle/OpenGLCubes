//
//  program.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#ifndef __OSXGLEssentials__program__
#define __OSXGLEssentials__program__

#include <OpenGL/OpenGL.h>
#include <string>

#include "named.h"
#include "shader.h"

class program : public named {
    
    program(const program&);
    
    program& log();
    
public:
    
    program();
    virtual ~program();
    
    program& bindAttrib(GLuint index, std::string name);
    program& bindFrag(GLuint index, std::string name);
    program& attach(shader& s);
    program& link();
    program& validate();
    program& use();
    
};


#endif /* defined(__OSXGLEssentials__program__) */
