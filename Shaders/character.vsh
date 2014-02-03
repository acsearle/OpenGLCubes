
// Declare our modelViewProjection matrix that we'll compute
//  outside the shader and set each frame
//uniform mat4 modelViewProjectionMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 inverseTransposeModelViewMatrix;

// Declare inputs and outputs
// inPosition : Position attributes from the VAO/VBOs
// inTexcoord : Texcoord attributes from the VAO/VBOs
// varTexcoord : TexCoord we'll pass to the rasterizer
// gl_Position : implicitly declared in all vertex shaders. Clip space position
//               passed to rasterizer used to build the triangles

in vec4  inPosition;
in vec2  inTexcoord;
in vec3 inNormal;
out vec2 varTexcoord;
out vec3 varNormal;

void main (void) 
{
	// Transform the vertex by the model view projection matrix so
	// the polygon shows up in the right place
	gl_Position	= projectionMatrix * modelViewMatrix * inPosition;
    //gl_Position	= inPosition+vec4(150,450,450,450);
	
	// Pass the unmodified texture coordinate from the vertex buffer
	// directly down to the rasterizer.
    varTexcoord = inTexcoord;
    varNormal = (inverseTransposeModelViewMatrix * vec4(inNormal, 0)).xyz;
}
