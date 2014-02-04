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
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "framebuffer.h"
#include "model.h"
#include "program.h"
#include "shader.h"
#include "texture.h"
#include "vao.h"

using namespace std;


// Indicies to which we will set vertex array attibutes
// See buildVAO and buildProgram



//@implementation OpenGLRenderer


class renderer_impl : public renderer
{
public:
    GLuint m_defaultFBOName;
    
    shared_ptr<program> m_characterPrg;
    unique_ptr<vao> m_characterVAO;
    shared_ptr<texture2d> m_characterTex;
    GLfloat m_characterAngle;
    unique_ptr<framebuffer> m_deferredFBO;
    unique_ptr<vao> m_quadVAO;
    
    GLuint m_viewWidth;
    GLuint m_viewHeight;
    
    virtual void resizeWithWidthAndHeight(GLuint width, GLuint height);
    virtual void render();

    void destroyFBO(GLuint fboName);
    void deleteFBOAttachment(GLenum attachment);
    unique_ptr<framebuffer> buildFBOWithWidthAndHeight(GLuint width, GLuint height);
    unique_ptr<texture2d> buildTexture(demoImage* image);
    
    unique_ptr<program> buildProgramFromFile(string);


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
        self->m_characterVAO = unique_ptr<vao>(new vao(m));
        
        auto n = model::quad();
        self->m_quadVAO = unique_ptr<vao>(new vao(n));
        
		
		
		////////////////////////////////////
		// Load texture for our character //
		////////////////////////////////////
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"demon" ofType:@"png"];
		demoImage *image = imgLoadImage([filePathName cStringUsingEncoding:NSASCIIStringEncoding], false);
		
		// Build a texture object with our image data
		self->m_characterTex = self->buildTexture(image);
		
		// We can destroy the image once it's loaded into GL
		imgDestroyImage(image);
        
		
		////////////////////////////////////////////////////
		// Load and Setup shaders for character rendering //
		////////////////////////////////////////////////////
		
		//demoSource *vtxSource = NULL;
		//demoSource *frgSource = NULL;
        string vtxSource, frgSource;
		
		// Build Program
		self->m_characterPrg = self->buildProgramFromFile("deferred");
		
        self->m_deferredFBO = self->buildFBOWithWidthAndHeight(100, 100);
        
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
    
    // rebuild the backing render target
    m_deferredFBO = buildFBOWithWidthAndHeight(width, height);
    
}



void renderer_impl::render() {
    
    mat4 modelView;
    mat4 projection;
    mat4 mvp;
	
	// Use the program for rendering our character
	m_characterPrg->use();
	
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

	
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "projectionMatrix"), 1, GL_FALSE, projection.m);
	glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "inverseTransposeModelViewMatrix"), 1, GL_FALSE, inverseTransposeModelView.m);

    //glBindFramebuffer(GL_FRAMEBUFFER, m_deferredFBO);
    m_deferredFBO->bind();
    glClearColor(0,0,1,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0,1,0,0);
    glBindTexture(GL_TEXTURE_2D, *m_characterTex);
    glBindVertexArray(*m_characterVAO);
    GLenum bufs[] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2 };
    glDrawBuffers(3, bufs);
    m_characterVAO->draw();
    
    // Bind our default FBO to render to the screen
	glBindFramebuffer(GL_FRAMEBUFFER, m_defaultFBOName);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Draw quads textured with the other framebuffer's attachments
    m_deferredFBO->color_attachment[0]->bind();
    modelView = translate(vec3{{0.f, 1.f, -3.f}}) * rotateX(M_PI);
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    m_quadVAO->bind().draw();

    m_deferredFBO->color_attachment[1]->bind();
    modelView = translate(vec3{{-1.f, 1.f, -3.f}}) * rotateX(M_PI);
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    m_quadVAO->bind().draw();
    
    m_deferredFBO->color_attachment[2]->bind();
    modelView = translate(vec3{{0.f, -0.f, -3.f}}) * rotateX(M_PI);
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    m_quadVAO->bind().draw();
    
    m_deferredFBO->depth_attachment->bind();
    modelView = translate(vec3{{-1.f, -0.f, -3.f}}) * rotateX(M_PI);
    glUniformMatrix4fv(glGetUniformLocation(*m_characterPrg, "modelViewMatrix"), 1, GL_FALSE, modelView.m);
    m_quadVAO->bind().draw();
    
    
    GetGLError();
	
	// Update the angle so our character keeps spinning
	m_characterAngle++;
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


unique_ptr<texture2d> renderer_impl::buildTexture(demoImage* image)
{
    auto texName = unique_ptr<texture2d>{new texture2d{image->width, image->height, image->format, image->type}};
	/*GLuint texName;
	
	// Create a texture object to apply to model
	glGenTextures(1, &texName);
	glBindTexture(GL_TEXTURE_2D, texName);
	
	// Set up filter and wrap modes for this texture object
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	*/
	// Indicate that pixel rows are tightly packed 
	//  (defaults to stride of 4 which is kind of only good for
	//  RGBA or FLOAT data types)
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	
	// Allocate and load image data into texture
	glTexImage2D(GL_TEXTURE_2D, 0, image->format, image->width, image->height, 0,
				 image->format, image->type, image->data);

	// Create mipmaps for this texture for better image quality
	//glGenerateMipmap(GL_TEXTURE_2D);
    texName->generateMipmap();
	
	GetGLError();
	
	return texName;
}


unique_ptr<framebuffer> renderer_impl::buildFBOWithWidthAndHeight(GLuint width, GLuint height)
{

    auto c1 = unique_ptr<texture2d>(new texture2d(width, height, GL_RGBA, GL_UNSIGNED_BYTE));
    auto c2 = unique_ptr<texture2d>(new texture2d(width, height, GL_RGBA, GL_UNSIGNED_BYTE));
    auto c3 = unique_ptr<texture2d>(new texture2d(width, height, GL_RGBA, GL_UNSIGNED_BYTE));
    auto d1 = unique_ptr<texture2d>(new texture2d(width, height, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT));
	   
    auto fboName = unique_ptr<framebuffer>(new framebuffer());
    fboName->bind()
        .attach_color(0, std::move(c1))
        .attach_color(1, std::move(c2))
        .attach_color(2, std::move(c3))
        .attach_depth(std::move(d1));
    
	
	GetGLError();
	
	return fboName;
}



unique_ptr<program> renderer_impl::buildProgramFromFile(string s) {
    NSString* filePathName = [[NSBundle mainBundle]
                              pathForResource:[NSString
                                               stringWithUTF8String:s.c_str()]
                              ofType:@"vsh"];
    string vertexSource = load([filePathName UTF8String]);
    filePathName = [[NSBundle mainBundle]
                    pathForResource:[NSString
                                     stringWithUTF8String:s.c_str()]
                    ofType:@"fsh"];
    string fragmentSource = load([filePathName UTF8String]);

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

    shader vs{GL_VERTEX_SHADER, vector<string>{ss.str(), vertexSource}};
    shader fs{GL_FRAGMENT_SHADER, vector<string>{ss.str(), fragmentSource}};
    
    unique_ptr<program> prgName{new program};
    
    prgName->attach(vs).attach(fs);
    
    prgName->bindAttrib(POS_ATTRIB_IDX, "inPosition")
        .bindAttrib(NORMAL_ATTRIB_IDX, "inNormal")
        .bindAttrib(TEXCOORD_ATTRIB_IDX, "inTexcoord")
        .bindFrag(0, "outColor")
        .bindFrag(1, "outPosition")
        .bindFrag(2, "outNormal");
    
    prgName->link().validate().use();
	
    
	///////////////////////////////////////
	// Setup common program input points //
	///////////////////////////////////////

	
	GLint samplerLoc = glGetUniformLocation(*prgName, "diffuseTexture");
	
	// Indicate that the diffuse texture will be bound to texture unit 0
	GLint unit = 0;
	glUniform1i(samplerLoc, unit);
	
	GetGLError();
	
	return prgName;
	
}


