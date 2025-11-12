shader_type canvas_item;
uniform float base_zoom = 1.2;
uniform float zoom_strength = 0.1; // how much it expands/contracts

void vertex() {
	// Zooms a little bit to prevent the same planets showing at the same time
    float dynamic_zoom = base_zoom;
   UV = (UV - 0.5) / dynamic_zoom + 0.5;
	//scroll speed in x and y direction
UV.x += TIME*.05;
UV.y += TIME*.05;
}

