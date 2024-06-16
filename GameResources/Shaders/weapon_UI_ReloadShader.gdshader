shader_type canvas_item;

uniform float percentage : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	
	
	
	float  avg = (main_texture.r + main_texture.g + main_texture.b) / 3.0;
	
	COLOR.a = main_texture.a;
	COLOR.rgb = main_texture.rgb * step(UV.x, percentage) +  vec3(avg) * step(percentage, UV.x);
}