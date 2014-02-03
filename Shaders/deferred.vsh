uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 inverseTransposeModelViewMatrix;

in vec4  inPosition;
in vec4  inNormal;
in vec2  inTexcoord;

out vec4 varPosition;
out vec4 varNormal;
out vec2 varTexcoord;

void main (void)
{
    varPosition = modelViewMatrix * inPosition;
	gl_Position	= projectionMatrix * varPosition;
    varNormal = inverseTransposeModelViewMatrix * vec4(inNormal.xyz, 0); // Caution -- what does last element get padded with?
    varTexcoord = inTexcoord;
}
