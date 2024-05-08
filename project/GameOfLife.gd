extends TileMap


@export var size: int = 80

@onready var camera = $Camera2D
const OFFSET = 320
const LIVE_CELL = Vector2i(0,0)
const DEAD_CELL = Vector2i(1,0)
const CURSOR_TILE = Vector2i(0,1)
const BASE_SPEED = 0.25
const SPEED_INCREMENT = 0.8
const SPEED_DECREMENT = 1.25

var cursor: Vector2i
var board: Array = []
var play_timer: Timer
var play_time = BASE_SPEED

func _ready():
	var c_zoom: float = 80.0 / size
	var c_offset: float = OFFSET / c_zoom
	camera.position = Vector2(c_offset, c_offset)
	camera.zoom = Vector2(c_zoom,c_zoom)
	for i in range(0,size):
		board.append([])
		for j in range(0,size):
			board[i].append(false)
	draw_board()
	play_timer = Timer.new()
	add_child(play_timer)
	play_timer.timeout.connect(step)
	


func draw_board():
	for i in range(0,size):
		for j in range(0,size):
			draw_tile(i, j)


func draw_tile(i: int, j: int):
	if board[i][j]:
		set_cell(0, Vector2i(i,j), 0, LIVE_CELL)
	else:
		set_cell(0, Vector2i(i,j), 0, DEAD_CELL)


func _process(delta):
	var new_cursor = local_to_map(get_global_mouse_position())
	if cursor != new_cursor:
		erase_cell(1, cursor)
		set_cell(1, new_cursor, 0, Vector2i(0, 1))
		cursor = new_cursor
		if Input.is_action_pressed("action"):
			invert_cursor()


func _input(event):
	if event.is_action_pressed("action"):
		invert_cursor()
	if event.is_action_pressed("next_frame"):
		step()
	if event.is_action_pressed("pause"):
		toggle_playing()
	if event.is_action_pressed("slow_down"):
		change_play_speed(SPEED_DECREMENT)
	if event.is_action_pressed("speed_up"):
		change_play_speed(SPEED_INCREMENT)


func invert_cursor():
	if !is_valid_cell(cursor.x, cursor.y):
		return
	board[cursor.x][cursor.y] = !board[cursor.x][cursor.y]
	draw_tile(cursor.x, cursor.y)


func is_valid_cell(x,y) -> bool:
	return x >= 0 and y >= 0 and x < size and y < size


var offsets: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.ONE, Vector2i.UP, Vector2i(-1,1),
								Vector2i.LEFT, Vector2i(-1,-1), Vector2i.DOWN, Vector2i(1,-1)]
func step():  # Scrap this and just use an array bruv
	var old_board = board.duplicate(true)
	for i in range(size):
		for j in range(size):
			var neibhors = 0
			for k in range(8):
				var neibhor: Vector2i = Vector2i(i,j) + offsets[k]
				if is_valid_cell(neibhor.x, neibhor.y) and old_board[neibhor.x][neibhor.y]:
					neibhors += 1
					
			if board[i][j]:
				if neibhors < 2 or neibhors > 3:
					board[i][j] = false
					draw_tile(i, j)
			else:  # Cell is dead chat
				if neibhors == 3:
					board[i][j] = true
					draw_tile(i, j)


func toggle_playing():
	if play_timer.is_stopped():
		play_timer.start(play_time)
	else:
		play_timer.stop()


func change_play_speed(del):
	play_time *= del
	play_timer.start(play_time)
