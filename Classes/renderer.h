

#include "glUtil.h"
#import <Foundation/Foundation.h>

#include <memory>




class renderer {
public:
    static std::unique_ptr<renderer> factory();
    virtual ~renderer() = 0;
    virtual void resize(GLuint width, GLuint height) = 0;
    virtual void render() = 0;

};


