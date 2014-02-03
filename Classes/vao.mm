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

vao::vao(model& m) {
        
        
        // Create a vertex array object (VAO) to cache model parameters
        glGenVertexArrays(1, &name);
        glBindVertexArray(name);
        
        vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.vertex.begin(), m.vertex.end());
        glEnableVertexAttribArray(POS_ATTRIB_IDX);
        glVertexAttribPointer(POS_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
        
        
        vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.normal.begin(), m.normal.end());
        glEnableVertexAttribArray(NORMAL_ATTRIB_IDX);
        glVertexAttribPointer(NORMAL_ATTRIB_IDX, 3, GL_FLOAT, GL_FALSE, sizeof(vec3), BUFFER_OFFSET(0));
        
        
        vbo(GL_ARRAY_BUFFER, GL_STATIC_DRAW, m.texcoord.begin(), m.texcoord.end());
        glEnableVertexAttribArray(TEXCOORD_ATTRIB_IDX);
        glVertexAttribPointer(TEXCOORD_ATTRIB_IDX, 2, GL_FLOAT, GL_FALSE, sizeof(vec2), BUFFER_OFFSET(0));
        
        vbo(GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW, m.elements.begin(), m.elements.end());
        
        GetGLError();
        
        
    }
    vao::~vao() {
        glBindVertexArray(name);
        GLuint bufName;
        GLint maxVertexAttribs;
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &maxVertexAttribs);
        for(GLuint index = 0; index < maxVertexAttribs; index++)
        {
            glGetVertexAttribiv(index, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING, (GLint*) &bufName);
            if(bufName)
                glDeleteBuffers(1, &bufName);
        }
        glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, (GLint*) &bufName);
        if(bufName)
            glDeleteBuffers(1, &bufName);
        glDeleteVertexArrays(1, &name);
        GetGLError();
    }