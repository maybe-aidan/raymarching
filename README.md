# Raymarching
A repository documenting my progressing learning about the raymarching method of rendering

## Description

This project is a documentation of my recent endeavors in learning the raymarching techinique for 3D rendering, in which 3D objects are represented by Signed Distance Fucntions (SDFs),
negating the need for many polygons to represent complex 3D geometry. This allows the programs to cut down on space typically needed to store large 3D models, with many triangles,
as this method only renders two triangles. The use of signed distance functions instead of 3D models, allows us as programmers and artists to create beautiful and complex 3D objects,
such as fractals, and infinitely repeated shapes without any signifcant performance decrease.

## The Algorithm

There are many much better sources to learn about the raymarching algorithm, but here is my breakdown.
- Starting from a point in space and a direction the point wishes to travel, a distance to the nearest object is calculated (using a combination of SDFs).
- This distance is the maximum safe distance the point can travel in **any** direction.
- The point then **marches** forward and recalculates the distance to the nearest object.
- This is repeated until the distance to an object is arbitrarily small (an object is hit), or enough steps have occurred (an object is missed)

We do this algorithm for each pixel on the screen, and assign color data based on whether an object was "hit" or not. This algorithm, combined with lighting models such as Phong or Blinn-Phong allow us to create really interesting images with pure math.

## Setup

This project was built on a 64 bit Windows machine, using Visual Studio Code. The .json file I used for building in g++ is provided. 
Included is also a version of the fragment shader used, written and formatted for shadertoy.com
- Get it running on shadertoy, all you have to do is copy all the code from the "shadertoy.glsl" file.
- Otherwise, you can try to build the project as a standalone C++ application.

## Other Resources and Learning

- For more learning on 3D graphics in general, I highly reccomend [learnopengl](learnopengl.com), which is where I learned most of what I know.
- For more on raymarching and setting up your first project on your own, I reccommend [this](https://michaelwalczyk.com/blog-ray-marching.html) article written by Michael Walczyk, which is where I started this project from.
