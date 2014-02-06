#ifndef __VEC_H__
#define __VEC_H__

#include <GLKit/GLKit.h>

#include <array>

template<typename T, std::size_t N> class TvecN;

template<typename T> class TvecN<T, 2> {
public:
    union {
        T data_[2];
        struct { T x, y; };
        struct { T r, g; };
        struct { T s, t; };
    };
    TvecN() {}
    TvecN(T x, T y) : x(x), y(y) {}
    T& operator[](size_t i) { return data_[i]; }
    const T& operator[](size_t i) const { return data_[i]; }
};

template<typename T> class TvecN<T, 3> {
public:
    union {
        T data_[3];
        struct { T x, y, z; };
        struct { T r, g, b; };
        struct { T s, t, p; };
        
    };
    TvecN() {}
    TvecN(T x, T y, T z) : x(x), y(y), z(z) {}
    T& operator[](size_t i) { return data_[i]; }
    const T& operator[](size_t i) const { return data_[i]; }
};

template<typename T> class TvecN<T, 4> {
public:
    union {
        T data_[4];
        struct { T x, y, z, w; };
        struct { T r, g, b, a; };
        struct { T s, t, p, q; };
    };
    TvecN() {}
    TvecN(T x, T y, T z, T w) : x(x), y(y), z(z), w(w) {}
    T& operator[](size_t i) { return data_[i]; }
    const T& operator[](size_t i) const { return data_[i]; }
};

template<typename T, std::size_t N> T dot(TvecN<T, N> a, TvecN<T, N> b) {
    T c{};
    for (std::size_t i = 0; i != N; ++i)
        c += a[i] * b[i];
    return c;
}

template<typename T> TvecN<T, 3> cross(TvecN<T, 3> a, TvecN<T, 3> b) {
    return TvecN<T, 3>{
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x
    };
}

typedef TvecN<float, 2> vec2;
typedef TvecN<float, 3> vec3;
typedef TvecN<float, 4> vec4;

typedef TvecN<int, 2> ivec2;
typedef TvecN<int, 3> ivec3;
typedef TvecN<int, 4> ivec4;

typedef TvecN<char, 2> cvec2;
typedef TvecN<char, 3> cvec3;
typedef TvecN<char, 4> cvec4;


#endif // __VEC_H__
