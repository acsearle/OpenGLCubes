

#include "glUtil.h"
#import <Foundation/Foundation.h>

enum {
	POS_ATTRIB_IDX,
	NORMAL_ATTRIB_IDX,
	TEXCOORD_ATTRIB_IDX
};


#define BUFFER_OFFSET(i) ((char *)nullptr + (i))

class renderer {
public:
    virtual ~renderer() {}
    static renderer* initWithDefaultFBO(GLuint defaultFBOName);
    virtual void resizeWithWidthAndHeight(GLuint width, GLuint height) = 0;
    virtual void render() = 0;
    virtual void dealloc() = 0;
};

