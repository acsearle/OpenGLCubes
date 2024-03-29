#ifndef __MAT_H__
#define __MATRL_H__

// Matrix is a column major floating point array

// All matrices are 4x4 by unless the mtx3x3 prefix is specified in the function name

// [ 0 4  8 12 ]
// [ 1 5  9 13 ]
// [ 2 6 10 14 ]
// [ 3 7 11 15 ]

#import <GLKit/GLKit.h>

#include <vector>

#include "vec.h"

typedef GLKMatrix3 mat3;
typedef GLKMatrix4 mat4;


inline GLKMatrix3 transpose(GLKMatrix3 a) { return GLKMatrix3Transpose(a); }
inline GLKMatrix3 invert(GLKMatrix3 a) { bool b; return GLKMatrix3Invert(a, &b); }
inline GLKMatrix3 invertAndTranspose(GLKMatrix3 a) { bool b; return GLKMatrix3InvertAndTranspose(a, &b); }
inline GLKMatrix3 operator*(GLKMatrix3 a, GLKMatrix3 b) { return GLKMatrix3Multiply(a, b); }
inline GLKMatrix3 operator+(GLKMatrix3 a, GLKMatrix3 b) { return GLKMatrix3Add(a, b); }
inline GLKMatrix3 operator-(GLKMatrix3 a, GLKMatrix3 b) { return GLKMatrix3Add(a, b); }

inline GLKMatrix4 transpose(GLKMatrix4 a) { return GLKMatrix4Transpose(a); }
inline GLKMatrix4 invert(GLKMatrix4 a) { bool b; return GLKMatrix4Invert(a, &b); }
inline GLKMatrix4 invertAndTranspose(GLKMatrix4 a) { bool b; return GLKMatrix4InvertAndTranspose(a, &b); }
inline GLKMatrix4 operator*(GLKMatrix4 a, GLKMatrix4 b) { return GLKMatrix4Multiply(a, b); }
inline GLKMatrix4 operator+(GLKMatrix4 a, GLKMatrix4 b) { return GLKMatrix4Add(a, b); }
inline GLKMatrix4 operator-(GLKMatrix4 a, GLKMatrix4 b) { return GLKMatrix4Add(a, b); }

inline GLKMatrix3& operator*=(GLKMatrix3& a, GLKMatrix3 b) { a = a * b; return a; }
inline GLKMatrix4& operator*=(GLKMatrix4& a, GLKMatrix4 b) { a = a * b; return a; }

// marix vector

inline GLKVector3 operator*(GLKMatrix3 a, GLKVector3 b) { return GLKMatrix3MultiplyVector3(a, b); }
inline GLKVector4 operator*(GLKMatrix4 a, GLKVector4 b) { return GLKMatrix4MultiplyVector4(a, b); }

// irregular

inline GLKVector3 operator*(GLKMatrix4 a, GLKVector3 b) { return GLKMatrix4MultiplyVector3(a, b); }

inline GLKVector3 multiplyWithTranslation(GLKMatrix4 a, GLKVector3 b) {
    return GLKMatrix4MultiplyVector3WithTranslation(a, b);
}

// array

inline void multiplyArray(GLKMatrix3 a, std::vector<vec3>& b) {
    GLKMatrix3MultiplyVector3Array(a, reinterpret_cast<GLKVector3*>(b.data()), b.size());
}

inline void multiplyArray(GLKMatrix4 a, std::vector<vec4>& b) {
    GLKMatrix4MultiplyVector4Array(a, reinterpret_cast<GLKVector4*>(b.data()), b.size());
}

inline void multiplyArray(GLKMatrix4 a, std::vector<vec3>& b) {
    GLKMatrix4MultiplyVector3Array(a, reinterpret_cast<GLKVector3*>(b.data()), b.size());
}

inline void multiplyArrayWithTranslation(GLKMatrix4 a, std::vector<vec3>& b) {
    GLKMatrix4MultiplyVector3ArrayWithTranslation(a, reinterpret_cast<GLKVector3*>(b.data()), b.size());
}



inline GLKMatrix4 translate(vec3 x) {
    return GLKMatrix4MakeTranslation(x[0], x[1], x[2]);
}

inline GLKMatrix4 rotate(float radians, vec3 n) {
    return GLKMatrix4MakeRotation(radians, n[0], n[1], n[2]);
}

inline GLKMatrix4 rotateX(float radians) {
    return GLKMatrix4MakeXRotation(radians);
}

inline GLKMatrix4 rotateY(float radians) {
    return GLKMatrix4MakeYRotation(radians);
}

inline GLKMatrix4 rotateZ(float radians) {
    return GLKMatrix4MakeZRotation(radians);
}

inline GLKMatrix4 scale(vec3 x) {
    return GLKMatrix4MakeScale(x[0], x[1], x[2]);
}

const mat3 identity3 = {
    1.f, 0.f, 0.f,
    0.f, 1.f, 0.f,
    0.f, 0.f, 1.f
};

const mat4 identity4 = {
    1.f, 0.f, 0.f, 0.f,
    0.f, 1.f, 0.f, 0.f,
    0.f, 0.f, 1.f, 0.f,
    0.f, 0.f, 0.f, 1.f
};

#endif //__MAT_H__

