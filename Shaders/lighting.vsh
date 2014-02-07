in vec4  inPosition;
in vec2  inTexcoord;

out vec2 varTexcoord;

void main (void)
{
	gl_Position	= inPosition;
    varTexcoord = inTexcoord;
}
