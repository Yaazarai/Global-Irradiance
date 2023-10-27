varying vec2 in_FragCoord;
uniform sampler2D in_SourceSDF;
uniform sampler2D in_Refraction;

void main() {
    vec4 sdfA = texture2D(gm_BaseTexture, in_FragCoord);
    vec4 sdfB = texture2D(in_SourceSDF, in_FragCoord);
	vec2 refraction = texture2D(in_Refraction, in_FragCoord).rg;
	gl_FragColor = vec4(max(sdfA.rg, sdfB.rg), refraction);
}