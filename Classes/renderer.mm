/*
 The OpenGLRenderer class creates and draws objects.
 Most of the code is OS independent.
 */

#import <GLKit/GLKit.h>


#import "renderer.h"
#import "mat.h"
#import "imageUtil.h"
#import "source.h"
#import "vec.h"


#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "framebuffer.h"
#include "mesh.h"
#include "program.h"
#include "shader.h"
#include "texture.h"
#include "vao.h"


using namespace std;


class entity {
public:
    mat4 model;
    entity() : model(identity4) {}
    explicit entity(mat4 model) : model(model) {}
    virtual void draw(program& p, mat4 view) = 0;
};

class leaf : public entity {
public:
    shared_ptr<vao> vao_;
    shared_ptr<texture2d> tex_;
    virtual void draw(program& p, mat4 view)
    {
        p["modelViewMatrix"] = view * model;
        p["inverseTransposeModelViewMatrix"] = invertAndTranspose(view * model);
        tex_->bind();
        vao_->bind().draw();
    }
};

class spotlight : public entity {
};

class group : public entity {
public:
    virtual void draw(program& p, mat4 view)
    {
        for (auto q : entities)
            q->draw(p, view * model);
    }
    vector<shared_ptr<entity>> entities;
};

class camera : public entity {
public:
    void draw(program& p, mat4 view) {
        p["projectionMatrix"] = model * view;
    }
};




class renderer_impl : public renderer
{
public:
    GLuint m_defaultFBOName;
    
    shared_ptr<program> m_characterPrg;
    //unique_ptr<vao> m_characterVAO;
    //shared_ptr<texture2d> m_characterTex;
    
    shared_ptr<entity> m_camera;
    shared_ptr<entity> m_character;
    shared_ptr<entity> m_display;
    
    vector<shared_ptr<leaf>> m_displays;
    
    GLfloat m_characterAngle;
    unique_ptr<framebuffer> m_deferredFBO;
    //unique_ptr<vao> m_quadVAO;
    
    GLuint m_viewWidth;
    GLuint m_viewHeight;
    bool m_resized; // We have to wait to implement resize on the rendering thread
    
    explicit renderer_impl(GLuint defaultFBOName);
    
    virtual void resizeWithWidthAndHeight(GLuint width, GLuint height);
    virtual void render();

    void destroyFBO(GLuint fboName);
    void deleteFBOAttachment(GLenum attachment);
    unique_ptr<framebuffer> buildFBOWithWidthAndHeight(GLuint width, GLuint height);
    unique_ptr<texture2d> buildTexture(demoImage* image);
    
    unique_ptr<program> buildProgramFromFile(string);

    
};











unique_ptr<renderer> renderer::initWithDefaultFBO(GLuint defaultFBOName)
{
    return unique_ptr<renderer>(new renderer_impl(defaultFBOName));
}

    renderer_impl::renderer_impl(GLuint defaultFBOName)
	{
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
		
    
        
		////////////////////////////////////////////////////
		// Build all of our and setup initial state here  //
		// Don't wait until our real time run loop begins //
		////////////////////////////////////////////////////
		
		m_defaultFBOName = defaultFBOName;
		
		m_viewWidth = 100;
		m_viewHeight = 100;
		
		m_characterAngle = 0;
        
		NSString* filePathName = nil;
        
        auto x = make_shared<leaf>();
        m_character = x;
        
        auto m = mesh::voxel();
        //self->m_characterVAO = unique_ptr<vao>(new vao(m));
        x->vao_ = make_shared<vao>(m);
        
        
		m_camera = make_shared<camera>();
		
		////////////////////////////////////
		// Load texture for our character //
		////////////////////////////////////
		
		filePathName = [[NSBundle mainBundle] pathForResource:@"demon" ofType:@"png"];
		demoImage *image = imgLoadImage([filePathName cStringUsingEncoding:NSASCIIStringEncoding], false);
		
		// Build a texture object with our image data
		//self->m_characterTex = self->buildTexture(image);
        shared_ptr<texture2d> demonTexture = buildTexture(image);
        x->tex_ = demonTexture;
		
		// We can destroy the image once it's loaded into GL
		imgDestroyImage(image);
        
        
        
        
		
		////////////////////////////////////////////////////
		// Load and Setup shaders for character rendering //
		////////////////////////////////////////////////////
		
		//demoSource *vtxSource = NULL;
		//demoSource *frgSource = NULL;
        string vtxSource, frgSource;
		
		// Build Program
		m_characterPrg = buildProgramFromFile("deferred");
		
        m_deferredFBO = buildFBOWithWidthAndHeight(100, 100);

        auto a = make_shared<group>();
        auto c = make_shared<vao>(mesh::quad());
        for (int x = 0; x != 2; ++x)
            for (int y = 0; y != 2; ++y) {
                auto d = make_shared<leaf>();
                d->vao_ = c;
                d->model = translate(vec3({{(float) x, (float) y, 0.f}}));
                m_displays.push_back(d);
                a->entities.push_back(d);
            }
        m_display = a;
        
        
        
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
		//self->render();
		
		// Reset the m_characterAngle which is incremented in render
		m_characterAngle = 0;
		
		// Check for errors to make sure all of our setup went ok
		GetGLError();
        
 
	}





void renderer_impl::resizeWithWidthAndHeight(GLuint width, GLuint height) {
	glViewport(0, 0, width, height);

	m_viewWidth = width;
	m_viewHeight = height;
    
    //m_deferredFBO = buildFBOWithWidthAndHeight(m_viewWidth, m_viewHeight);
    m_deferredFBO->resize(width, height);
    m_camera->model = GLKMatrix4MakePerspective(45, (float)m_viewWidth / (float)m_viewHeight,1.0,100);
}



void renderer_impl::render() {
    mat4 view;
    
       
	
	// Use the program for rendering our character
	m_characterPrg->use();
		
    
    view = translate(vec3{{0.f, 0.f, -20.f}}) * rotate(M_PI_2, vec3{{1.f, 0.f, 0.f}});
    m_camera->draw(*m_characterPrg, identity4);

    
    
    m_character->model = rotate(m_characterAngle/57, vec3{{0.7f, 0.3f, 0.1f}});
    
    m_deferredFBO->bind();

    GLenum bufs[] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2 };
    glDrawBuffers(3, bufs);

    glClearColor(0,0,1,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    m_character->draw(*m_characterPrg, view);
    
    // Bind our default FBO to render to the screen
	glBindFramebuffer(GL_FRAMEBUFFER, m_defaultFBOName);
    glClearColor(0,1,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //m_display->draw(*m_characterPrg, translate(vec3{{0.f,0.f,-3.f}}) * rotateX(M_PI));
    //m_character->draw(*m_characterPrg, view);
    
    m_displays[0]->tex_ = m_deferredFBO->color_attachment[0];
    m_displays[1]->tex_ = m_deferredFBO->color_attachment[1];
    m_displays[2]->tex_ = m_deferredFBO->color_attachment[2];
    m_displays[3]->tex_ = m_deferredFBO->depth_attachment;
    
    m_display->draw(*m_characterPrg, translate(vec3{{1.f,-1.f,-3.f}}) * rotateY(M_PI));
    
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


