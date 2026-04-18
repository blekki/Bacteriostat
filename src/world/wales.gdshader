shader_type canvas_item;

instance uniform vec2 viewport_size = vec2(1, 1);

uniform float wales_speed = 1.0;
uniform float roughness = 1.0;
uniform sampler2D noise : repeat_enable;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable;

void fragment() {
	//	wales
	float noise_hight = texture(noise, UV + (TIME * wales_speed)).r * roughness;
	//float noise_hight = texture(simplex_noise, (UV * viewport_size) + (TIME * wales_speed)).r;
	float offset = noise_hight / 200.0;
	COLOR = texture(screen_texture, SCREEN_UV + offset);
}
