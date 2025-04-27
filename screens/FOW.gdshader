// fog_shader.gdshader
shader_type canvas_item;

// Parámetros que recibe desde GDScript
uniform sampler2D exploration_texture;
uniform vec2 player_pos;
uniform float radius;
uniform vec4 fog_color;
uniform vec4 explored_color;
uniform vec2 texture_size;

void fragment() {
    vec2 pixel_pos = UV * texture_size;
    float dist = distance(pixel_pos, player_pos);
	
 	// Leer el valor de exploración (ahora usa el canal alpha)
    vec4 explore_data = texture(exploration_texture, UV);
	
    if (dist <= radius) {
        COLOR = vec4(0.0); // Totalmente transparente
    } else if (explore_data.a > 0.5) { // canal alpha
        COLOR = explored_color; // Área explorada
    } else {
        COLOR = fog_color; // No explorado
    }
}