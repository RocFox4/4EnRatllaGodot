class_name Inici extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.Guanyador != 0:
		$Guanyador.set_text("Ha guanyat el Jugador "+str(Global.Guanyador)+"!") 
		

func _on_sortir_pressed():
	get_tree().quit()


func _on_inici_pressed():
	get_node("/root/Global").g_canvi_escena("Inici")


func _on_opcions_pressed():
	get_node("/root/Global").g_canvi_escena("Inici")
	Global.PC = true
