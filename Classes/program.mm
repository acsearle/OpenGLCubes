//
//  program.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#include <OpenGL/gl3.h>
#include "program.h"
#include <OpenGL/gl3ext.h>
using namespace std;

    program& program::log() {
        GLint n;
        glGetProgramiv(name, GL_INFO_LOG_LENGTH, &n);
        if (n > 0)
        {
            string s;
            s.resize(n);
            glGetProgramInfoLog(name, n, &n, (GLchar*) s.data());
            NSLog(@"Program info log:\n%s\n", s.data());
        }
        return *this;
    }

    program::program() :
    name(glCreateProgram()) {
    }
    
    program::~program() {
        glDeleteProgram(name);
    }
    
    program::operator GLuint() const {
        return name;
    }
    
    program& program::bindAttrib(GLuint index, string name) {
        glBindAttribLocation(this->name, index, name.c_str());
        return *this;
    }

program& program::bindFrag(GLuint index, string name) {
    glBindFragDataLocation(this->name, index, name.c_str());
    return *this;
}

    
    program& program::attach(shader& s) {
        glAttachShader(name, s);
        return *this;
    }
    
    program& program::link() {
        glLinkProgram(name);
        log();
        GLint status;
        glGetProgramiv(name, GL_LINK_STATUS, &status);
        if (!status) {
            NSLog(@"Failed to link program");
        }
        return *this;
    }
    
    program& program::validate() {
        glValidateProgram(name);
        log();
        GLint status;
        glGetProgramiv(name, GL_VALIDATE_STATUS, &status);
        if (!status) {
            NSLog(@"Failed to validate program");
        }
        return *this;
    }
    
    program& program::use() {
        glUseProgram(name);
        return *this;
    }
    
