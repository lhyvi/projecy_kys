shader_type canvas_item;

uniform vec2 center = vec2(0,0);
uniform float wave_length: hint_range(0,3.14) = 0.25 ;
uniform float speed: hint_range(0,10) = 5.;
uniform float amplitude: hint_range(0,2) = 0.5;

void fragment() {
	float len = 2. * PI / wave_length;
	float dist = distance(center, UV);
	float shade = (sin(len * (dist)/2. - (speed * TIME)))* amplitude;
	COLOR = vec4(shade,shade,shade,1);
}
