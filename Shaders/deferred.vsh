uniform mat4 cameraProjectionMatrix;
uniform mat4 cameraViewMatrix;


uniform mat4 modelViewMatrix;
uniform mat4 inverseTransposeModelViewMatrix;

in vec4  inPosition;
in vec4  inNormal;
in vec2  inTexcoord;

out vec4 varNormal;
out vec2 varTexcoord;

void main (void)
{
	gl_Position	= cameraProjectionMatrix * cameraViewMatrix * modelViewMatrix * inPosition;
    varNormal = inverseTransposeModelViewMatrix * inNormal;
    varTexcoord = inTexcoord;
}
