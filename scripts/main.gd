extends Node3D

@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_empty:PackedScene

@export var map_length:int = 16
@export var map_height:int = 9

var _pg:PathGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	_pg = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()
	
func _complete_grid():
	for x in range(map_length):
		for y in range(map_height):
			if not _pg.get_path().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
	
func _display_path():
	var _path:Array[Vector2i] = _pg.generate_path()
	
	while _path.size() < 30:
		_path = _pg.generate_path()

	for element in _path:
		var tile_score:int = _pg.get_tile_score(element)
		
		var tile:Node3D = tile_empty.instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		
		if tile_score == 2:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,-90,0)
		elif tile_score == 8:
			tile = tile_start.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 10:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 1 or tile_score == 4 or tile_score == 5:
			tile = tile_straight.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 6:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,180,0)
		elif tile_score == 12:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,90,0)
		elif tile_score == 9:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,0,0)
		elif tile_score == 3:
			tile = tile_corner.instantiate()
			tile_rotation = Vector3(0,270,0)
			
		add_child(tile)
		tile.global_position = Vector3(element.x, 0, element.y)
		tile.global_rotation_degrees = tile_rotation
	

