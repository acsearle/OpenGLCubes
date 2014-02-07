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

#import <OpenGL/gl3ext.h>

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
        if (tex_)
            tex_->bind();
        vao_->bind().draw();
    }
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

class camera {
public:
    mat4 view_;
    mat4 projection_;
    camera() : projection_(identity4) {}
    
    void draw(program& p) {
        p["cameraViewMatrix"] = view_;
        p["cameraInverseViewMatrix"] = invert(view_);
        p["cameraProjectionMatrix"] = projection_;
        p["cameraInverseProjectionMatrix"] = invert(projection_);
    }
};

class spotlight {
public:
    mat4 view_;
    mat4 projection_;
    spotlight() : projection_(identity4) {}
    void draw(program& p) {
        p["spotlightViewMatrix"] = view_;
        p["spotlightInverseViewMatrix"] = invert(view_);
        p["spotlightProjectionMatrix"] = projection_;
        p["spotlightInverseProjectionMatrix"] = invert(projection_);
    }
    void drawAsCamera(program& p) {
        p["cameraProjectionMatrix"] = projection_ * view_;
        p["cameraInverseProjectionMatrix"] = invert(projection_ * view_);
    }
};


template<typename T> class voxel {
public:
    ivec3 size_;
    vector<T> data_;

    explicit voxel(ivec3 lmn) : size_(lmn), data_(lmn[0] * lmn[1] * lmn[2], 0) {
    }
    
    T& operator()(ivec3 ijk) {
        return data_[ijk[0] + size_[0] * (ijk[1] + size_[1] * ijk[2])];
    }
    
    T operator()(vec3 v) {
        if (!bounds(v))
            return T{};
        return operator()(ivec3(v.x, v.y, v.z));
    }
    
    bool bounds(vec3 xyz) {
        return ((xyz[0] >= 0)
                && (xyz[1] >= 0)
                && (xyz[2] >= 0)
                && (xyz[0] < size_[0])
                && (xyz[1] < size_[1])
                && (xyz[2] < size_[2]));
    }
    
    T& get(size_t i, size_t j, size_t k) {
        return data_[i + size_[0] * (j + size_[1] * k)];
    }
    
    shared_ptr<vao> makeVAO() {
        mesh<vertex, GLuint> m;
        auto test = [](T t) { return t; };
        for (size_t k = 0; k != size_[2]; ++k)
            for (size_t j = 0; j != size_[1]; ++j)
                for (size_t i = 0; i != size_[0]; ++i) {
                    T a = operator()(ivec3{i, j, k});
                    if (test(a)) {
                        T b;
                        
                        if ((i == 0) || !test(b = get(i-1,j,k))) {
                            m.vertices.push_back(vertex(i,j,k, -1,0,0, 0,0,a));
                            m.vertices.push_back(vertex(i,j,k+1, -1,0,0, 1,0,a));
                            m.vertices.push_back(vertex(i,j+1,k+1, -1,0,0, 1,1,a));
                            m.vertices.push_back(vertex(i,j+1,k, -1,0,0, 0,1,a));
                        }
                        if ((i+1 == size_[0]) || !test(b = get(i+1,j,k))) {
                            m.vertices.push_back(vertex(i+1,j,k, 1,0,0, 0,0,a));
                            m.vertices.push_back(vertex(i+1,j+1,k, 1,0,0, 0,1,a));
                            m.vertices.push_back(vertex(i+1,j+1,k+1, 1,0,0, 1,1,a));
                            m.vertices.push_back(vertex(i+1,j,k+1, 1,0,0, 1,0,a));
                        }
                        if ((j == 0) || !test(b = get(i,j-1,k))) {
                            m.vertices.push_back(vertex(i,j,k, 0,-1,0, 0,0,a));
                            m.vertices.push_back(vertex(i+1,j,k, 0,-1,0, 1,0,a));
                            m.vertices.push_back(vertex(i+1,j,k+1, 0,-1,0, 1,1,a));
                            m.vertices.push_back(vertex(i,j,k+1, 0,-1,0, 0,1,a));
                        }
                        if ((j+1 == size_[1]) || !test(b = get(i,j+1,k))) {
                            m.vertices.push_back(vertex(i,j+1,k, 0,+1,0, 0,0,a));
                            m.vertices.push_back(vertex(i,j+1,k+1, 0,+1,0, 0,1,a));
                            m.vertices.push_back(vertex(i+1,j+1,k+1, 0,+1,0, 1,1,a));
                            m.vertices.push_back(vertex(i+1,j+1,k, 0,+1,0, 1,0,a));
                        }
                        
                        if ((k == 0) || !test(b = get(i,j,k-1))) {
                            m.vertices.push_back(vertex(i,j,k, 0,0,-1, 0,0,a));
                            m.vertices.push_back(vertex(i,j+1,k, 0,0,-1, 0,1,a));
                            m.vertices.push_back(vertex(i+1,j+1,k, 0,0,-1, 1,1,a));
                            m.vertices.push_back(vertex(i+1,j,k, 0,0,-1, 1,0,a));
                        }
                        if ((k+1 == size_[2]) || !test(b = get(i,j,k+1))) {
                            m.vertices.push_back(vertex(i,j,k+1, 0,0,1, 0,0,a));
                            m.vertices.push_back(vertex(i+1,j,k+1, 0,0,1, 0,1,a));
                            m.vertices.push_back(vertex(i+1,j+1,k+1, 0,0,1, 1,1,a));
                            m.vertices.push_back(vertex(i,j+1,k+1, 0,0,1, 1,0,a));
                        }
                        
                    }
                }
        for (GLushort i = 0; i != m.vertices.size(); i += 4) {
            m.elements.push_back(i); m.elements.push_back(i + 1); m.elements.push_back(i + 2);
            m.elements.push_back(i); m.elements.push_back(i + 2); m.elements.push_back(i + 3);
        }
        
        return shared_ptr<vao>{new vao{m}};
        
    }
    
    // where do vertex array objects and buffers live?
    
};

class interval
{
public:
    explicit interval(float x) : a_(x), b_(x) {}
    
    void hull(float x) {
        if (x < a_)
            a_ = x;
        if (x > b_)
            b_ = x;
    }
    bool overlap(interval x) {
        return (a_ > x.b_) || (b_ < x.a_);
    }
private:
    float a_, b_;
};


bool separating_axis(mat4 b_transform) {
    // cube ([0,0,0],[1,1,1])
    // cube A ([0,0,0],[1,1,1])
    
    // candidate axes are
    
    vec3 a_vertices[] = {
        vec3(0,0,0),
        vec3(0,0,1),
        vec3(0,1,0),
        vec3(0,1,1),
        vec3(1,0,0),
        vec3(1,0,1),
        vec3(1,1,0),
        vec3(1,1,1)
    };
    
    vec3 a_normals[] = {
        vec3(0,0,1),
        vec3(0,1,0),
        vec3(1,0,0)
    };
    
    vec3 b_vertices[8];
    vec3 b_normals[8];
    std::copy(a_vertices, a_vertices + 8, b_vertices);
    std::copy(a_normals, a_normals + 3, b_normals);

    GLKMatrix4MultiplyVector3ArrayWithTranslation(b_transform, (GLKVector3*) b_vertices, 8);
    GLKMatrix4MultiplyVector3Array(b_transform, (GLKVector3*) b_normals, 3);
    
    
    auto is_separating_axis = [&](vec3 axis) {
        interval a{dot(a_vertices[0], axis)};
        interval b{dot(b_vertices[0], axis)};
        for (size_t i = 1; i != 8; ++i) {
            a.hull(dot(a_vertices[i], axis));
            b.hull(dot(a_vertices[i], axis));
        }
        return !a.overlap(b);
    };

    for (auto a : a_normals)
        if (is_separating_axis(a))
            return false;
    for (auto b : b_normals)
        if (is_separating_axis(b))
            return false;
    for (auto a : a_normals)
        for (auto b : b_normals)
            if (is_separating_axis(cross(a, b)))
                return false;
    return true;
}


class renderer_impl : public renderer
{
public:
    GLuint m_defaultFBOName;
    
    shared_ptr<program> m_characterPrg;
    shared_ptr<program> m_lightingPrg;
    
    shared_ptr<camera> m_camera;
    shared_ptr<entity> m_character;
    shared_ptr<leaf> m_screen;
    
    shared_ptr<texture2d> m_texture;
    
    GLfloat m_characterAngle;
    unique_ptr<framebuffer> m_deferredFBO;
    unique_ptr<framebuffer> m_shadowFBO;
    
    GLuint m_viewWidth;
    GLuint m_viewHeight;
    bool m_resized; // We have to wait to implement resize on the rendering thread
    
    explicit renderer_impl();
    
    virtual void resize(GLuint width, GLuint height);
    virtual void render();

    unique_ptr<framebuffer> buildFBO(GLuint width, GLuint height);
    unique_ptr<framebuffer> buildShadowFBO(GLuint width, GLuint height);
    unique_ptr<texture2d> buildTexture(string);
    
    unique_ptr<program> buildProgramFromFile(string);

    
};







renderer::~renderer() {
}


unique_ptr<renderer> renderer::factory()
{
    return unique_ptr<renderer>{new renderer_impl{}};
}

    renderer_impl::renderer_impl()
	{
		NSLog(@"%s %s", glGetString(GL_RENDERER), glGetString(GL_VERSION));
        
		m_viewWidth = 100;
		m_viewHeight = 100;
		
		m_characterAngle = 0;

		m_camera = make_shared<camera>();
        
        m_texture = buildTexture("up");
        
        // Make the voxel object
        {
            auto x = make_shared<leaf>();

            // Set random voxels
            voxel<char> v{ivec3(16, 2, 16)};
            for (int i = 0; i != v.size_[0]; ++i)
                for (int j = 0; j != v.size_[1]; ++j)
                    for (int k = 0; k != v.size_[2]; ++k)
                        v.get(i,j,k) = rand() & 1;
            x->vao_ = v.makeVAO();
            
            x->tex_ = m_texture;
            x->model = translate(vec3(-8, -2, -8));
            
            m_character = x;
        }

        
        // Build Program
		m_characterPrg = buildProgramFromFile("deferred");
        m_lightingPrg = buildProgramFromFile("lighting");
		
        m_deferredFBO = buildFBO(100, 100);
        m_shadowFBO = buildShadowFBO(1024, 1024);

        {
            m_screen = shared_ptr<leaf>{new leaf};
            m_screen->vao_ = shared_ptr<vao>{new vao{*make_screen()}};
        }
        
        
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        
        
		// Reset the m_characterAngle which is incremented in render
		m_characterAngle = 0;
		
		// Check for errors to make sure all of our setup went ok
		GetGLError();
        
 
	}





void renderer_impl::resize(GLuint width, GLuint height) {
	glViewport(0, 0, width, height);

	m_viewWidth = width;
	m_viewHeight = height;
    
    m_deferredFBO->resize(width, height);
    // m_camera->projection_ = GLKMatrix4MakePerspective(45, (float)m_viewWidth / (float)m_viewHeight,1.0,100);
}



void renderer_impl::render() {
    mat4 view;
    
    
    m_camera->projection_ = GLKMatrix4MakePerspective(M_PI_4, (float)m_viewWidth / (float)m_viewHeight,1.0,100);
    m_camera->view_ = GLKMatrix4MakeLookAt(10, 20, 30, 0, 0, 0, 0, 1, 0);


    spotlight s;
    s.projection_ = GLKMatrix4MakePerspective(16.f/30.f, 1, 1.0, 100);
    s.view_ = GLKMatrix4MakeLookAt(20*sin(m_characterAngle/157), 10, 20*cos(m_characterAngle/157), 0, 0, 0, 0, 1, 0);
    //s.view_ = GLKMatrix4MakeLookAt(20*sin(2), 10, 20*cos(2), 0, 0, 0, 0, 1, 0);
    
    // shadow map
    
    m_shadowFBO->bind();
    glViewport(0,0,1024,1024);
    
    m_characterPrg->use();
    view = identity4;
    s.drawAsCamera(*m_characterPrg);
    
    GLenum bufs[] = { GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2 };
    glDrawBuffers(0, bufs);
    glClearColor(0,0,0,0);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_POLYGON_OFFSET_FILL);
    glPolygonOffset(1, 1);
    
    m_character->draw(*m_characterPrg, view);
    glDisable(GL_POLYGON_OFFSET_FILL);

    // Use the program for rendering our character

    m_deferredFBO->bind();
    glViewport(0, 0, m_viewWidth, m_viewHeight);

    m_camera->draw(*m_characterPrg);

    
    
    //m_character->model = rotate(m_characterAngle/57, vec3{0.7f, 0.3f, 0.1f});
    

    glDrawBuffers(3, bufs);
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    glActiveTexture(GL_TEXTURE0);
    m_character->draw(*m_characterPrg, view);
    
    // Bind our default FBO to render to the screen
	glBindFramebuffer(GL_FRAMEBUFFER, m_defaultFBOName);
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    GetGLError();

    
    m_lightingPrg->use();
    m_camera->draw(*m_lightingPrg);
    s.draw(*m_lightingPrg);

    
    glActiveTexture(GL_TEXTURE0);
    m_deferredFBO->color_attachment[0]->bind();
    glActiveTexture(GL_TEXTURE1);
    m_texture->bind();
    glActiveTexture(GL_TEXTURE2);
    m_deferredFBO->color_attachment[1]->bind();
    glActiveTexture(GL_TEXTURE3);
    m_deferredFBO->depth_attachment->bind();
    glActiveTexture(GL_TEXTURE4);
    m_shadowFBO->depth_attachment->bind();
    
    m_screen->draw(*m_lightingPrg, identity4);
    
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


unique_ptr<texture2d> renderer_impl::buildTexture(string pathForResource)
{
    NSString* filePathName = nil;
    
    filePathName = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:pathForResource.c_str()] ofType:@"png"];
    demoImage *image = imgLoadImage([filePathName cStringUsingEncoding:NSASCIIStringEncoding], false);
    
    
    
    auto texName = unique_ptr<texture2d>{new texture2d{image->width, image->height, image->format, image->type}};
	
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
    
    imgDestroyImage(image);

	
	return texName;
}


unique_ptr<framebuffer> renderer_impl::buildFBO(GLuint width, GLuint height)
{

    auto c1 = unique_ptr<texture2d>(new texture2d(width, height, GL_RGBA, GL_UNSIGNED_BYTE));
    auto c2 = unique_ptr<texture2d>(new texture2d(width, height, GL_RGBA, GL_UNSIGNED_BYTE));
    auto d1 = unique_ptr<texture2d>(new texture2d(width, height, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT));
	   
    auto fboName = unique_ptr<framebuffer>(new framebuffer());
    fboName->bind()
        .attach_color(0, std::move(c1))
        .attach_color(1, std::move(c2))
        .attach_depth(std::move(d1));
    
	
	GetGLError();
	
	return fboName;
}

unique_ptr<framebuffer> renderer_impl::buildShadowFBO(GLuint width, GLuint height)
{
    
    auto d1 = unique_ptr<texture2d>(new texture2d(width, height, GL_DEPTH_COMPONENT, GL_UNSIGNED_SHORT));
    
    auto fboName = unique_ptr<framebuffer>(new framebuffer());
    fboName->bind()
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
        .bindFrag(1, "outNormal");
    
    prgName->link().validate().use();
	
    
	///////////////////////////////////////
	// Setup common program input points //
	///////////////////////////////////////

	
    /*
	GLint samplerLoc = glGetUniformLocation(*prgName, "diffuseTexture");
	
	// Indicate that the diffuse texture will be bound to texture unit 0
	GLint unit = 0;
	glUniform1i(samplerLoc, unit);
     */
    (*prgName)["diffuseTexture"] = 0;
    (*prgName)["spotlightTexture"] = 1;
    (*prgName)["normalTexture"] = 2;
    (*prgName)["depthTexture"] = 3;
    (*prgName)["shadowMapTexture"] = 4;
	
	GetGLError();
	
	return prgName;
	
}


