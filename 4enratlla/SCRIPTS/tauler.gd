class_name Tauler extends TextureRect
# Tauler i fitxes, amb comprovació del 4 en ratlla

# constants

const N_FILES = 7
const N_COL = 8
const OFFSET = Vector2(66, 0)
const DElTA_X := 90

# atributs 
@onready var _capa = $CanvasLayer
@onready var _J1 = $Jugador1
@onready var _PNJ = $Ordinador
@onready var _GR= $Graella
var _tau:Array = []
var _primeraFilaBuida:Array

# Es crida quan el node entra a l'arbre de l'escena per primera vegada.
func _ready():
	
	for i in range(N_FILES):
		_tau.append([])
		for j in range(N_COL):
			_tau[i].append(' ')
	for i in range(N_COL):
		_primeraFilaBuida.append(N_FILES-1)
	var gra:Sprite2D
	
	gra = _GR.duplicate()
	_GR.hide()
	gra.position = gra.position + Vector2(10, 35)
	_capa.add_child(gra)

func fila_plena(quiTira:String,col:int):
	var fil = _primeraFilaBuida [col]
	if fil < 0:
		if quiTira == "huma":
			print("columna plena")
			Global.torn = 1
		elif quiTira == "PC" :
			tira_fitxa(quiTira,col+1)

func tira_fitxa(quiTira:String, col:int):
	var fil = _primeraFilaBuida [col]
	if fil < 0:
		if quiTira == "huma":
			print("columna plena")
			Global.torn = 1
		elif quiTira == "PC" :
			fila_plena(quiTira,col)
			
	else:
		var f:RigidBody2D
		if quiTira == "huma":
			f = _J1.duplicate ()
			_tau[fil][col] = 'x'
		else:
			f = _PNJ.duplicate()
			_tau[fil][col] = 'O'
		var pos:Vector2
		_primeraFilaBuida [col] -=1
		pos = Vector2(OFFSET+Vector2(DElTA_X*col,0))
		f.position = pos
		f.linear_velocity = Vector2(0,0)
		_capa.add_child(f)
		f.z_index = -10
		var gra:Sprite2D
		gra = _GR.duplicate()
		gra.position = gra.position + Vector2(10, 45)
		_capa.add_child(gra)

# Es crida cada frame. 'delta' és el temps transcorregut des del frame anterior.
func _process(delta):
	check_win_condition()
	Global.Guanyador = check_win_condition()
	if Global.Guanyador == 1:
		await get_tree().create_timer(2).timeout
		get_node("/root/Global").g_canvi_escena("Fi")
	if Global.Guanyador == 2:
		await get_tree().create_timer(2).timeout
		get_node("/root/Global").g_canvi_escena("Fi")
	if Global.PC == false:
		
		if Global.torn == 1: 
			$F1.show()
			$F1.position = Vector2(get_global_mouse_position().x, -20)
			if Input.is_action_just_pressed("left_mouse_click") and Global.torn == 1:
				$F1.hide()
				var fil = _primeraFilaBuida[roundf(get_global_mouse_position().x/DElTA_X)-1]
				if fil < 0:
					Global.torn = 1
					print("columna plena Jugador 1")
				else:
					tira_fitxa("huma", roundf(get_global_mouse_position().x/DElTA_X)-1)
					Global.torn = 2
				
		elif Global.torn == 2: 
			$F2.show()
			$F2.position = Vector2(get_global_mouse_position().x, -20)
			if Input.is_action_just_pressed("left_mouse_click") and Global.torn == 2:
				$F2.hide()
				var fil = _primeraFilaBuida[roundf(get_global_mouse_position().x/DElTA_X)-1]
				if fil < 0:
					Global.torn = 2
					print("columna plena Jugador 2")
				else:
					tira_fitxa("J2", roundf(get_global_mouse_position().x/DElTA_X)-1)
					Global.torn = 1
	elif Global.PC:
		if Global.torn == 1: 
			$F1.show()
			$F1.position = Vector2(get_global_mouse_position().x, -20)
			if Input.is_action_just_pressed("left_mouse_click") and Global.torn == 1:
				$F1.hide()
				var fil = _primeraFilaBuida[roundf(get_global_mouse_position().x/DElTA_X)-1]
				if fil < 0:
					Global.torn = 1
					print("columna plena Jugador 1")
				else:
					tira_fitxa("huma", roundf(get_global_mouse_position().x/DElTA_X)-1)
					await get_tree().create_timer(0.5).timeout 
					Global.torn = 2
		elif Global.torn == 2:
			tira_fitxa("PC", Next_PC_Move())
			Global.torn = 1
			

func Next_PC_Move():
	if troba_millor_moviment() > 0:
		return troba_millor_moviment()
	else:
		return randi() % N_COL

func troba_millor_moviment():
	# Comprova la victòria vertical del jugador
	for fil in range(N_FILES - 2):  # Només cal comprovar fins la 4a fila des de baix
		for col in range(N_COL):
			if _tau[fil][col] == 'O' and _tau[fil+1][col] == 'O' and _tau[fil+2][col] == 'O':
				if _primeraFilaBuida[col] == fil-1:
					return col
			elif _tau[fil][col] == 'x' and _tau[fil+1][col] == 'x' and _tau[fil+2][col] == 'x':
				if _primeraFilaBuida[col] == fil-1:
					return col
	# Comprova horitzontalment
	for fil in range(N_FILES):
		for col in range(N_COL - 2):  # Mirem apartir de la 5a columna
			if _tau[fil][col] == 'O' and _tau[fil][col+1] == 'O' and _tau[fil][col+2] == 'O':
				if col+3 < N_COL and _primeraFilaBuida[col+3] == fil:
					return col+3
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil:
					return col-1
			elif _tau[fil][col] == 'x' and _tau[fil][col+1] == 'x' and _tau[fil][col+2] == 'x':
				if col+3 < N_COL and _primeraFilaBuida[col+3] == fil:
					return col+3
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil:
					return col-1
	# Comprova diagonal (dalt-esquerra a baix-dreta)
	for fil in range(N_FILES - 2):
		for col in range(N_COL - 2):
			if _tau[fil][col] == 'O' and _tau[fil+1][col+1] == 'O' and _tau[fil+2][col+2] == 'O':
				if col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:
					return col-1
				elif col+3 < N_COL and _primeraFilaBuida[col+3] == fil+3:
					return col+3
			elif _tau[fil][col] == 'x' and _tau[fil+1][col+1] == 'x' and _tau[fil+2][col+2] == 'x':
				if col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:
					return col-1
				elif col+3 < N_COL and _primeraFilaBuida[col+3] == fil+3:
					return col+3
	# Comprova diagonal (dalt-dreta a baix-esquerra)
	for fil in range(N_FILES - 2):
		for col in range(2, N_COL):
			if _tau[fil][col] == 'O' and _tau[fil+1][col-1] == 'O' and _tau[fil+2][col-2] == 'O':
				if col+3 < N_COL and _primeraFilaBuida[col+3] == fil-3:  # Si el següent moviment està disponible
					return col+3
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil+1:  # Si el següent moviment està disponible
					return col-1
			elif _tau[fil][col] == 'x' and _tau[fil+1][col-1] == 'x' and _tau[fil+2][col-2] == 'x':
				if col+3 < N_COL and _primeraFilaBuida[col+3] == fil+3:  # Si el següent moviment està disponible
					return col+3
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:  # Si el següent moviment està disponible
					return col-1
	for fil in range(N_FILES - 1):  # Només cal comprovar fins la 5a fila des de baix
		for col in range(N_COL):
			if _tau[fil][col] == 'O' and _tau[fil+1][col] == 'O':
				if _primeraFilaBuida[col] == fil-1:
					return col
			elif _tau[fil][col] == 'x' and _tau[fil+1][col] == 'x':
				if _primeraFilaBuida[col] == fil-1:
					return col

	# Comprova horitzontal
	for fil in range(N_FILES):
		for col in range(N_COL - 1):  # Comencem des de la 5a columna
			if _tau[fil][col] == 'O' and _tau[fil][col+1] == 'O':
				if col+2 < N_COL and _primeraFilaBuida[col+2] == fil:
					return col+2
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil:
					return col-1
			elif _tau[fil][col] == 'x' and _tau[fil][col+1] == 'x':
				if col+2 < N_COL and _primeraFilaBuida[col+2] == fil:
					return col+2
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil:
					return col-1

	# Comprova diagonal (dalt-esquerra a baix-dreta)
	for fil in range(N_FILES - 1):
		for col in range(N_COL - 1):
			if _tau[fil][col] == 'O' and _tau[fil+1][col+1] == 'O':
				if col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:
					return col-1
				elif col+2 < N_COL and _primeraFilaBuida[col+2] == fil+2:
					return col+2
			elif _tau[fil][col] == 'x' and _tau[fil+1][col+1] == 'x':
				if col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:
					return col-1
				elif col+2 < N_COL and _primeraFilaBuida[col+2] == fil+2:
					return col+2

	# Comprova diagonal (dalt-dreta a baix-esquerra)
	for fil in range(N_FILES - 1):
		for col in range(1, N_COL):
			if _tau[fil][col] == 'O' and _tau[fil+1][col-1] == 'O':
				if col+2 < N_COL and _primeraFilaBuida[col+2] == fil-1:
					return col+2
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil+1:
					return col-1
			elif _tau[fil][col] == 'x' and _tau[fil+1][col-1] == 'x':
				if col+2 < N_COL and _primeraFilaBuida[col+2] == fil+3:
					return col+2
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil-1:
					return col-1
	for fil in range(N_FILES):
		for col in range(N_COL):
			if _tau[fil][col] == 'x':
				if col+1 < N_COL and _primeraFilaBuida[col+1] == fil:
					return col+1
				elif col-1 >= 0 and _primeraFilaBuida[col-1] == fil:
					return col-1
	return -1
func check_win_condition():
	# Comprova horitzontal
	for fil in range(N_FILES):
		for col in range(N_COL - 3):  # Només cal comprovar fins la 4a columna per la dreta
			if _tau[fil][col] == 'x' and _tau[fil][col+1] == 'x' and _tau[fil][col+2] == 'x' and _tau[fil][col+3] == 'x':
				print("Jugador 1 guanya horitzontalment")
				return 1
			elif _tau[fil][col] == 'O' and _tau[fil][col+1] == 'O' and _tau[fil][col+2] == 'O' and _tau[fil][col+3] == 'O':
				print("Jugador 2 guanya horitzontalment")
				return 2

# Comprova vertical
	for fil in range(N_FILES - 3):  # Només cal comprovar fins la 4a fila per baix
		for col in range(N_COL):
			if _tau[fil][col] == 'x' and _tau[fil+1][col] == 'x' and _tau[fil+2][col] == 'x' and _tau[fil+3][col] == 'x':
				print("Jugador 1 guanya verticalment")
				return 1
			elif _tau[fil][col] == 'O' and _tau[fil+1][col] == 'O' and _tau[fil+2][col] == 'O' and _tau[fil+3][col] == 'O':
				print("Jugador 2 guanya verticalment")
				return 2

	# Comprova diagonal (dalt-esquerra a baix-dreta)
	for fil in range(N_FILES - 3):
		for col in range(N_COL - 3):
			if _tau[fil][col] == 'x' and _tau[fil+1][col+1] == 'x' and _tau[fil+2][col+2] == 'x' and _tau[fil+3][col+3] == 'x':
				print("Jugador 1 guanya diagonalment (dalt-esquerra a baix-dreta)")
				return 1
			elif _tau[fil][col] == 'O' and _tau[fil+1][col+1] == 'O' and _tau[fil+2][col+2] == 'O' and _tau[fil+3][col+3] == 'O':
				print("Jugador 2 guanya diagonalment (dalt-esquerra a baix-dreta)")
				return 2

	# Comprova diagonal (dalt-dreta a baix-esquerra)
	for fil in range(N_FILES - 3):
		for col in range(3, N_COL):
			if _tau[fil][col] == 'x' and _tau[fil+1][col-1] == 'x' and _tau[fil+2][col-2] == 'x' and _tau[fil+3][col-3] == 'x':
				print("Jugador 1 guanya diagonalment (dalt-dreta a baix-esquerra)")
				return 1
			elif _tau[fil][col] == 'O' and _tau[fil+1][col-1] == 'O' and _tau[fil+2][col-2] == 'O' and _tau[fil+3][col-3] == 'O':
				print("Jugador 2 guanya diagonalment (dalt-dreta a baix-esquerra)")
				return 2
