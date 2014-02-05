//
//  framebuffer.h
//  OSXGLEssentials
//
//  Created by Antony Searle on 2/3/14.
//
//

#ifndef __OSXGLEssentials__framebuffer__
#define __OSXGLEssentials__framebuffer__

#include <memory>
#include <vector>

#include "texture.h"

class framebuffer : public named {
public:

    std::vector<std::shared_ptr<texture2d>> color_attachment;
    std::shared_ptr<texture2d> depth_attachment;
    
    framebuffer() {
        glGenFramebuffers(1, &name_);
        GLint maxColorAttachments;
        glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColorAttachments);
        color_attachment.resize(maxColorAttachments);
    }
    
    ~framebuffer() {
        glDeleteFramebuffers(1, &name_);
    }
    
    framebuffer& bind() {
        glBindFramebuffer(GL_FRAMEBUFFER, name_);
        return *this;
    }
    
    framebuffer& validate() {
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"Framebuffer is incomplete: %x", status);
        }
        return *this;
    }
    
    framebuffer& attach_color(GLuint index, std::shared_ptr<texture2d> t) {
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + index, GL_TEXTURE_2D, *t, 0);
        color_attachment[index] = t;
        return *this;
    }
    
    framebuffer& attach_depth(std::shared_ptr<texture2d> t) {
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, *t, 0);
        depth_attachment = t;
        return *this;
    }
    
    framebuffer& resize(GLsizei width, GLsizei height) {
        for (auto p : color_attachment)
            if (p)
                p->bind().resize(width, height);
        if (depth_attachment)
            depth_attachment->bind().resize(width, height);
        return *this;
    }
    
};



#endif /* defined(__OSXGLEssentials__framebuffer__) */
