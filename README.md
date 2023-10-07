# Global-Irradiance
A better method for 2D based global illumination.

The most common issue with 2D Global Illumination--which uses a method called radiosity--is two fold: performance & noisey. The poor performance is a direct result of naive random sampling frame-by-frame, producing a noisey result. Using naive random sampling without frame-by-frame consideration requires you to increase the number of ray samples or the number of temporal frames. The former reduces performance and the later makes things blurry--neither is fun to look at for gaming. A major recommendation is to seed the golden ratio into your blue noise, because it maintains uniformity and makes the noise more blue over-time. While this may work for 3D applications and certain graphics affects, for 2D global illumination this method is very undesirable. In order to achieve production ready visually fidelity we have to take into account how noise affects our lighting on a frame-by-frame basis--since the previous frame feeds into the next frame with 2D global illumination.

Let's look at the some examples of why this doesn't work for 2D. On the left blue-noise using rotation (convert the noise to radians, add an offset, convert back to normal space) and on the right blue noise with seeded golden ratio. This is 16 rays per pixel + 2 frames (current and previous)  of temporal filtering.

![GIF_ROT](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/f353e328-256c-4ffd-a188-5af9bba592cb)
![GIF_PHI](https://github.com/Yaazarai/Global-Irradiance/assets/7478702/0956e033-70f0-45be-aca6-ce75ef765529)

The differences in visual fidelity is obvious. Since 2D global illumination relys heavily on noise for random ray rotation, this means that the scene is seeded with that noise, so the best option, unsurprisingly is to modify our noise on a frame-by-frame basis to fill in the gaps seeded by previous frames. This method ends up being vastly superior producing minimal artifacting even with only 2 temporal frames to filter out seeded noise. The other benefit here to blue-noise rotation is that the uniformity of the input texture is perfectly maintained and unmodified, since every pixel is rotated by the same offset--which cannot be said for using the golden ratio.

