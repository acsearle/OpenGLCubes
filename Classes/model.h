//
//  model.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/2/14.
//
//

#ifndef __OSXGLEssentials__model__
#define __OSXGLEssentials__model__

#include <iostream>

#include <vector>
#include "vectorUtil.h"
#include "matrixUtil.h"


class model {
public:
    std::vector<vec3> vertex;
    std::vector<vec3> normal;
    std::vector<vec2> texcoord;
    std::vector<GLshort> elements;
    
    static model quad();
    
    void append(model m);
    
    void apply(mat4 a);
    
    
    
    static model voxel();
};



#endif /* defined(__OSXGLEssentials__model__) */
