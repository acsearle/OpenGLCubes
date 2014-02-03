uniform sampler2D diffuseTexture;

in vec4  varPosition;
in vec4  varNormal;
in vec2  varTexcoord;

out vec4 outColor;
out vec4 outPosition;
out vec4 outNormal;

void main (void)
{
	outColor    = texture(diffuseTexture, varTexcoord.st, 0.0);
    outPosition = varPosition;
    outNormal   = varNormal;
}