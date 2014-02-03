uniform mat4 viewMatrix;

in vec4  inPosition;
in vec2  inTexcoord;

out vec2 varTexcoord;

void main (void)
{
	gl_Position	= viewMatrix * inPosition;
    varTexcoord = inTexcoord;
}
