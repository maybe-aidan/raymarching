#version 330 core
out vec4 FragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

#define PI 3.14159265
#define TAU (2.0 * PI)

void rotate_around_axis(inout vec2 p, float a) {
    p = cos(a) * p + sin(a) * vec2(p.y, -p.x);
}

// p: arbitrary point in 3D space
// c: center of the sphere
// r: radius of the sphere
float distance_from_sphere(in vec3 p, in vec3 c, in float r){
    return length(p - c) - r;
    // distance between our point and the center of the sphere, minus its radius
}
// Cases:
// || p - c || < r : we are inside the sphere
// || p - c || = r : we are touching the sphere
// || p - c || > r : we are outside the sphere

// basic smooth displacement using a combination of continous periodic functions
float displacement(in vec3 p) {
    return sin(4.0 * p.x + u_time * 0.02) * sin(6.0 * p.y - u_time * 0.005) * sin(3.0 * p.z + u_time * 1.02) * 0.25;
}

// Combination of all SDFs
float map_of_the_world(in vec3 p){
    float disp = displacement(p);
    float sphere0 = distance_from_sphere(p, vec3(0, 0, 0), 1.0);

    return sphere0 + disp;
}

// Samples points close to the position in order to determine the gradient(derivative of vector functions), 
// which allows us to calculate a normal for any general sdf
vec3 calculate_normal(in vec3 p) {
    const vec3 small_step = vec3(0.0001, 0.0, 0.0);
    float x_gradient = map_of_the_world(p + small_step.xyy) - map_of_the_world(p - small_step.xyy);
    float y_gradient = map_of_the_world(p + small_step.yxy) - map_of_the_world(p - small_step.yxy);
    float z_gradient = map_of_the_world(p + small_step.yyx) - map_of_the_world(p - small_step.yyx);

    vec3 normal = vec3(x_gradient, y_gradient, z_gradient);

    return normalize(normal);
}


// Phong reflection model
vec3 phong(in vec3 lightDir, in vec3 viewDir, in vec3 N) {
    const vec3 lightColor = vec3(1.0, 1.0, 1.0);

    // ambient lighting
    const float ambientStrength = 0.1;
    vec3 ambient = lightColor * ambientStrength;

    // diffuse lighting
    float diff = max(dot(N, lightDir), 0.0);
    vec3 diffuse = lightColor * diff;

    // specular lighting
    const float specularStrength = 0.5;
    vec3 reflectDir = reflect(lightDir, N);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = lightColor * (specularStrength * spec);

    vec3 result = ambient + diffuse + specular;
    return result;
}

// The raymarching algorithm
vec3 raymarch(in vec3 ro, in vec3 rd, in vec2 uv) {
    float total_dist_traveled = 0.0;

    // constants to break out of the loop
    const int NUMBER_OF_STEPS = 256;
    const float EPSILON = 0.0001;
    const float MAX_DISTANCE = 1000.0;

    for(int i = 0; i < NUMBER_OF_STEPS; i++) {
        // current position is equal to the origin of the ray + distance traveled in a given direction
        vec3 current_position = ro + total_dist_traveled * rd;

        // feed the sdf with p = current_position
        float march_radius = map_of_the_world(current_position);

        if(march_radius < EPSILON) { // Hit!
            vec3 normal = calculate_normal(current_position);

            vec3 light_position = vec3(2.0, -5.0, 3.0);

            // creates a normalized vector pointing toward the light
            vec3 direction_to_light = normalize(current_position - light_position);
            // generates sahding based on the phong model
            vec3 lighting = phong(normalize(direction_to_light), normalize(current_position - ro), normal);

                                                         // Color based on displacement value
            return vec3(0.0, 0.6353, 1.0) * lighting + displacement(current_position) * vec3(0.0, 1.0, 0.0) * 2;
        }

        if(total_dist_traveled > MAX_DISTANCE) { // Miss
            break;
        }
        // increment the distance traveled by the result of the signed distance function
        total_dist_traveled += march_radius;
    }
                                        // creates the sort of starburst effect of the background
    return vec3(0.0, 0.1725, 0.3686) * ((1/sqrt(uv.x * uv.x + uv.y * uv.y)) + vec3(0.2));

}

// camera stuff
mat3 getCam(vec3 ro, vec3 lookAt) {
	vec3 camF = normalize(vec3(lookAt - ro));
	vec3 camR = normalize(cross(vec3(0,1,0), camF));
	vec3 camU = cross(camF, camR);
	return mat3(camR, camU, camF);
}

void mouseControl(inout vec3 ro) {
    vec2 m = u_mouse / u_resolution;
    rotate_around_axis(ro.yz, m.y * PI * 0.5 - 0.5);
    rotate_around_axis(ro.xz, m.x * TAU );
}

void render(inout vec3 color, in vec2 uv) {
    vec3 camera_position = vec3(3.0, 3.0, -5.0);
    vec3 ro = camera_position;
    mouseControl(ro);
    vec3 lookAt = vec3(0.0, 0.0, 0.0);
    vec3 rd = getCam(ro, lookAt) * normalize(vec3(uv, 1.0));
    color = raymarch(ro, rd, uv);
}

void main() {
    // remaps the screen coordinates to [0, 1] on both x and y
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 color = vec3(0.0, 0.0, 0.0);
    render(color, uv);

    FragColor = vec4(color, 1.0);
}
