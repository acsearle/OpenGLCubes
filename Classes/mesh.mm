//
//  model.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#include "mesh.h"

using namespace std;

unique_ptr<mesh<vertex, GLuint>> make_quad() {
    unique_ptr<mesh<vertex, GLuint>> m{new mesh<vertex, GLuint>};
    
    vertex v;

    v.normal = cvec3(0, 0, 1); // Constant

    v.position = v.texcoord = cvec3(0, 0, 0);
    m->vertices.push_back(v);
    v.position = v.texcoord = cvec3(1, 0, 0);
    m->vertices.push_back(v);
    v.position = v.texcoord = cvec3(1, 1, 0);
    m->vertices.push_back(v);
    v.position = v.texcoord = cvec3(0, 1, 0);
    m->vertices.push_back(v);

    m->elements.push_back(0);
    m->elements.push_back(2);
    m->elements.push_back(1);
    m->elements.push_back(0);
    m->elements.push_back(3);
    m->elements.push_back(2);
    
    return m;
}


unique_ptr<mesh<vertex, GLuint>> make_screen() {
    unique_ptr<mesh<vertex, GLuint>> m{new mesh<vertex, GLuint>};
    
    vertex v;
    
    v.normal = cvec3(0, 0, 1); // Constant
    
    v.position = cvec3(-1, -1, 0);
    v.texcoord = cvec3(0, 0, 0);
    m->vertices.push_back(v);
    v.position = cvec3(-1, +1, 0);
    v.texcoord = cvec3(0, 1, 0);
    m->vertices.push_back(v);
    v.position = cvec3(+1, +1, 0);
    v.texcoord = cvec3(1, 1, 0);
    m->vertices.push_back(v);
    v.position = cvec3(+1, -1, 0);
    v.texcoord = cvec3(1, 0, 0);
    m->vertices.push_back(v);
    
    m->elements.push_back(0);
    m->elements.push_back(2);
    m->elements.push_back(1);
    m->elements.push_back(0);
    m->elements.push_back(3);
    m->elements.push_back(2);
    
    return m;
}


/*
template<typename V, typename E> void mesh<V, E>::append(const mesh<V, E>& m)
{
    size_t n = vertices.size();
    for (auto e : m.elements)
        elements.push_back(e + n);
    vertices.insert(vertices.end(), m.vertices.begin(), m.vertices.end());
}

template<typename V, typename E> void mesh<V, E>::apply(mat4 a)
{
    mat4 b = invertAndTranspose(a);
    for (V& v : vertices) {
        v.position = multiplyWithTranslation(a, v.position);
        v.normal = b * v.normal;
    }
}
*/
