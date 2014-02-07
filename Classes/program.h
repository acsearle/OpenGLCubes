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

#include "mat.h"
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
    
    // Proxy class to enable assignment to shader uniforms
    
    class uniform {
        GLint location_;
    public:
        explicit uniform(GLint location) : location_(location) {}
        void operator=(mat3 a) {
            glUniformMatrix3fv(location_, 1, GL_FALSE, a.m);
        }
        void operator=(mat4 a) {
            glUniformMatrix4fv(location_, 1, GL_FALSE, a.m);
        }
        void operator=(GLint a) {
            glUniform1i(location_, a);
        }
    };
    
    uniform operator[](const GLchar* name) {
        return uniform(glGetUniformLocation(name_, name));
    }
    
};


#endif /* defined(__OSXGLEssentials__program__) */
