shader_type canvas_item;
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
	float alpha = texture(TEXTURE, UV).a;
	if (COLOR.r+COLOR.g+COLOR.b<.25) {
		COLOR=vec4(.2/3.0,.2/3.0,.2/3.0,COLOR.a);
	} else {
		float red = noise(SCREEN_UV+TIME*.5);
		float green = noise(SCREEN_UV-TIME*.5);
		float blue = noise(SCREEN_UV+TIME*.2);
		COLOR = vec4(0.9+red*.1,.5+ .5*green,.5 + .5*blue,alpha);
	}
	
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
