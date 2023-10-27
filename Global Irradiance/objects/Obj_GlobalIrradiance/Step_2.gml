// SYSTEM FRAME ITERATORS:
global.irr_temporalframe = !global.irr_temporalframe;
global.irr_frametime += 2.0 * global.irr_usetimeoffsets;

// EXAMPLE SYSTEM CONTROLS:
global.irr_raysperpixel += 8 * (keyboard_check_pressed(ord("A")) - keyboard_check_pressed(ord("Q")));
global.irr_temporalfactor += 0.05 * (keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W")));
global.irr_usetimeoffsets ^= keyboard_check_pressed(ord("Z"));
global.irr_usetemporalfilter ^= keyboard_check_pressed(ord("X"));
global.irr_usegaussianfilter ^= keyboard_check_pressed(ord("C"));
global.irr_usesmartdenoisefilter ^= keyboard_check_pressed(ord("V"));
global.irr_usedebuginterface ^= keyboard_check_pressed(ord("B"));

// SYSTEM CLAMPING RESTRICTIONS:
global.irr_resolution = power(2, ceil(log2(real(global.irr_resolution))));
global.irr_raysperpixel = clamp(real(global.irr_raysperpixel), 8, 256);
global.irr_temporalfactor = clamp(real(global.irr_temporalfactor), 0.05, 0.95);