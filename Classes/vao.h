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
#include <vector>

#include "mesh.h"
#include "named.h"

#define BUFFER_OFFSET(i) ((char *)nullptr + (i))


enum {
	POS_ATTRIB_IDX,
	NORMAL_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX
};



class vbo : public named
{
public:
    template<typename I> vbo(GLenum target, GLenum usage, I b, I e) {
        glGenBuffers(1, &name_);
        glBindBuffer(target, name_);
        glBufferData(target, (char*) &*e - (char*) &*b, &*b, usage);
    }
    template<typename T> vbo(GLenum target, GLenum usage, const std::vector<T>& x) {
        glGenBuffers(1, &name_);
        glBindBuffer(target, name_);
        glBufferData(target, x.size() * sizeof(T), x.data(), usage);
    }
    ~vbo() {
        glDeleteBuffers(1, &name_);
    }
};

class vao : public named {
public:
    explicit vao(const mesh<vertex, GLuint>& m);
    
    vao& bind();
    ~vao();
    vao& draw();
private:
    GLsizei count_;
    GLenum type_;
    std::vector<std::shared_ptr<vbo>> attrib;
    std::shared_ptr<vbo> elemen;
};



#endif /* defined(__OSXGLEssentials__vao__) */
