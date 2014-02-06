//
//  vao.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//
#include "glUtil.h"
#include "vao.h"
#include "renderer.h"

using namespace std;



vao::vao(const mesh<vertex, GLuint>& m) : count_(m.elements.size()), type_(GL_UNSIGNED_INT) {
    glGenVertexArrays(1, &name_);
    bind();
    
    attrib.push_back(shared_ptr<vbo>{new vbo{GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.vertices}});
    
    glEnableVertexAttribArray(POS_ATTRIB_IDX);
    glVertexAttribPointer(POS_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), BUFFER_OFFSET(0));
    
    glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
    glVertexAttribPointer(NORMAL_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), BUFFER_OFFSET(3));
    
    glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
    glVertexAttribPointer(TEXCOORD_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), BUFFER_OFFSET(6));
    
    elemen = shared_ptr<vbo>{new vbo{GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, m.elements}};
    
    GetGLError();
}

vao::~vao() {
    glDeleteVertexArrays(1, &name_);
    GetGLError();
}

vao& vao::bind() {
    glBindVertexArray(name_);
    return *this;
}

vao& vao::draw() {
    glDrawElements(GL_TRIANGLES, count_, GL_UNSIGNED_INT, 0);
    return *this;
}