

#include "glUtil.h"
#import <Foundation/Foundation.h>

#include <memory>
enum {
	POS_ATTRIB_IDX,
	NORMAL_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX
};


#define BUFFER_OFFSET(i) ((char *)nullptr + (i))

class renderer {
public:
    static std::unique_ptr<renderer> factory();
    virtual ~renderer() = 0;
    virtual void resize(GLuint width, GLuint height) = 0;
    virtual void render() = 0;

};


