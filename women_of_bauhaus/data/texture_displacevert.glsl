#define PROCESSING_TEXLIGHT_SHADER
#define M_PI 3.1415926535897932384626433832795 // Code from https://www.opengl.org/discussion_boards/showthread.php/163086-Pi-3-1415926

uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

varying vec2 coord;

// Lighting variables
uniform sampler2D sampler;
uniform int lightCount; // number of active lights
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8]; // new variable to moderate intensity of reflected colour depending on how bright the point lights are at this frame
uniform float SpecularFocus[8];
uniform vec3 SpecularContribution[8];
uniform vec3 DiffuseContribution[8];
uniform vec3 AmbientLight[8];

// Variables for vertices breaking apart effect
uniform float breathCycle = 0.5;
uniform float offset = 0.0;
uniform float amplitude = 1.0;
uniform float magnitude = 80.0; // 10 is subtle and 200 is extreme

// Variables for stretching effect

void main()
{
	coord = texCoord;
	// calculate height map from brightness of texture sample
	vec4 pixel = texture2D(sampler, coord);
	float dv = (pixel.r + pixel.g + pixel.b) / 3.0;
	dv = dv * magnitude * (sin(breathCycle * M_PI * 2) * amplitude + offset);
	vec4 displace = vec4(normalize(normal) * dv, 0.0);

	gl_Position = transform * (vertex + displace);
	vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);    

	vec3 light = vec3(0.0, 0.0, 0.0);

    vec3 vertexCamera = vec3(modelview * vertex);
    vec3 transformedNormal = normalize(normalMatrix * normal); //Vertex normal direction

	for(int i = 0; i < lightCount; i++) {
	    vec3 dir = normalize(lightPosition[i].xyz - vertexCamera); //Vertex to light direction
	    float amountDiffuse = max(0.0, dot(dir, transformedNormal));

		// calculate the vertex position in eye coordinates
		vec3 vertexViewDir = normalize(-vertexCamera);
		
		// calculate the vector corresponding to the light source reflected in the vertex surface.
		// lightDir is negated as GLSL expects an incoming (rather than outgoing) vector
		vec3 lightReflection = reflect(-dir, transformedNormal);
		
		// specular light is dot product of light reflection vector and our viewing vector.
		// the closer we are to the reflection angle, the greater the specular sheen.
		float amountSpecular = max(0.0, dot(lightReflection, vertexViewDir));
		
		// apply an additional pow() to focus the specular effect
		// (try playing with this value)
		amountSpecular = pow(amountSpecular, SpecularFocus[i]);
		
		// calculate actual light intensity
		light += (SpecularContribution[i] * amountSpecular + DiffuseContribution[i] * amountDiffuse + AmbientLight[i]) * lightDiffuse[i];
	}
	vertColor = vec4(light, 1) * color;
}