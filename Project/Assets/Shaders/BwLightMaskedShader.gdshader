shader_type canvas_item;


uniform sampler2D screen_tex_frg_2 : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 n_out2p0;
// Texture2D:2
	n_out2p0 = texture(screen_tex_frg_2, SCREEN_UV);


// FloatFunc:3
	float n_out3p0 = abs(n_out2p0.x);


// Output:0
	COLOR.rgb = vec3(n_out3p0);
	COLOR.a = 1.0;
	// Called for every pixel the material is visible on.
}

void light() {
	LIGHT += vec4(1, 1 ,1, 1);

}
