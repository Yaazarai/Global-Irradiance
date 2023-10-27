varying vec2 in_FragCoord;

#define F16V2(f) vec2(floor(f * 255.0) * float(0.0039215686274509803921568627451), fract(f * 255.0))

void main() {
	vec4 color = texture2D(gm_BaseTexture, in_FragCoord);
	float emissive = max(color.r, max(color.g, color.b));
	vec4 scene = vec4(1.0) - vec4(sign(color.rgb), sign(emissive));
	gl_FragColor = vec4(F16V2(in_FragCoord.x * scene.a), F16V2(in_FragCoord.y * scene.a));
}