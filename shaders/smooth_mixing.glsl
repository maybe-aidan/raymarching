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

// Float Operators

float intersectSDF(in float distA, in float distB) {
    return max(distA, distB);
}

float unionSDF(in float distA, in float distB) {
    return min(distA, distB);
}
 
float differenceSDF(in float distA, in float distB) {
    return max(distA, -distB);
}

float smoothMax(float a, float b, float k) {
    return log(exp(k * a) + exp(k * b)) / k;
}

float smoothMin(float a, float b, float k) {
    return -smoothMax(-a, -b, k);
}

// Vec2 Operators
vec2 intersectVec2(in vec2 v1, in vec2 v2) {
    return (v1.x > v2.x) ? v1: v2;
}

vec2 unionVec2(in vec2 v1, in vec2 v2) {
    return (v1.x < v2.x) ? v1: v2;
}

vec2 differenceVec2(in vec2 v1, in vec2 v2) {
    return (v1.x > -v2.x) ? v1: -v2;
}

vec2 smoothMinVec2(in vec2 v1, in vec2 v2, float k) {
    float x = smoothMin(v1.x, v2.x, k);
    float y = unionVec2(v1, v2).y;
    vec2 result = vec2(x, y);
    return result;
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

float distance_from_cube(in vec3 p, in vec3 c, in float scale) {
    vec3 q = abs(p - c) - scale;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float displacement(in vec3 p) {
    return sin(4.0 * p.x + u_time * 0.2) * cos(6.0 * p.y - u_time * 0.5) * sin(3.0 * p.z + u_time * 1.02) * 0.25;
}

float distance_from_origin(in vec3 p) {
    return length(p - vec3(0.0));
}

// Combination of all SDFs
vec2 map_of_the_world(in vec3 p){
    float disp = displacement(p);
    vec3 origin = vec3(0.0);

    // complex shape
    vec3 position = vec3(sin(u_time) * 5.0, cos(u_time) , sin(u_time + 0.5));
    float moving_ID = 1.0;
    float sphere0_func = distance_from_sphere(p, position, 1.1);
    float cube_func = distance_from_cube(p, position, 1.0);
    float complex_function = differenceSDF(cube_func, sphere0_func - disp);
    vec2 moving = vec2(complex_function, moving_ID);

    // complex shape
    float shape_ID = 3.0;
    float cube_component = distance_from_cube(p, origin, 1.8);
    float inner_sphere = distance_from_sphere(p, origin, 2.3);
    float outer_sphere = distance_from_sphere(p, origin, 2.5);
    float complex = intersectSDF(outer_sphere, differenceSDF(cube_component, inner_sphere));
    vec2 complex_shape = vec2(complex, shape_ID);

    vec2 scene = smoothMinVec2(complex_shape, moving, 3.0);

    return scene;
}

vec3 calculate_normal(in vec3 p) {
    const vec3 small_step = vec3(0.0001, 0.0, 0.0);
    float x_gradient = map_of_the_world(p + small_step.xyy).x - map_of_the_world(p - small_step.xyy).x;
    float y_gradient = map_of_the_world(p + small_step.yxy).x - map_of_the_world(p - small_step.yxy).x;
    float z_gradient = map_of_the_world(p + small_step.yyx).x - map_of_the_world(p - small_step.yyx).x;

    vec3 normal = vec3(x_gradient, y_gradient, z_gradient);

    return normalize(normal);
}

vec3 getMaterial(float ID) {
    vec3 m;
    switch(int(ID)) {
        case 1:
            m = vec3(0.9255, 0.1098, 0.0); break;
        case 2:
            m = vec3(0.0, 0.7333, 0.1843); break;
        case 3:
            m = vec3(0.749, 0.0, 0.902); break;
        default:
            m = vec3(1.0, 1.0, 1.0); break;
    }

    return m;
}

vec3 phong(in vec3 lightDir, in vec3 viewDir, in vec3 N, in float ID) {
    const vec3 lightColor = vec3(1.0, 1.0, 1.0);

    const float ambientStrength = 0.1;
    vec3 ambient = lightColor * ambientStrength;

    float diff = max(dot(N, lightDir), 0.0);
    vec3 diffuse = lightColor * diff;

    const float specularStrength = 0.5;
    vec3 reflectDir = reflect(lightDir, N);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    vec3 specular = lightColor * (specularStrength * spec);

    vec3 color = getMaterial(ID);

    vec3 result = ambient * color + diffuse * color + specular;
    return result;
}

vec3 blinn_phong(in vec3 lightDir, in vec3 viewDir, in vec3 N, in float ID) {
    const vec3 lightColor = vec3(0.8, 1.0, 1.0);
    const float ambientStrength = 0.2;
    const float specularStrength = 0.5;
    vec3 color = getMaterial(ID);

    // ambient
    vec3 ambient = ambientStrength * color;
    // diffuse
    float diff = max(dot(lightDir, N), 0.0);
    vec3 diffuse = diff * color;
    // specular
    vec3 reflectDir = reflect(lightDir, N);
    float spec = 0.0;
    vec3 halfwayDir = normalize(lightDir - viewDir);
    spec = pow(max(dot(N, halfwayDir), 0.0), 32.0);

    vec3 specular = vec3(1.0) * spec;

    return ambient + diffuse + specular;
}

vec3 raymarch(in vec3 ro, in vec3 rd, in vec2 uv) {
    float total_dist_traveled = 0.0;

    const int NUMBER_OF_STEPS = 256;
    const float EPSILON = 0.001;
    const float MAX_DISTANCE = 1000.0;

    for(int i = 0; i < NUMBER_OF_STEPS; i++) {
        vec3 current_position = ro + total_dist_traveled * rd;

        // feed the sdf with p = current_position
        float march_radius = map_of_the_world(current_position).x;

        if(march_radius < EPSILON) { // Hit!
            vec3 normal = calculate_normal(current_position);

            vec3 light_position = vec3(2.0, -5.0, 3.0);

            vec3 direction_to_light = normalize(current_position - light_position);

            vec3 lighting = blinn_phong(normalize(direction_to_light), normalize(current_position - ro), normal, map_of_the_world(current_position).y);
                                                         // Color based on displacement value
            return lighting; //  + displacement(current_position) * vec3(0.0, 1.0, 0.0) * 2.0;
        }

        if(total_dist_traveled > MAX_DISTANCE) { // Miss
            break;
        }
        total_dist_traveled += march_radius;
    }
                                        // creates the sort of starburst effect of the background
    return vec3(0.0, 0.1725, 0.3686) * ((1/sqrt(uv.x * uv.x + uv.y * uv.y)) + vec3(0.2));

}

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
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 color = vec3(0.0, 0.0, 0.0);
    render(color, uv);

    FragColor = vec4(color, 1.0);
}