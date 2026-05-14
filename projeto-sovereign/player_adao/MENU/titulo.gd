extends Control # Funciona para Label ou RichTextLabel

func _ready():
	# Ajusta o pivô automaticamente para o centro
	pivot_offset = size / 2
	
	# Criamos o Tween
	var tween = create_tween().set_loops()
	
	# ANIMAÇÃO 1: Flutuar (Sobe e desce)
	# 'property_interpolate' no eixo Y
	tween.tween_property(self, "position:y", position.y - 15, 1.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y, 1.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# ANIMAÇÃO 2: Pulsar (Escala)
	# Criamos um segundo tween paralelo para não travar o primeiro
	var tween_scale = create_tween().set_loops()
	tween_scale.tween_property(self, "scale", Vector2(1.1, 1.1), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_scale.tween_property(self, "scale", Vector2(1.0, 1.0), 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
