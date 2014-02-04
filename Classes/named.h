//
//  named.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/3/14.
//
//

#ifndef OSXGLEssentials_named_h
#define OSXGLEssentials_named_h

#import <OpenGL/OpenGL.h>

class named
{
public:
    named() : name_(0) {} // required to support glGenX(&name_)-style initialization
    explicit named(GLuint name) : name_(name) {}
    virtual ~named() = 0; // pure virtual as there is no generic way to delete a name
    operator GLuint() const { return name_; }
    // bool and unimplemented pointer conversions for safety?
protected:
    GLuint name_;
private:
    named(const named&);
    named& operator=(const named&);
};

inline named::~named() {}


#endif
