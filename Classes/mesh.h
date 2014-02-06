//
//  model.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#ifndef __OSXGLEssentials__mesh__
#define __OSXGLEssentials__mesh__

#include <iostream>

#include <vector>
#include "vec.h"
#include "mat.h"

class vertex {
public:
    cvec3 position;
    cvec3 normal;
    cvec3 texcoord;
    vertex() {}
    vertex(char x , char y , char z ,
           char nx, char ny, char nz,
           char s , char t , char p )
    : position(x,y,z)
    , normal(nx, ny, nz)
    , texcoord(s,t,p) {
    }
};


template<typename V, typename E> class mesh {
public:
    std::vector<V> vertices;
    std::vector<E> elements;
    
    
    /*
    void append(const mesh& m);
    
    void apply(mat4 a);
    */
    
    
};

std::unique_ptr<mesh<vertex, GLuint>> make_quad();
std::unique_ptr<mesh<vertex, GLuint>> make_screen();

#endif /* defined(__OSXGLEssentials__mesh__) */
