shader_type canvas_item;

// Pega a imagem da tela que está atrás do retângulo
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Configurações
uniform float pixel_factor : hint_range(1.0, 10.0, 1.0) = 4.0; 
uniform float color_depth : hint_range(1.0, 64.0, 1.0) = 16.0; 

void fragment() {
	// CORREÇÃO AQUI: Usamos SCREEN_PIXEL_SIZE
	// SCREEN_PIXEL_SIZE é o tamanho de um pixel em UV (ex: 1/1920)
	vec2 pixel_size = vec2(pixel_factor) * SCREEN_PIXEL_SIZE;
	
	// Matemática de pixelização
	vec2 uv = floor(SCREEN_UV / pixel_size) * pixel_size;
	
	// Pega a cor
	vec3 color = texture(screen_texture, uv).rgb;
	
	// Redução de Cores
	color = floor(color * color_depth) / color_depth;
	
	COLOR = vec4(color, 1.0);
}