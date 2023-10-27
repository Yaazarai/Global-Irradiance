function draw_sprite_refraction(visibility,occlusion,spr,subimg,xpos,ypos,xscale,yscale,rot) {
	shader_set(Shd_Refraction);
	shader_set_uniform_f(global.irr_refraction_uRefraction, visibility);
	shader_set_uniform_f(global.irr_refraction_uReflection, occlusion);
	draw_sprite_ext(spr, subimg, xpos, ypos, xscale, yscale, rot, c_white, 1.0);
	shader_reset();
}

function draw_surface_refraction(visibility,occlusion,surf,xpos,ypos,xscale,yscale,rot) {
	shader_set(Shd_Refraction);
	shader_set_uniform_f(global.irr_refraction_uRefraction, visibility);
	shader_set_uniform_f(global.irr_refraction_uReflection, occlusion);
	draw_surface_ext(surf, xpos, ypos, xscale, yscale, rot, c_white, 1.0);
	shader_reset();
}

function draw_ambient_refraction(refraction) {
	var color = draw_get_color();
	var alpha = draw_get_alpha();
	refraction *= 255.0;
	draw_set_color(make_color_rgb(refraction, refraction, refraction));
	draw_set_alpha(1.0);
	draw_rectangle(0, 0, global.irr_resolution, global.irr_resolution, false);
	draw_set_alpha(alpha);
	draw_set_color(color);
}

function draw_sprite_emitter(spr,subimg,xpos,ypos,xscale,yscale,rot,col) {
	draw_sprite_ext(spr, subimg, xpos, ypos, xscale, yscale, rot, col, 1.0);
}

function draw_surface_emitter(surf,xpos,ypos,xscale,yscale,rot, col) {
	draw_surface_ext(surf, xpos, ypos, xscale, yscale, rot, col, 1.0);
}

function draw_sprite_occluder(spr,subimg,xpos,ypos,xscale,yscale,rot) {
	draw_sprite_ext(spr, subimg, xpos, ypos, xscale, yscale, rot, c_white, 1.0);
}

function draw_surface_occluder(surf,xpos,ypos,xscale,yscale,rot) {
	draw_surface_ext(surf, xpos, ypos, xscale, yscale, rot, c_white, 1.0);
}