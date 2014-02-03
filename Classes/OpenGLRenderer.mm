/*
 The OpenGLRenderer class creates and draws objects.
 Most of the code is OS independent.
 */

#import <GLKit/GLKit.h>


#import "OpenGLRenderer.h"
#import "matrixUtil.h"
#import "imageUtil.h"
#import "sourceUtil.h"
#import "vectorUtil.h"


#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#include "model.h"
#include "program.h"
#include "shader.h"
#include "vao.h"

using namespace std;


// Indicies to which we will set vertex array attibutes
// See buildVAO and buildProgram



//@implementation OpenGLRenderer

class program;

class renderer_impl : public renderer
{
public:
    GLuint m_defaultFBOName;
    
    GLuint m_characterPrgName;
    GLuint m_characterVAOName;
    GLuint m_characterTexName;
    GLuint m_characterNumElements;
    GLfloat m_characterAngle;
    GLuint m_deferredFBOName;
    
    GLuint m_viewWidth;
    GLuint m_viewHeight;
    
    virtual void resizeWithWidthAndHeight(GLuint width, GLuint height);
    virtual void render();
    virtual void dealloc();
    void destroyFBO(GLuint fboName);
    void deleteFBOAttachment(GLenum attachment);
    GLuint buildFBOWithWidthAndHeight(GLuint width, GLuint height);
    GLuint buildTexture(demoImage* image);
    program* buildProgram(string* vertexSource, string* fragmentSource);


};











renderer* renderer::initWithDefaultFBO(GLuint defaultFBOName)
{
	//if((self = [super init]))
    renderer_impl* self = new renderer_impl;
	{
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
		
		////////////////////////////////////////////////////
		// Build all of our and setup initial state here  //
		// Don't wait until our real time run loop begins //
		////////////////////////////////////////////////////
		
		self->m_defaultFBOName = defaultFBOName;
		
		self->m_viewWidth = 100;
		self->m_viewHeight = 100;
		
		self->m_characterAngle = 0;
		
		NSString* filePathName = nil;
        
        
        auto m = model::voxel();
        self->m_characterVAOName = (new vao(m))->name;
        self->m_characterNumElements = m.elements.size();
		
        
		
		////////////////////////////////////
		// Load texture for our character //
		////////////////////////////////////
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"demon" ofType:@"png"];
		demoImage *image = imgLoadImage([filePathName cStringUsingEncoding:NSASCIIStringEncoding], false);
		
		// Build a texture object with our image data
		self->m_characterTexName = self->buildTexture(image);
		
		// We can destroy the image once it's loaded into GL
		imgDestroyImage(image);
        
		
		////////////////////////////////////////////////////
		// Load and Setup shaders for character rendering //
		////////////////////////////////////////////////////
		
		//demoSource *vtxSource = NULL;
		//demoSource *frgSource = NULL;
        string vtxSource, frgSource;
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"character" ofType:@"vsh"];
		//vtxSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
        vtxSource = load([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"character" ofType:@"fsh"];
		//frgSource = srcLoadSource([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
        frgSource = load([filePathName cStringUsingEncoding:NSASCIIStringEncoding]);
		
		// Build Program
		self->m_characterPrgName = *(self->buildProgram(&vtxSource,&frgSource));
		
        self->m_deferredFBOName = self->buildFBOWithWidthAndHeight(500, 500);
        
		////////////////////////////////////////////////
		// Set up OpenGL state that will never change //
		////////////////////////////////////////////////
		
		// Depth test will always be enabled
		glEnable(GL_DEPTH_TEST);
        
		// We will always cull back faces for better performance
		glEnable(GL_CULL_FACE);
		
		// Draw our scene once without presenting the rendered image.
		//   This is done in order to pre-warm OpenGL
		// We don't need to present the buffer since we don't actually want the
		//   user to see this, we're only drawing as a pre-warm stage
		self->render();
		
		// Reset the m_characterAngle which is incremented in render
		self->m_characterAngle = 0;
		
		// Check for errors to make sure all of our setup went ok
		GetGLError();
	}
	
	return self;
}






void renderer_impl::resizeWithWidthAndHeight(GLuint width, GLuint height)
{
	glViewport(0, 0, width, height);

	m_viewWidth = width;
	m_viewHeight = height;
}

GLuint smuggle;

void renderer_impl::render() {
    
    mat4 modelView;
    mat4 projection;
    mat4 mvp;
	
	// Use the program for rendering our character
	glUseProgram(m_characterPrgName);
	
	// Calculate the projection matrix
	//mtxLoadPerspective(projection, 90, (float)m_viewWidth / (float)m_viewHeight,5.0,10000);
    projection = GLKMatrix4MakePerspective(45, (float)m_viewWidth / (float)m_viewHeight,1.0,100);
	
	// Calculate the modelview matrix to render our character 
	//  at the proper position and rotation
	//mtxLoadTranslate(modelView, 0, 0, -45);
	modelView = translate(vec3{{0.f, 0.f, -20.f}});
    //mtxRotateXApply(modelView, -90.0f);
    modelView *= rotate(M_PI_2, vec3{{1.f, 0.f, 0.f}});
    //mtxRotateApply(modelView, m_characterAngle, 0.7, 0.3, 1);
    modelView *= rotate(m_characterAngle/57, vec3{{0.7f, 0.3f, 0.1f}});
	
	// Multiply the modelview and projection matrix and set it in the shader
	//mtxMultiply(mvp, projection, modelView);
    mvp = projection * modelView;
    mat4 inverseTransposeModelView = invertAndTranspose(modelView);
	
	// Have our shader use the modelview projection matrix 
	// that we calculated above

    glUniformMatrix4fv(glGetUniformLocation(m_characterPrgName, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    glUniformMatrix4fv(glGetUniformLocation(m_characterPrgName, "projectionMatrix"), 1, GL_FALSE, projection.m);
	glUniformMatrix4fv(glGetUniformLocation(m_characterPrgName, "inverseTransposeModelViewMatrix"), 1, GL_FALSE, inverseTransposeModelView.m);

    glBindFramebuffer(GL_FRAMEBUFFER, m_deferredFBOName);
    glClearColor(1,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0,1,0,0);
    glBindTexture(GL_TEXTURE_2D, m_characterTexName);
    glBindVertexArray(m_characterVAOName);
    glDrawElements(GL_TRIANGLES, m_characterNumElements, GL_UNSIGNED_SHORT, 0);
    
    // Bind our default FBO to render to the screen
	glBindFramebuffer(GL_FRAMEBUFFER, m_defaultFBOName);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //glBindTexture(GL_TEXTURE_2D, m_characterTexName);
    glBindTexture(GL_TEXTURE_2D, smuggle);
    glGenerateMipmap(GL_TEXTURE_2D);
	glBindVertexArray(m_characterVAOName);
    glDrawElements(GL_TRIANGLES, m_characterNumElements, GL_UNSIGNED_SHORT, 0);
    
    
    GetGLError();
	
	// Update the angle so our character keeps spinning
	//m_characterAngle++;
}

static GLsizei GetGLTypeSize(GLenum type)
{
	switch (type) {
		case GL_BYTE:
			return sizeof(GLbyte);
		case GL_UNSIGNED_BYTE:
			return sizeof(GLubyte);
		case GL_SHORT:
			return sizeof(GLshort);
		case GL_UNSIGNED_SHORT:
			return sizeof(GLushort);
		case GL_INT:
			return sizeof(GLint);
		case GL_UNSIGNED_INT:
			return sizeof(GLuint);
		case GL_FLOAT:
			return sizeof(GLfloat);
	}
	return 0;
}


GLuint renderer_impl::buildTexture(demoImage* image)
{
	GLuint texName;
	
	// Create a texture object to apply to model
	glGenTextures(1, &texName);
	glBindTexture(GL_TEXTURE_2D, texName);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Indicate that pixel rows are tightly packed 
	//  (defaults to stride of 4 which is kind of only good for
	//  RGBA or FLOAT data types)
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
	// Allocate and load image data into texture
	glTexImage2D(GL_TEXTURE_2D, 0, image->format, image->width, image->height, 0,
				 image->format, image->type, image->data);

	// Create mipmaps for this texture for better image quality
	glGenerateMipmap(GL_TEXTURE_2D);
	
	GetGLError();
	
	return texName;
}


void renderer_impl::deleteFBOAttachment(GLenum attachment)
{    
    GLint param;
    GLuint objName;
    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment,
        GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, &param);
    glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER, attachment,
        GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, (GLint*) &objName);
    if(GL_RENDERBUFFER == param)
        glDeleteRenderbuffers(1, &objName);
    else if(GL_TEXTURE == param)
        glDeleteTextures(1, &objName);
    
}

void renderer_impl::destroyFBO(GLuint fboName)
{ 
	glBindFramebuffer(GL_FRAMEBUFFER, fboName);
	GLint maxColorAttachments;
    glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColorAttachments);
	GLint colorAttachment;
	for(colorAttachment = 0; colorAttachment < maxColorAttachments; colorAttachment++)
    	deleteFBOAttachment(GL_COLOR_ATTACHMENT0+colorAttachment);
	deleteFBOAttachment(GL_DEPTH_ATTACHMENT);
	deleteFBOAttachment(GL_STENCIL_ATTACHMENT);
	glDeleteFramebuffers(1,&fboName);
}



GLuint renderer_impl::buildFBOWithWidthAndHeight(GLuint width, GLuint height)
{
	GLuint fboName;
	
	GLuint colorTexture, colorTexture2;
	
	// Create a texture object to apply to model
	glGenTextures(1, &colorTexture);
	glBindTexture(GL_TEXTURE_2D, colorTexture);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Allocate a texture image with which we can render to
	// Pass NULL for the data parameter since we don't need to load image data.
	//     We will be generating the image by rendering to this texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
				 width, height, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, NULL);

	// Create a texture object to apply to model
	glGenTextures(1, &colorTexture2);
	glBindTexture(GL_TEXTURE_2D, colorTexture2);
    
    smuggle = colorTexture;
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Allocate a texture image with which we can render to
	// Pass NULL for the data parameter since we don't need to load image data.
	//     We will be generating the image by rendering to this texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
				 width, height, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, NULL);
	
    /*
	GLuint depthRenderbuffer;
	glGenRenderbuffers(1, &depthRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
     */
    
    // Create a texture object to apply to model
    GLuint depthTexture;
	glGenTextures(1, &depthTexture);
	glBindTexture(GL_TEXTURE_2D, depthTexture);
    
    smuggle = depthTexture;
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	
	// Allocate a texture image with which we can render to
	// Pass NULL for the data parameter since we don't need to load image data.
	//     We will be generating the image by rendering to this texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT,
				 width, height, 0,
				 GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT, NULL);
	
	glGenFramebuffers(1, &fboName);
	glBindFramebuffer(GL_FRAMEBUFFER, fboName);	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTexture, 0);
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, colorTexture2, 0);
	//glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthTexture, 0);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		destroyFBO(fboName);
		return 0;
	}
	
	GetGLError();
	
	return fboName;
}

program* renderer_impl::buildProgram(string* vertexSource, string* fragmentSource)
{
	// Determine if GLSL version 140 is supported by this context.
	//  We'll use this info to generate a GLSL shader source string  
	//  with the proper version preprocessor string prepended
	double glLanguageVersion;
	
    glLanguageVersion = atof((char*) glGetString(GL_SHADING_LANGUAGE_VERSION));

	// GL_SHADING_LANGUAGE_VERSION returns the version standard version form
	//  with decimals, but the GLSL version preprocessor directive simply
	//  uses integers (thus 1.10 should 110 and 1.40 should be 140, etc.)
	//  We multiply the floating point number by 100 to get a proper
	//  number for the GLSL preprocessor directive
	GLuint version = round(100 * glLanguageVersion);
		
	stringstream ss;
    ss << "#version " << version << endl;

    shader vs{GL_VERTEX_SHADER, vector<string>{ss.str(), *vertexSource}};
    shader fs{GL_FRAGMENT_SHADER, vector<string>{ss.str(), *fragmentSource}};
    
    program& prgName = *(new program); // explicitly leak it for now
    
    prgName.attach(vs).attach(fs);
    
    prgName.bindAttrib(POS_ATTRIB_IDX, "inPosition");
    prgName.bindAttrib(NORMAL_ATTRIB_IDX, "inNormal");
    prgName.bindAttrib(TEXCOORD_ATTRIB_IDX, "inTexcoord");
    
    prgName.bindFrag(0, "outColor");
    prgName.bindFrag(1, "outNormal");
    
    prgName.link().validate().use();
	
    
	///////////////////////////////////////
	// Setup common program input points //
	///////////////////////////////////////

	
	GLint samplerLoc = glGetUniformLocation(prgName, "diffuseTexture");
	
	// Indicate that the diffuse texture will be bound to texture unit 0
	GLint unit = 0;
	glUniform1i(samplerLoc, unit);
	
	GetGLError();
	
	return &prgName;
	
}


void renderer_impl::dealloc()
{
	
	// Cleanup all OpenGL objects and 
	glDeleteTextures(1, &m_characterTexName);
		
	//[self destroyVAO:m_characterVAOName];

	glDeleteProgram(m_characterPrgName);

	//mdlDestroyModel(m_characterModel);

	
	//[super dealloc];
}


