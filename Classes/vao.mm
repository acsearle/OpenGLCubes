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

vao::vao(const mesh& m) : count_(m.elements.size()) {
    glGenVertexArrays(1, &name_);
    bind();

    GLuint maxVertexAttribs;
    glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, (GLint*) &maxVertexAttribs);
    attrib.resize(maxVertexAttribs);
    
    attrib[POS_ATTRIB_IDX] = shared_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.vertex.begin(), m.vertex.end()));
    glEnableVertexAttribArray(POS_ATTRIB_IDX);
    glVertexAttribPointer(POS_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
    
    
    attrib[NORMAL_ATTRIB_IDX] = shared_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.normal.begin(), m.normal.end()));
    glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
    glVertexAttribPointer(NORMAL_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
    
    
    attrib[TEXCOORD_ATTRIB_IDX] = shared_ptr<vbo>(new vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.texcoord.begin(), m.texcoord.end()));
    glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
    glVertexAttribPointer(TEXCOORD_ATTRIB_IDX, 2, GL_FLOAT, GL_FALSE, sizeof(vec2), BUFFER_OFFSET(0));
    
    elemen = shared_ptr<vbo>(new vbo(GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, m.elements.begin(), m.elements.end()));
    
    GetGLError();
    
    
}


vao::vao(vector<vertex>& v, vector<GLushort>& e) : count_(e.size()) {
    glGenVertexArrays(1, &name_);
    bind();
    
    attrib.push_back(shared_ptr<vbo>{new vbo{GL_ARRAY_BUFFER, GL_STATIC_DRAW, v}});
    
    glEnableVertexAttribArray(POS_ATTRIB_IDX);
    glVertexAttribPointer(POS_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), 0);
    
    glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
    glVertexAttribPointer(NORMAL_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), BUFFER_OFFSET(sizeof(cvec3)));
    
    glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
    glVertexAttribPointer(TEXCOORD_ATTRIB_IDX, 3, GL_BYTE, GL_FALSE, sizeof(vertex), BUFFER_OFFSET(sizeof(cvec3)*2));
    
    elemen = shared_ptr<vbo>{new vbo{GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, e}};
    
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