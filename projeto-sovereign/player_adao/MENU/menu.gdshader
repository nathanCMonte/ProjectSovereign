shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_speed : hint_range(0.0, 5.0) = 1.0;
uniform float shine_size : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    // Pega a cor que a Godot já ia desenhar (o texto)
    vec4 color = texture(TEXTURE, UV);
    
    // Cria o movimento do brilho (vai de -1.5 a 1.5 para atravessar o texto)
    float time = fract(TIME * shine_speed / 2.0) * 3.0 - 1.5;
    
    // Calcula a faixa de luz inclinada
    float shine = smoothstep(time - shine_size, time, UV.x + UV.y * 0.5) - 
                  smoothstep(time, time + shine_size, UV.x + UV.y * 0.5);
    
    // O SEGREDO: Multiplicamos pelo alpha da textura original
    // Assim o brilho só aparece onde tem letra desenhada
    color.rgb += shine_color.rgb * shine * color.a;
    
    COLOR = color;
}

