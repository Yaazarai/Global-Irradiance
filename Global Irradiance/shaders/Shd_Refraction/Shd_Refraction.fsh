varying vec2 in_FragCoord;
uniform float in_Refraction;
uniform float in_Reflection;

void main() {
	float alpha = texture2D(gm_BaseTexture, in_FragCoord).a;
	gl_FragColor = vec4(in_Refraction, in_Reflection, 0.0, sign(alpha));
}