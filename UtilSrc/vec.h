#ifndef __VEC_H__
#define __VEC_H__

#include <OpenGL/OpenGL.h>
#include <OpenGL/gl3.h>
#include <GLKit/GLKit.h>

typedef GLKVector2 vec2;
typedef GLKVector3 vec3;
typedef GLKVector4 vec4;

#define VNIO(N, F, S) \
inline GLKVector##N operator F (GLKVector##N a, GLKVector##N b) { \
return GLKVector##N##S (a, b); \
} \
inline GLKVector##N operator F(GLKVector##N a, float b) { \
    return GLKVector##N##S##Scalar(a, b); \
}\
inline GLKVector##N operator F##= (GLKVector##N& a, GLKVector##N b) { \
    a = a F b; \
    return a; \
} \
inline GLKVector##N operator F##= (GLKVector##N& a, float b) { \
    a = a F b; \
    return a; \
}



#define VN(N) \
VNIO(N, +, Add) \
VNIO(N, -, Subtract) \
VNIO(N, *, Multiply) \
VNIO(N, /, Divide)

VN(2)
VN(3)
VN(4)



#endif // __VEC_H__
