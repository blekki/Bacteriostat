shader_type canvas_item;

uniform float blur : hint_range(0.0, 5.0);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_enable;

void fragment() {
	vec3 raw_color = vec3(1.0, 1.0, 1.0);
	vec3 blur_color = textureLod(screen_texture, SCREEN_UV, blur).rgb;
	COLOR = vec4(blur_color, 1.0);
}
