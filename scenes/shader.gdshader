shader_type canvas_item;

uniform int pixel_size:hint_range(1,10) = 1; // Size of Downsampled Pixels, make sure its a power of 2
uniform int bayer_level:hint_range(0,2) = 1;
uniform float _Spread: hint_range(0, 1); // Dither spread
uniform float dither_size: hint_range(0,1); // Dither clamp
uniform int palette_color_count; // Put size of color palette here; or use script to put gradient size
uniform sampler2D gradient: filter_nearest; // Put gradient here
uniform float[100] gradient_offsets; // Don't touch; use script to put offsets from gradient to here


const int bayer2[4] = int[4] (
            0, 2,
            3, 1
        );
const int[16] bayer4 = int[16] (
            0, 8, 2, 10,
            12, 4, 14, 6,
            3, 11, 1, 9,
            15, 7, 13, 5
        );
const int[64] bayer8 = int[64](
            0, 32, 8, 40, 2, 34, 10, 42,
            48, 16, 56, 24, 50, 18, 58, 26,  
            12, 44,  4, 36, 14, 46,  6, 38, 
            60, 28, 52, 20, 62, 30, 54, 22,  
            3, 35, 11, 43,  1, 33,  9, 41,  
            51, 19, 59, 27, 49, 17, 57, 25, 
            15, 47,  7, 39, 13, 45,  5, 37, 
            63, 31, 55, 23, 61, 29, 53, 21
        );
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

float GetBayer2(int x, int y) {
    return float(bayer2[(x % 2) + (y % 2) * 2]) * (1.0 / 4.0) - 0.5;
}

float GetBayer4(int x, int y) {
    return float(bayer4[(x % 4) + (y % 4) * 4]) * (1.0 / 16.0) - 0.5;
}

float GetBayer8(int x, int y) {
    return float(bayer8[(x % 8) + (y % 8) * 8]) * (1.0 / 64.0) - 0.5;
}
vec4 get_gradient_color(float position) {
    return textureLod(gradient, vec2(clamp(position,0,1), 0.5),0.0);
}
float getBayer(int x, int y) {
	if(bayer_level == 0) {
		return GetBayer2(x,y);
	} else if (bayer_level == 1) {
		return GetBayer4(x,y);
	}
	return GetBayer8(x, y);
}
vec4 get_dithered_col(vec4 col, sampler2D screen_texture, vec2 uv, vec2 screen_pixel_size) {
	int x = int(uv.x / screen_pixel_size.x);
    int y = int(uv.y / screen_pixel_size.y);
	
	vec4 output = col + _Spread * getBayer(x,y);

//	float _RedColorCount = 16.;
//	float _GreenColorCount = 16.;
//	float _BlueColorCount = 16.;
//
//    output.r = floor((_RedColorCount - 1.0) * output.r + 0.5) / (_RedColorCount - 1.0);
//    output.g = floor((_GreenColorCount - 1.0) * output.g + 0.5) / (_GreenColorCount - 1.0);
//    output.b = floor((_BlueColorCount - 1.0) * output.b + 0.5) / (_BlueColorCount - 1.0);
	return output;
}

float get_lum(vec3 color) {
	return (color.r * 0.299) + (color.g * 0.587) + (color.b * 0.114);
}
bool is_pixel_dithered(float fact) {
	float range_length = 1. / float(palette_color_count);
	for(int i = 1; i <= palette_color_count; i++) {
		//float p = range_length * float(i);
		float p = gradient_offsets[i];
		float dither_length = range_length * dither_size;
		float d1 = p - (dither_length);
		float d2 = p + (dither_length);
		if (d1 <= fact && fact <= d2) {
			return true;
		}
	}
	return false;
}

void fragment() 
{
	// downsample the uv by multiplying it by (texture_size / pixel_size) and flooring
	// vec2 screen_size = vec2(1,1) / SCREEN_PIXEL_SIZE;
	vec2 downed_pixel_size = SCREEN_PIXEL_SIZE * float(pixel_size);
	vec2 s_uv = floor(SCREEN_UV / downed_pixel_size) * downed_pixel_size;
	vec4 col = texture(SCREEN_TEXTURE, s_uv);

	float lum = get_lum(col.rgb);
	if (is_pixel_dithered(lum)) {
		col = get_dithered_col(col, SCREEN_TEXTURE, SCREEN_UV, downed_pixel_size);
	}
	float dlum = get_lum(col.rgb);
	col = get_gradient_color(dlum);
	col = col * ((sin(SCREEN_UV.y / SCREEN_PIXEL_SIZE.y + (TIME * 5.)) + 1.) * .1 + .9);
	COLOR = vec4(col.rgb,1);
}
