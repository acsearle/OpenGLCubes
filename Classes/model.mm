//
//  model.cpp
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#include "model.h"


 model model::quad() {
    model m;
    
    m.vertex.push_back(vec3{{0.f, 0.f, 0.f}});
    m.vertex.push_back(vec3{{1.f, 0.f, 0.f}});
    m.vertex.push_back(vec3{{1.f, 1.f, 0.f}});
    m.vertex.push_back(vec3{{0.f, 1.f, 0.f}});
    m.elements.push_back(0);
    m.elements.push_back(2);
    m.elements.push_back(1);
    m.elements.push_back(0);
    m.elements.push_back(3);
    m.elements.push_back(2);
    m.texcoord.push_back(vec2{{0.f, 0.f}});
    m.texcoord.push_back(vec2{{1.f, 0.f}});
    m.texcoord.push_back(vec2{{1.f, 1.f}});
    m.texcoord.push_back(vec2{{0.f, 1.f}});
    m.normal.insert(m.normal.end(), 4, vec3{{0.f, 0.f, 1.f}});
    return m;
}

void model::append(model m)
{
    size_t n = vertex.size();
    for (auto e : m.elements)
        elements.push_back(e + n);
    vertex.insert(vertex.end(), m.vertex.begin(), m.vertex.end());
    texcoord.insert(texcoord.end(), m.texcoord.begin(), m.texcoord.end());
    normal.insert(normal.end(), m.normal.begin(), m.normal.end());
}

void model::apply(mat4 a)
{
    mat4 b = invertAndTranspose(a);
    multiplyWithTranslation(a, &*vertex.begin(), &*vertex.end());
    multiply(b, &*normal.begin(), &*normal.end());
}

 model model::voxel()
{
    model m;
    auto f = [](int x, int y, int z) -> bool {
        /*
         double r = sqrt(x*x+y*y)-8;
         return (r*r + z*z) > 20;
         */
        double z2 = z + (x*x+y*y)/16.0;
        return x*x+y*y+z2*z2*16 > 100;
        
    };
    
    for (int i = -16; i != +16; ++i)
        for (int j = -16; j != +16; ++j)
            for (int k = -16; k != +16; ++k)
            {
                if (f(i,j,k) > f(i,j,k+1)) {
                    model q = quad();
                    q.apply(translate(vec3{{(float)i,(float)j,(float)k}}));
                    m.append(q);
                }
                if (f(i,j,k) < f(i,j,k+1)) {
                    model q = quad();
                    q.apply(rotate(M_PI,vec3{{1.f,1.f,0.f}}));
                    q.apply(translate(vec3{{(float)i,(float)j,(float)k}}));
                    m.append(q);
                }
                
                if (f(i,j,k) < f(i,j+1,k)) {
                    model q = quad();
                    q.apply(rotate(M_PI_2, vec3{{1.f,0.f,0.f}}));
                    q.apply(translate(vec3{{(float)i,(float)j+1,(float)k-1}}));
                    m.append(q);
                }
                if (f(i,j,k) > f(i,j+1,k)) {
                    model q = quad();
                    q.apply(rotate(M_PI,vec3{{1.f,1.f,0.f}}));
                    q.apply(rotate(M_PI_2, vec3{{1.f,0.f,0.f}}));
                    q.apply(translate(vec3{{(float)i,(float)j+1,(float)k-1}}));
                    m.append(q);
                }
                
                if (f(i,j,k) < f(i+1,j,k)) {
                    model q = quad();
                    q.apply(rotate(-M_PI_2, vec3{{0.f,1.f,0.f}}));
                    q.apply(translate(vec3{{(float)i+1,(float)j,(float)k-1}}));
                    m.append(q);
                }
                if (f(i,j,k) > f(i+1,j,k)) {
                    model q = quad();
                    q.apply(rotate(M_PI,vec3{{1.f,1.f,0.f}}));
                    q.apply(rotate(-M_PI_2, vec3{{0.f,1.f,0.f}}));
                    q.apply(translate(vec3{{(float)i+1,(float)j,(float)k-1}}));
                    m.append(q);
                }
                
                
            }
    return m;
}

