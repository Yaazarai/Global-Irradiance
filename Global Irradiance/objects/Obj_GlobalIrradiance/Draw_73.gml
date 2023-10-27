// Make sure blending is enabled when combining surfaces with existing data.
gpu_set_blendenable(true);

	// Draw and Seed the World Scene into the Global Irradiance render surface.
	surface_set_target(gameworld_irradiance[1 - global.irr_temporalframe]);
		draw_surface_ext(gameworld_worldscene, 0, 0, 1, 1, 0, c_white, 1);
	surface_reset_target();

// Disable blending for all Global Irradiance render processes (we don't care about alpha components here).
gpu_set_blendenable(false);

	// Generate the JFA + SDF of the world scene.
	irradiance_jfaseeding(gameworld_worldscene, gameworld_transfer, gameworld_jumpflood);
	irradiance_jfarender(gameworld_transfer, gameworld_jumpflood);
	irradiance_distancefield(gameworld_jumpflood, gameworld_worldsceneSDF);
	
	// CLear the jump flood surfaces for reuse.
	irradiance_clear(gameworld_transfer);
	irradiance_clear(gameworld_jumpflood);
	
	// Generate the JFA + SDF of the occluders.
	irradiance_jfaseedinginvert(gameworld_occluders, gameworld_transfer, gameworld_jumpflood);
	irradiance_jfarender(gameworld_transfer, gameworld_jumpflood);
	irradiance_distancefield(gameworld_jumpflood, gameworld_occluderSDF);
	
	// Combine the World Scene + Occluders SDFs into a single surface.
	irradiance_combinefields(gameworld_combinedSDF, gameworld_worldsceneSDF, gameworld_occluderSDF, gameworld_refraction);
	
	// Generate the special radial blue noise.
	irradiance_radialbluenoise(gameworld_radialbluenoise, (global.irr_usetimeoffsets)?global.irr_frametime:0.0);
	
	// Generate the final Global Irradiance Scene.
	surface_set_target(gameworld_irradiance[global.irr_temporalframe]);
		shader_set(global.irr_irradiance);
		shader_set_uniform_f(global.irr_irradiance_uResolution, global.irr_resolution);
		shader_set_uniform_f(global.irr_irradiance_uRaysPerPixel, global.irr_raysperpixel);
		shader_set_uniform_f(global.irr_irradiance_uStepsPerRay, global.irr_stepsperray);
		texture_set_stage(global.irr_irradiance_uDistanceField, surface_get_texture(gameworld_combinedSDF));
		texture_set_stage(global.irr_irradiance_uBlueNoise, surface_get_texture(gameworld_radialbluenoise));
		draw_surface(gameworld_irradiance[1 - global.irr_temporalframe], 0, 0);
		shader_reset();
	surface_reset_target();

// Re-Enable Alpha Blending since the Global Irradiance pass is complete.
gpu_set_blendenable(true);

if (global.irr_usetemporalfilter) {
	gpu_set_blendenable(false);
	irradiance_temporalfilter(gameworld_postprocessfilter, gameworld_irradiance[global.irr_temporalframe], gameworld_transfer);
	
	if (global.irr_usegaussianfilter)
		irradiance_gaussianfilter(gameworld_postprocessfilter, gameworld_transfer);
	
	if (global.irr_usesmartdenoisefilter)
		irradiance_smartdenoisefilter(gameworld_postprocessfilter, gameworld_transfer);
	
	gpu_set_blendenable(true);
	
	gpu_set_blendmode(bm_add);
	draw_surface(gameworld_postprocessfilter, 0, 0);
	draw_surface(gameworld_postprocessfilter, 0, 0);
	gpu_set_blendmode(bm_normal);
} else {
	gpu_set_blendenable(false);
	
	if (global.irr_usegaussianfilter)
		irradiance_gaussianfilter(gameworld_irradiance[global.irr_temporalframe], gameworld_transfer);
		
	if (global.irr_usesmartdenoisefilter)
		irradiance_smartdenoisefilter(gameworld_irradiance[global.irr_temporalframe], gameworld_transfer);
	
	gpu_set_blendenable(true);
	
	gpu_set_blendmode(bm_add);
	draw_surface(gameworld_irradiance[global.irr_temporalframe], 0, 0);
	draw_surface(gameworld_irradiance[global.irr_temporalframe], 0, 0);
	gpu_set_blendmode(bm_normal);
}

if (global.irr_usedebuginterface) {
	draw_set_color(c_black);
	draw_set_font(Fnt_MonoSpace);
	draw_set_color(c_black);
	draw_set_alpha(0.25);
	draw_rectangle(0, 0, 270, 205, false);
	draw_set_alpha(0.5);
	draw_set_color(c_yellow);
	draw_text(5, 5,   "Frame Rate:          " + string(fps));
	draw_text(5, 25,  "Resolution:          " + string(global.irr_resolution));
	draw_text(5, 45,  "[Q,A] Ray Count:     " + string(global.irr_raysperpixel));
	draw_text(5, 65,  "[W,S] Temporal:      " + string(global.irr_temporalfactor));
	draw_text(5, 85,  "[*,*] World Time:    " + string(global.irr_frametime));
	draw_text(5, 105, "[Z] Time Offsets:    " + string((global.irr_usetimeoffsets)?"TRUE":"FALSE"));
	draw_text(5, 125, "[X] Temporal Filter: " + string((global.irr_usetemporalfilter)?"TRUE":"FALSE"));
	draw_text(5, 145, "[C] Gaussian Filter: " + string((global.irr_usegaussianfilter)?"TRUE":"FALSE"));
	draw_text(5, 165, "[V] Smart Denoise:   " + string((global.irr_usesmartdenoisefilter)?"TRUE":"FALSE"));
	draw_text(5, 185, "[B] Debug Interface: " + string((global.irr_usedebuginterface)?"TRUE":"FALSE"));
	draw_set_alpha(1.0);
	draw_set_color(c_white);
}