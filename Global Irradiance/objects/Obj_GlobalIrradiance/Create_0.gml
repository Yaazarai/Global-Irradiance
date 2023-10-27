/*
	Globally Refracted Irradiance:
		Indirect Lighting using Radiosity and Emitter-First-Occluder-Second Refraction Tracking.
		
		1. Render Light Scene: Static Occluders (Black) + Emitters (Color) + Empty Space (Transparent)
		2. Render Occluders:   Dynamic Occluders (Non-Black) + Empty Space (Transparent)
		3. Subtract Emitter Space from Dynamic Occluders.
		3. Render Refraction:  (Ordered)
			3a. Empty Space (White)
			3a. Static Occluders (Black)
			3b. Dynamic Occluders (Grayscale)
			3d. Emitters (White)
		4. Calculate JumpFlood of Light Scene.
		5. Calculate Inverted JumpFlood of Dynamic Occluders.
			Inverted JFA means you invert the surface so that empty space and surfaces are swapped
			so that the final generated SDF is within the surface rather than empty space.
		6. Calculate Scene SDF + Dynamic Occluder SDF.
		7. Combine Scene SDF + Dynamic Occluder SDF + Refraction Surface.
		8. Calculate Radial Blue Noise (noise is converfted to radians, offset by time as an angle,
			then converted back to noraml 0...1 space).
		9. Render Irradiance based Lighting.
		10. Field Predictive Noise Smoothing.
		11. Run Bloom, SparseFilter and/or TemporalFilter passes.
*/
/// LIGHTING SETTINGS:
game_set_speed(60, gamespeed_fps);
global.irr_resolution = 512.0;
global.irr_raysperpixel = 32.0;
global.irr_stepsperray = 32.0;

global.irr_usedebuginterface = true;
global.irr_usetimeoffsets = true;
global.irr_usetemporalfilter = false;
global.irr_usegaussianfilter = false;
global.irr_usesmartdenoisefilter = false;
global.irr_temporalfactor = 0.5;

// STEP ITERATOR VARIABLES:
global.irr_temporalframe = 0.0;
global.irr_frametime = 0.0;

/// LIGHTING SHADERS & INITIALIZATION:
irradiance_defaultshaders();
irradiance_initialize();

/// USER GAME WORLD SURFACES:
#macro INVALID_SURFACE -1
gameworld_worldscene = INVALID_SURFACE;
gameworld_occluders = INVALID_SURFACE;
gameworld_refraction = INVALID_SURFACE;

/// UTILITY SURFACES:
gameworld_transfer = INVALID_SURFACE;
gameworld_jumpflood = INVALID_SURFACE;

/// RENDER SURFACES
gameworld_worldsceneSDF = INVALID_SURFACE;
gameworld_occluderSDF = INVALID_SURFACE;
gameworld_combinedSDF = INVALID_SURFACE;
gameworld_normalfield = INVALID_SURFACE;
gameworld_radialbluenoise = INVALID_SURFACE;
gameworld_irradiance[0] = INVALID_SURFACE;
gameworld_irradiance[1] = INVALID_SURFACE;

// FILTER SURFACES:
gameworld_postprocessfilter = INVALID_SURFACE;