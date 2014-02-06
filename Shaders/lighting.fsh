uniform sampler2D diffuseTexture;

in vec2  varTexcoord;

out vec4 outColor;

void main (void)
{
	outColor = texture(diffuseTexture, varTexcoord.st, 0.0);
}