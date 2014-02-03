

#ifndef __VECTOR_UTIL_H__
#define __VECTOR_UTIL_H__

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

/*

// Subtracts one 4D vector to another
void vec4Add(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector from another
void vec4Subtract(float* vec, const float* lhs, const float* rhs);

// Multiplys one 4D vector by another
void vec4Multiply(float* vec, const float* lhs, const float* rhs);

// Divides one 4D vector by another
void vec4Divide(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector to another
void vec3Add(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector from another
void vec3Subtract(float* vec, const float* lhs, const float* rhs);

// Multiplys one 4D vector by another
void vec3Multiply(float* vec, const float* lhs, const float* rhs);

// Divides one 4D vector by another
void vec3Divide(float* vec, const float* lhs, const float* rhs);

// Calculates the Cross Product of a 3D vector
void vec3CrossProduct(float* vec, const float* lhs, const float* rhs);

// Normalizes a 3D vector
void vec3Normalize(float* vec, const float* src);

// Returns the Dot Product of 2 3D vectors
float vec3DotProduct(const float* lhs, const float* rhs);

// Returns the Dot Product of 2 4D vectors
float vec4DotProduct(const float* lhs, const float* rhs);

// Returns the length of a 3D vector 
// (i.e the distance of a point from the origin)
float vec3Length(const float* vec);

// Returns the distance between two 3D points
float vec3Distance(const float* pointA, const float* pointB);
*/

#endif //__VECTOR_UTIL_H__
