varying vec2      in_FragCoord;
uniform float     in_Resolution, in_RaysPerPixel, in_StepsPerRay;
uniform sampler2D in_DistanceField, in_BlueNoise;

#define DECAY    0.95
#define EPSILON  0.0001
#define TAU      float(6.2831853071795864769252867665590)
#define V2F16(v) ((v.y * float(0.0039215686274509803921568627451)) + v.x)

vec3 raymarch(vec2 pix, vec2 dir, float rindexI, float rindexE) {
	for(float rindex = rindexI, dist = 0.0, i = 0.0; i < in_StepsPerRay; i += 1.0, pix += dir * dist) {
		vec4 rsdf = texture2D(in_DistanceField, pix).rgba;
		if ((dist = V2F16(rsdf.rg)) < EPSILON)
			return (max(texture2D(gm_BaseTexture, pix).rgb, texture2D(gm_BaseTexture, pix - (dir * (1.0/in_Resolution))).rgb) * DECAY) * rindex;
		
		if (rindexE < (rsdf.a-EPSILON) || rindexE > (rsdf.a+EPSILON))
			rindexE = rindex = min(rindex, rindex * rsdf.a);
	}
	return vec3(0.0);
}

void main() {
	vec4 rsdf = texture2D(in_DistanceField, in_FragCoord).rgba;
	vec3 irradiant = texture2D(gm_BaseTexture, in_FragCoord).rgb;
	if (V2F16(rsdf.rg) >= EPSILON) {
		float THETA = TAU * texture2D(in_BlueNoise, in_FragCoord).r;
		for(float ray = 0.0; ray < TAU; ray += TAU / in_RaysPerPixel)
			irradiant += raymarch(in_FragCoord, vec2(cos(THETA + ray), -sin(THETA + ray)), rsdf.b, rsdf.a);
		irradiant *= 1.0/(in_RaysPerPixel + 2.0);
	}
	gl_FragColor = vec4(irradiant, 1.0);
}