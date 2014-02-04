//
//  vao.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//
#include "glUtil.h"
#include "vao.h"
#include "OpenGLRenderer.h"

using namespace std;

vao::vao(model& m) : count_(m.elements.size()) {
    
    
    glGenVertexArrays(1, &name_);
    bind();
    
    buffers_.push_back(unique_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.vertex.begin(), m.vertex.end())));
    glEnableVertexAttribArray(POS_ATTRIB_IDX);
    glVertexAttribPointer(POS_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
    
    
    buffers_.push_back(unique_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.normal.begin(), m.normal.end())));
    glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
    glVertexAttribPointer(NORMAL_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
    
    
    buffers_.push_back(unique_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.texcoord.begin(), m.texcoord.end())));
    glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
    glVertexAttribPointer(TEXCOORD_ATTRIB_IDX, 2, GL_FLOAT, GL_FALSE, sizeof(vec2), BUFFER_OFFSET(0));
    
    buffers_.push_back(unique_ptr<vbo>(new vbo(GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, m.elements.begin(), m.elements.end())));
    
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
    glDrawElements(GL_TRIANGLES, count_, GL_UNSIGNED_SHORT, 0);
    return *this;
}