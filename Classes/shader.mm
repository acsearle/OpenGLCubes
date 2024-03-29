//
//  shader.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#include <OpenGL/gl3.h>
#include "shader.h"

using namespace std;

shader::shader(GLenum type, vector<string> sources) : named(glCreateShader(type)) {
    vector<GLchar*> str;
    vector<GLint> len;
    for (auto& s : sources) {
        str.push_back((GLchar*) s.data());
        len.push_back(s.size());
    }
    glShaderSource(name_, sources.size(), str.data(), len.data());
    glCompileShader(name_);
    
    GLsizei n;
    glGetShaderiv(name_, GL_INFO_LOG_LENGTH, &n);
    if (n > 0)
    {
        string s;
        s.resize(n);
        glGetShaderInfoLog(name_, n, &n, (GLchar*) s.data());
        NSLog(@"Shader compile log:%s\n", s.c_str());
    }
    
    GLint status;
    glGetShaderiv(name_, GL_COMPILE_STATUS, &status);
    if (!status)
    {
        NSLog(@"Failed to compile shader:\n");
        for (auto s : sources)
            NSLog(@"%s", s.c_str());
        NSLog(@"\n");
    }
    
}

shader::~shader() {
    glDeleteShader(name_);
}



