shader_type canvas_item;
render_mode blend_mul;
global uniform vec2 mouse_pos;
global uniform float out_radius;
global uniform float in_radius;
//uniform float time;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist_from_mouse = length((SCREEN_UV - mouse_pos/vec2(1600.0,900.0)/SCREEN_PIXEL_SIZE)/SCREEN_PIXEL_SIZE);
	float amt = (out_radius-dist_from_mouse)/(out_radius-in_radius);
	amt = clamp(amt,0.0,1.0);
	COLOR = vec4(COLOR.rgb*amt,COLOR.a);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
