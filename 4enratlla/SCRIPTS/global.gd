extends Node

#script d'Autoload
const ESC_INICI: = preload("res://SCENES/inici.tscn")
const ESC_TAULER: = preload("res://SCENES/tauler.tscn")
var torn = 1
var Guanyador = 0
var PC = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func g_canvi_escena(escActual:String):
	if escActual == "Inici":
		get_tree().change_scene_to_packed(ESC_TAULER)
	else:
		get_tree().change_scene_to_packed(ESC_INICI)
