varying vec2 in_FragCoord;
uniform float in_Resolution;

void main() {
	float gaussian[25];
	gaussian[ 0]=0.00366300366; gaussian[ 1]=0.01465201465; gaussian[ 2]=0.02564102564; gaussian[ 3]=0.01465201465;	gaussian[ 4]=0.00366300366;
	gaussian[ 5]=0.01465201465; gaussian[ 6]=0.05860805861; gaussian[ 7]=0.09523809524; gaussian[ 8]=0.05860805861; gaussian[ 9]=0.01465201465;
	gaussian[10]=0.02564102564; gaussian[11]=0.09523809524; gaussian[12]=0.15018315018; gaussian[13]=0.09523809524; gaussian[14]=0.02564102564;
	gaussian[15]=0.01465201465; gaussian[16]=0.05860805861; gaussian[17]=0.09523809524; gaussian[18]=0.05860805861; gaussian[19]=0.01465201465;
	gaussian[20]=0.00366300366; gaussian[21]=0.01465201465; gaussian[22]=0.02564102564; gaussian[23]=0.01465201465; gaussian[24]=0.00366300366;
	
	vec2 offsets[25];
	offsets[ 0]=vec2(-2.0, -2.0); offsets[ 1]=vec2(-1.0, -2.0); offsets[ 2]=vec2(0.0, -2.0); offsets[ 3]=vec2(1.0, -2.0); offsets[ 4]=vec2(2.0, -2.0);
	offsets[ 5]=vec2(-2.0, -1.0); offsets[ 6]=vec2(-1.0, -1.0); offsets[ 7]=vec2(0.0, -1.0); offsets[ 8]=vec2(1.0, -1.0); offsets[ 9]=vec2(2.0, -1.0);
	offsets[10]=vec2(-2.0, +0.0); offsets[11]=vec2(-1.0, +0.0); offsets[12]=vec2(0.0, +0.0); offsets[13]=vec2(1.0, +0.0); offsets[14]=vec2(2.0, +0.0);
	offsets[15]=vec2(-2.0, +1.0); offsets[16]=vec2(-1.0, +1.0); offsets[17]=vec2(0.0, +1.0); offsets[18]=vec2(1.0, +1.0); offsets[19]=vec2(2.0, +1.0);
	offsets[20]=vec2(-2.0, +2.0); offsets[21]=vec2(-1.0, +2.0); offsets[22]=vec2(0.0, +2.0); offsets[23]=vec2(1.0, +2.0); offsets[24]=vec2(2.0, +2.0);
	
    vec3 light = vec3(0.0);
    for(int i = 0; i < 25; i++)
        light += texture2D(gm_BaseTexture, in_FragCoord + (offsets[i] / in_Resolution)).rgb * gaussian[i];
	
	gl_FragColor = vec4(light, 1.0);
}