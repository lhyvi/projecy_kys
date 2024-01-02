shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	// Place fragment code here.
	vec4 col = texture(TEXTURE, UV);
	float dist = distance(vec2(0,UV.y), vec2(0,0.5));
	col = mix(col,vec4(0,0,0,1), dist * 1.);
	COLOR = col;
}
