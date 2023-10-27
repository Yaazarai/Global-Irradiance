# Global-Irradiance
A better method for 2D based global illumination. Built with GameMaker Studio 2 (v2023.6.0.92).

<p align="center">
  <img src="https://github.com/Yaazarai/Global-Irradiance/assets/7478702/5169b042-0485-4008-9061-cab933e1ab74" />
</p>

----

## USING GLOBAL IRRADIANCE

Global irradiance provides 3 helper functions for occluders, emitters and refraction: `draw_sprite_occluder / emitter / refraction` and `draw_surface_occluder / emitter / refraction`.

The `Obj_GlobalIrradiance` is a test object which implements the system and provides three surfaces that you must draw your scene to using the functions above: `gameworld_occluders`, `gameworld_worldscene` and `gameworld_refraction`.

1. `gameworld_occluders` must contain all occluders in your scene. Draw your occluders in BLACK so that they only cast shadows, draw them in COLOR/WHITE if you want them to be visible.
2. `gameworld_worldscene` must have the previous surface drawn in BLACK (removing all color) and then have all emitters drawn to it.
3. `gameworld_refraction` must contain all occluders in your scene that will be visible have their refraction properties rendered here.

In the provided test object the scene is all drawn in the `Draw Begin` event. Here is that example:
```GML
surface_set_target(gameworld_occluders);
draw_clear_alpha(c_black, 0);
	draw_sprite_occluder(Spr_WallScene, 0, 0, 0, 1, 1, 0);
	draw_sprite_occluder(Spr_Occluder, 0, mouse_x, mouse_y, 1, 1, global.irr_frametime / 30.0);
surface_reset_target();


surface_set_target(gameworld_worldscene);
draw_clear_alpha(c_black, 0);
	draw_surface_emitter(gameworld_occluders, 0, 0, 1, 1, 0, c_black); // Brightness is taken from the color of the emnitter, brighter colors have brighter light.
	draw_sprite_emitter(Spr_EmitterScene, 0, 0, 0, 1, 1, 0, c_white); // Brightness is taken from the color of the emnitter, brighter colors have brighter light.
surface_reset_target();

surface_set_target(gameworld_refraction);
draw_clear_alpha(c_black, 0);
	draw_ambient_refraction(1.0);
	draw_sprite_refraction(0.0 /*visibility*/, 0.0 /*occlusion*/, Spr_WallScene, 0, 0, 0, 1, 1, 0);
	draw_sprite_refraction(1.0 /*visibility*/, 0.0 /*occlusion*/, Spr_Occluder, 0, mouse_x, mouse_y, 1, 1, global.irr_frametime / 30.0);
surface_reset_target();
```

----

## PART ONE: REWORKING NOISE
The most common issue with 2D Global Illumination--which uses a method called radiosity--is two fold: performance & noisey. The poor performance is a direct result of naive random sampling frame-by-frame, producing a noisey result. Using naive random sampling without frame-by-frame consideration requires you to increase the number of ray samples or the number of temporal frames. The former reduces performance and the later makes things blurry--neither is fun to look at for gaming. A major recommendation is to seed the golden ratio into your blue noise, because it maintains uniformity and makes the noise more blue over-time. While this may work for 3D applications and certain graphics affects, for 2D global illumination this method is very undesirable. In order to achieve production ready visually fidelity we have to take into account how noise affects our lighting on a frame-by-frame basis--since the previous frame feeds into the next frame with 2D global illumination.

Let's look at the some examples of why this doesn't work for 2D. On the left blue-noise using rotation (convert the noise to radians, add an offset, convert back to normal space) and on the right blue noise with seeded golden ratio. This is 16 rays per pixel + 2 frames (current and previous)  of temporal filtering.

![GIF_ROT](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/f353e328-256c-4ffd-a188-5af9bba592cb)
![GIF_PHI](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/0956e033-70f0-45be-aca6-ce75ef765529)

The differences in visual fidelity is obvious. Since 2D global illumination relys heavily on noise for random ray rotation, this means that the scene is seeded with that noise, so the best option, unsurprisingly is to modify our noise on a frame-by-frame basis to fill in the gaps seeded by previous frames. This method ends up being vastly superior producing minimal artifacting even with only 2 temporal frames to filter out seeded noise. The other benefit here to blue-noise rotation is that the uniformity of the input texture is perfectly maintained and unmodified, since every pixel is rotated by the same offset--which cannot be said for using the golden ratio.

----

## PART TWO: REFRACTION
One of the new main features of Global Irradiance is refraction tracking. Refraction is the the change in direction of different frequencies of light as it passes through a medium... Well this isn't what we're doing, but rather we're simulating a change in light as it passes through an occluder. This allows occluders to be lit-up with varying levels of brightness, say depending on z-depth or transparency for faking windows or for lighting up enemies/players in a game scene. How is this done? We internally trace each occluder by generating the occluders their own internal SDF and then combining that with the master scene SDF. This is done by rendering dynamic occluders to their own surface in color with transparent empty space and inverting the surface so that empty/space and occluders swap and then performing jumpflooding and SDF on the inverted occluder surface.

![Screenshot_1](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/e11545b7-d6e9-42cc-b5c5-2dc65110a734)
![Screenshot_2](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/ca44567b-ab0c-40b2-8c6c-2ae84c20243b)
![Screenshot_3](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/52e8370e-2868-447f-ae2c-ae5af9c1bed1)


Finally we define two separate properties for the occluders, this is `visibility` and `occlusion`. Visibility tells the GI system how lit-up the occluder should be. Occlusion tells the GI system how strong of a shadow the occluder should cast. The Occlusion property should NEVER be higher than the Visibility property. Using the provided helper functions `draw_sprite_refraction()` and `draw_surface_refraction()` will not allow you to do this by default saving you the trouble of debugging.

![Screenshot_4](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/145b3284-68c6-4d2b-8313-ce9924ea0758)

Here black means zero refraction and will block ALL light sources from passing through, white is the ambient light level and red, yellow or green are the refraction properties of the dynamic occluders. The GI makes this work by tracking changes in refraction when any change in the signed distance field of the scene needs to be checked, which is near edges of surfaces when raytracing needs higher precision. This allows us to check for changes in the level of refraction efficiently as each ray is traced.

![image](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/7503553d-29ae-45d7-a99d-2eabd3d3ef49)

