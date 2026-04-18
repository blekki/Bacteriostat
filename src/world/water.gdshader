shader_type canvas_item;

uniform vec4 color = vec4(0.842, 1.0, 0.978, 1.0);
uniform sampler2D gradient : repeat_enable;
uniform sampler2D noise : repeat_enable;

void fragment() {
	vec2 deep = texture(noise, SCREEN_UV + (TIME / 20.0)).rg;
	vec4 new_color = texture(gradient, deep);
	
	//vec3 white = vec3(1.0, 1.0, 1.0); 
	//COLOR = vec4(gradien * deep, 1.0);
	COLOR = new_color;
}
