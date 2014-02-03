uniform sampler2D diffuseTexture;

in vec4  varPosition;
in vec4  varNormal;
in vec2  varTexcoord;

out vec4 outColor;
out vec4 outPosition;
out vec4 outNormal;

void main (void)
{
	outColor    =
        0.5+clamp((texture(diffuseTexture, varTexcoord.st, 0.0)
        - texture(diffuseTexture, varTexcoord.st + vec2(0.01,0), 0.0) * 0.25
    - texture(diffuseTexture, varTexcoord.st + vec2(-0.01,0), 0.0) * 0.25
    - texture(diffuseTexture, varTexcoord.st + vec2(0.01,0), 0.0) * 0.25
    - texture(diffuseTexture, varTexcoord.st + vec2(-0.01,0), 0.0) * 0.25).x, 0, 0.001) * -100 * vec4(1,1,1,1);
    outPosition = varPosition;
    outNormal   = vec4(varNormal.xyz, 1);
}