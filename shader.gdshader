shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	vec4 a = vec4(0,0.1*sin(SCREEN_UV*30.0),0);
	vec4 b = vec4(0.1*sin(SCREEN_UV*27.0+1.0),0,0);
	vec4 c = vec4(0,0.1*cos(SCREEN_UV*10.0),0);
	
	COLOR = a+b+c+vec4(0.9,1.0,1.2,alpha);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
