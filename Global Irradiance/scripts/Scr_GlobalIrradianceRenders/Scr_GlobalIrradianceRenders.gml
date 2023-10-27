function irradiance_defaultshaders() {
	global.irr_refraction = Shd_Refraction;
	global.irr_jfaseeding = Shd_JfaSeeding;
	global.irr_jfaseedinginvert = Shd_JfaSeedingInvert;
	global.irr_jumpfloodalgorithm = Shd_JumpFloodAlgorithm;
	global.irr_distancefield = Shd_DistanceField;
	global.irr_combinefields = Shd_CombineFields;
	
	global.irr_radialbluenoise = Shd_RadialBlueNoise;
	global.irr_bluenoisetexture = Spr_BlueNoise512;
	
	global.irr_irradiance = Shd_Irradiance;
	global.irr_temporalfilter = Shd_TemporalFilter;
	global.irr_gaussianfilter = Shd_GaussianFilter;
	global.irr_smartdenoisefilter = Shd_SmartDenoiseFilter;
}

function irradiance_initialize() {
	global.irr_resolution = power(2, ceil(log2(real(global.irr_resolution))));
	global.irr_raysperpixel = clamp(real(global.irr_raysperpixel), 8, 256);
	global.irr_stepsperray = clamp(real(global.irr_stepsperray), 8, 256);
	
	global.irr_refraction_uRefraction = shader_get_uniform(global.irr_refraction, "in_Refraction");
	global.irr_refraction_uReflection = shader_get_uniform(global.irr_refraction, "in_Reflection");
	global.irr_jumpfloodalgorithm_uResolution = shader_get_uniform(global.irr_jumpfloodalgorithm, "in_Resolution");
	global.irr_jumpfloodalgorithm_uJumpDistance = shader_get_uniform(global.irr_jumpfloodalgorithm, "in_JumpDistance");
	global.irr_radialbluenoise_uWorldTime = shader_get_uniform(global.irr_radialbluenoise, "in_WorldTime");
	global.irr_combinefields_uRefraction = shader_get_sampler_index(global.irr_combinefields, "in_Refraction");
	global.irr_combinefields_uSourceSDF = shader_get_sampler_index(global.irr_combinefields, "in_SourceSDF");
	global.irr_irradiance_uResolution = shader_get_uniform(global.irr_irradiance, "in_Resolution");
	global.irr_irradiance_uRaysPerPixel = shader_get_uniform(global.irr_irradiance, "in_RaysPerPixel");
	global.irr_irradiance_uStepsPerRay = shader_get_uniform(global.irr_irradiance, "in_StepsPerRay");
	global.irr_irradiance_uDistanceField = shader_get_sampler_index(global.irr_irradiance, "in_DistanceField");
	global.irr_irradiance_uBlueNoise = shader_get_sampler_index(global.irr_irradiance, "in_BlueNoise");
	global.irr_temporalfilter_uTemporalFactor = shader_get_uniform(global.irr_temporalfilter, "in_TemporalFactor");
	global.irr_temporalfilter_uPreviousFrame = shader_get_sampler_index(global.irr_temporalfilter, "in_PreviousFrame");
	global.irr_gaussianfilter_uResolution = shader_get_uniform(global.irr_gaussianfilter, "in_Resolution");
	global.irr_smartdenoisefilter_uResolution = shader_get_uniform(global.irr_smartdenoisefilter, "in_Resolution");
}

function irradiance_clear(surface) {
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    surface_reset_target();
}

function irradiance_jfaseeding(init, jfaA, jfaB) {
    surface_set_target(jfaB);
    draw_clear_alpha(c_black, 0);
    shader_set(global.irr_jfaseeding);
    draw_surface(init,0,0);
    shader_reset();
    surface_reset_target();
    
    surface_set_target(jfaA);
    draw_clear_alpha(c_black, 0);
    surface_reset_target();
}

function irradiance_jfaseedinginvert(init, jfaA, jfaB) {
    surface_set_target(jfaB);
    draw_clear_alpha(c_black, 0);
    shader_set(global.irr_jfaseedinginvert);
    draw_surface(init,0,0);
    shader_reset();
    surface_reset_target();
    
    surface_set_target(jfaA);
    draw_clear_alpha(c_black, 0);
    surface_reset_target();
}

function irradiance_jfarender(source, destination) {
    var passes = ceil(log2(global.irr_resolution));
    
    shader_set(global.irr_jumpfloodalgorithm);
    shader_set_uniform_f(global.irr_jumpfloodalgorithm_uResolution, global.irr_resolution);
	
	var tempA = source, tempB = destination, tempC = source;
    var i = 0; repeat(passes) {
        var offset = power(2, passes - i - 1);
        shader_set_uniform_f(global.irr_jumpfloodalgorithm_uJumpDistance, offset);
        surface_set_target(tempA);
			draw_surface(tempB,0,0);
        surface_reset_target();
		
		tempC = tempA;
		tempA = tempB;
		tempB = tempC;
        i++;
    }
    
    shader_reset();
	if (destination != tempC) {
		surface_set_target(destination);
			draw_surface(tempC,0,0);
        surface_reset_target();
	}
}

function irradiance_distancefield(jfa, surface) {
    surface_set_target(surface);
    draw_clear_alpha(c_black, 0);
    shader_set(global.irr_distancefield);
    draw_surface(jfa, 0, 0);
    shader_reset();
    surface_reset_target();
}

function irradiance_combinefields(destination, sourceA, sourceB, refraction) {
    surface_set_target(destination);
	draw_clear_alpha(c_black, 0);
	shader_set(global.irr_combinefields);
	texture_set_stage(global.irr_combinefields_uSourceSDF, surface_get_texture(sourceB));
	texture_set_stage(global.irr_combinefields_uRefraction, surface_get_texture(refraction));
    draw_surface(sourceA, 0, 0);
    shader_reset();
    surface_reset_target();
}

function irradiance_radialbluenoise(surface, time) {
    surface_set_target(surface);
	shader_set(global.irr_radialbluenoise);
	shader_set_uniform_f(global.irr_radialbluenoise_uWorldTime, time);
    draw_sprite_tiled(global.irr_bluenoisetexture, 0, 0, 0);
	shader_reset();
    surface_reset_target();
}

function irradiance_temporalfilter(temporalframe, currentframe, transferframe) {
	surface_set_target(transferframe);
	draw_surface(temporalframe, 0, 0);
	surface_reset_target();
	
	surface_set_target(temporalframe);
	shader_set(global.irr_temporalfilter);
	shader_set_uniform_f(global.irr_temporalfilter_uTemporalFactor, global.irr_temporalfactor);
	texture_set_stage(global.irr_temporalfilter_uPreviousFrame, surface_get_texture(transferframe));
	draw_surface(currentframe, 0, 0);
	shader_reset();
	surface_reset_target();
}

function irradiance_gaussianfilter(gaussianframe, transferframe) {
	surface_set_target(transferframe);
	draw_surface(gaussianframe, 0, 0);
	surface_reset_target();
	
	surface_set_target(gaussianframe);
	shader_set(global.irr_gaussianfilter);
	shader_set_uniform_f(global.irr_gaussianfilter_uResolution, global.irr_resolution);
	draw_surface(transferframe, 0, 0);
	shader_reset();
	surface_reset_target();
}

function irradiance_smartdenoisefilter(denoiseframe, transferframe) {
	surface_set_target(transferframe);
	draw_surface(denoiseframe, 0, 0);
	surface_reset_target();
	
	surface_set_target(denoiseframe);
	shader_set(global.irr_smartdenoisefilter);
	shader_set_uniform_f(global.irr_smartdenoisefilter_uResolution, global.irr_resolution);
	draw_surface(transferframe, 0, 0);
	shader_reset();
	surface_reset_target();
}