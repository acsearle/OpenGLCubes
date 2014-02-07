uniform sampler2D diffuseTexture;
uniform sampler2D spotlightTexture;
uniform sampler2D normalTexture;
uniform sampler2D depthTexture;
uniform sampler2D shadowMapTexture;

uniform mat4 cameraInverseProjectionMatrix;
uniform mat4 cameraInverseViewMatrix;

uniform mat4 spotlightProjectionMatrix;
uniform mat4 spotlightViewMatrix;
uniform mat4 spotlightInverseViewMatrix;

in vec2  varTexcoord;

out vec4 outColor;

void main (void)
{
    vec4 diffuse = texture(diffuseTexture, varTexcoord.st, 0.0);
    vec4 normal = texture(normalTexture, varTexcoord.st, 0.0) * 2 - 1;

    float depth = texture(depthTexture, varTexcoord.st, 0.0).r;
    vec4 window = vec4(varTexcoord.st, depth, 1);
    vec4 ndc = window * 2 - 1;
    vec4 eye = cameraInverseProjectionMatrix * ndc;
    eye /= eye.w;
    vec4 world = cameraInverseViewMatrix * eye;
    // Camera eye coordinates

    
    // Go from [0, 1] texture space to [-1, +1] normalized device coordinates
    
    // Window depth coordinates
    
    // outColor = eyePosition();
    
    // outColor = diffuse * (normal.y * 0.5 + 0.5);
    
    vec4 x_spotlight_eye = spotlightViewMatrix * world;
    vec4 x_spotlight_clip = spotlightProjectionMatrix * x_spotlight_eye;
    vec4 x_spotlight_ndc = x_spotlight_clip / x_spotlight_clip.w;
    vec4 x_spotlight_window = x_spotlight_ndc * 0.5 + 0.5;

    float irradiance = (x_spotlight_window.z <=
                        texture(shadowMapTexture,
                                x_spotlight_window.st,
                                0.0).r) ? 1 : 0;
    irradiance *= 900 / pow(length(x_spotlight_eye), 2);
    
    
    vec4 x_normal = spotlightViewMatrix * vec4(normal.xyz, 0);
    
    outColor = diffuse * (texture(spotlightTexture,
                                  x_spotlight_window.st,
                                  0.0) * clamp(x_normal.z, 0, 1) * irradiance * 0.5
                          + 0.5);

                        
    /*
    outColor = diffuse * (
                          texture(projectionTexture,
                                  x_spotlight_window.st,
                                  0.0) * clamp(x_normal.z, 0, 1) * 900 / (d*d) * 0.5
                          + 0.5);
     */
    /*
                        float q = texture(shadowMapTexture, x_spotlight_window.st, 0.0).r;
    if (x_spotlight_window.z < q + 0.0001)
        outColor = diffuse;
    else
        outColor = vec4(0);
*/

    /*
    vec4 x_spotlight_depth = texture(shadowMapTexture, x_spotlight_window.st, 0.0);
    outColor = x_spotlight_depth;
     */
    
    
    
    
}