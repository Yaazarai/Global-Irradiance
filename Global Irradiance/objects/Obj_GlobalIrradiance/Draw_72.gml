/*
	Anything drawn to this surface should be drawn in color/white (color is irrelevant), just not black.
	Helper Functions:
		draw_sprite_occluder
		draw_surface_occluder
*/
surface_set_target(gameworld_occluders);
draw_clear_alpha(c_black, 0);
draw_sprite_occluder(Spr_WallScene, 0, 0, 0, 1, 1, 0);
draw_sprite_occluder(Spr_Occluder, 0, mouse_x, mouse_y, 1, 1, global.irr_frametime / 30.0);

// Uncomment this to allow lights to be traced inside occluders--visually not recommended.
//draw_sprite_emitter(Spr_EmitterScene, 0, 0, 0, 1, 1, 0, c_black);
surface_reset_target();

/*
	ALL walls--including dynamic occluders--should be drawn to this surface in black.
	ALL emitters are drawn in color.
	Helper Functions:
		draw_sprite_emitter
		draw_surface_emitter
*/
surface_set_target(gameworld_worldscene);
draw_clear_alpha(c_black, 0);
draw_surface_emitter(gameworld_occluders, 0, 0, 1, 1, 0, c_black);

draw_sprite_emitter(Spr_EmitterScene, 0, 0, 0, 1, 1, 0, c_white);
draw_set_color(c_white);
surface_reset_target();

/*
	Anything drawn to this surface should ALSO be drawn to gameworld_occluders.
	Helper Functions:
		draw_sprite_refraction
		draw_surface_refraction
*/
surface_set_target(gameworld_refraction);
draw_clear_alpha(c_black, 0);
draw_ambient_refraction(1.0);

draw_sprite_refraction(0.0, 0.0, Spr_WallScene, 0, 0, 0, 1, 1, 0);
draw_sprite_refraction(1.0, 0.0, Spr_Occluder, 0, mouse_x, mouse_y, 1, 1, global.irr_frametime / 30.0);

surface_reset_target();