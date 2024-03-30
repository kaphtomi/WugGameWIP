shader_type canvas_item;
global uniform vec2 mouse_pos;
const float out_radius = 130.0;
const float in_radius = 120.0;
//uniform float time;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

void fragment() {
	float dist_from_mouse = length((SCREEN_UV - mouse_pos)/SCREEN_PIXEL_SIZE);
	float amt = (out_radius-dist_from_mouse+10.0*fract(sin(dot(SCREEN_UV,vec2(12.9898,78.233)*TIME))*43758.5453123))/(out_radius-in_radius);
	amt = clamp(amt,0.0,1.0);
	COLOR = vec4(COLOR.rgb*amt,COLOR.a);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
