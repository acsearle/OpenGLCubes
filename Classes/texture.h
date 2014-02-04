//
//  texture.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/3/14.
//
//

#ifndef __OSXGLEssentials__texture__
#define __OSXGLEssentials__texture__

#include <OpenGL/gl3.h>

#include "named.h"

class texture : public named
{
public:
    texture() {
        glGenTextures(1, &name_);
    }
    ~texture() {
        glDeleteTextures(1, &name_);
    }
};

class texture2d : public texture {
public:
    texture2d(GLsizei width, GLsizei height, GLenum format, GLenum type) {
        bind();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, type, NULL);
    }
    texture2d& bind() {
        glBindTexture(GL_TEXTURE_2D, name_);
        return *this;
    }
    texture2d& generateMipmap() {
        glGenerateMipmap(GL_TEXTURE_2D);
        return *this;
    }
};


#endif /* defined(__OSXGLEssentials__texture__) */
