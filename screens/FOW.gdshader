shader_type canvas_item;

// ========== TEXTURE & POSITION DATA ==========
uniform sampler2D exploration_texture; // Records where player has visited
uniform vec2 player_pos;               // Current position of player in world coordinates
uniform vec2 texture_size;             // Size of the world texture

// ========== FOG OF WAR COLORS ==========
uniform vec4 fog_color;                // Color for unexplored areas (black)
uniform vec4 explored_color;           // Color for explored areas (gray)

// ========== VISUAL SETTINGS ==========
uniform float sight_radius;                  // Player's sight radius
uniform float blur_edge = 5.0;         // How soft the edge of sight radius is
uniform float explored_blur = 0.7;     // How soft the explored area edges are

void fragment() {
    // Convert UV coordinates to world pixel coordinates
    vec2 pixel_pos = UV * texture_size;

    // Calculate how far this pixel is from the player
    float distance_from_player = distance(pixel_pos, player_pos);

    // Get this pixel's exploration data from the exploration map
    vec4 explore_data = texture(exploration_texture, UV);
    bool has_been_explored = explore_data.a > 0.0;

    // ===== VISIBILITY ZONES =====

    // ZONE 1: VISIBLE AREA - Currently in player's sight
    if (distance_from_player <= sight_radius - blur_edge) {
        // Fully transparent - player can see everything
        COLOR = vec4(0.0);
    }
    // ZONE 2: TRANSITION EDGE - Soft edge of player's sight
    else if (distance_from_player <= sight_radius + blur_edge) {
        // Smooth transition from transparent to explored
        float edge_blend = smoothstep(sight_radius + blur_edge, sight_radius - blur_edge, distance_from_player);
        COLOR = mix(explored_color, vec4(0.0), edge_blend);
    }
    // ZONE 3: EXPLORED AREA - Player has been here before
    else if (has_been_explored) {
        // Soft fade from gray (explored) to black (unexplored)
        float explore_blend = smoothstep(0.0, explored_blur, explore_data.a);
        COLOR = mix(fog_color, explored_color, explore_blend);
    }
    // ZONE 4: UNEXPLORED - Never visited
    else {
        // Solid black fog
        COLOR = fog_color;
    }
}
