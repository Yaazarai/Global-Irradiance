varying vec2 in_FragCoord;
uniform float in_TemporalFactor;
uniform sampler2D in_PreviousFrame;

void main() {
	vec3 colorA = texture2D(gm_BaseTexture, in_FragCoord).rgb;
	vec3 colorB = texture2D(in_PreviousFrame, in_FragCoord).rgb;
	gl_FragColor = vec4(mix(colorA, colorB, in_TemporalFactor), 1.0);
}