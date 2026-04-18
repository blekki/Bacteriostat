shader_type canvas_item;

uniform vec4 color_a = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 color_b = vec4(1.0, 1.0, 0.0, 1.0);
uniform float frequency : hint_range(1.0, 200.0) = 100.0;
uniform float speed : hint_range(-10.0, 10.0) = 2.0;

void fragment() {
	float wave = sin((FRAGCOORD.x + FRAGCOORD.y) * frequency + TIME * speed);
    float limit = step(0.5, wave);
	COLOR = mix(color_b, color_a, limit);
}