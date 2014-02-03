//
//  vao.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#ifndef __OSXGLEssentials__vao__
#define __OSXGLEssentials__vao__

#import <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include "model.h"

template<typename I> void vbo(GLenum target, GLenum usage, I b, I e) {
    GLuint name;
    glGenBuffers(1, &name);
    glBindBuffer(target, name);
    glBufferData(target, (char*) &*e - (char*) &*b, &*b, usage);
}

struct vao {
    GLuint name;
    explicit vao(model& m);
    ~vao();
};


#endif /* defined(__OSXGLEssentials__vao__) */
