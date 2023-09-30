extends Node3D

@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]


@export var map_length:int = 16
@export var map_height:int = 10

@export var min_path_size = 50
@export var max_path_size = 70
@export var min_loops = 3
@export var max_loops = 5

var _pg:PathGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	_pg = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	_pop_along_grid()
	
func _add_curve_point(c3d:Curve3D, v3:Vector3) ->bool:
	c3d.add_point(v3)
	return true
	
func _pop_along_grid():
	var box = tile_enemy.instantiate()
	
	var c3d:Curve3D = Curve3D.new()
	
	for element in _pg.get_path():
		c3d.add_point(Vector3(element.x, 0.4, element.y))

	var p3d:Path3D = Path3D.new()
	add_child(p3d)
	p3d.curve = c3d
	
	var pf3d:PathFollow3D = PathFollow3D.new()
	p3d.add_child(pf3d)
	pf3d.add_child(box)
	
	var curr_distance:float = 0.0
	
	while curr_distance < c3d.point_count-1:
		curr_distance += 0.02
		pf3d.progress = clamp(curr_distance, 0, c3d.point_count-1.00001)
		await get_tree().create_timer(0.01).timeout

func _complete_grid():
	for x in range(map_length):
		for y in range(map_height):
			if not _pg.get_path().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
	
func _display_path():
	var iteration_count:int = 1
	_pg.generate_path(true)

	while _pg.get_path().size() < min_path_size or _pg.get_path().size() > max_path_size or _pg.get_loop_count() < min_loops or _pg.get_loop_count() > max_loops:
		iteration_count += 1
		_pg.generate_path(true)

	print("Generated a path of %d tiles after %d iterations" % [_pg.get_path().size(), iteration_count])
	print(_pg.get_path())
	
	
	for i in range(_pg.get_path().size()):
		var tile_score:int = _pg.get_tile_score(i)
		
		var tile:Node3D = tile_empty[0].instantiate()
		var tile_rotation: Vector3 = Vector3.ZERO
		
		if tile_score == 2:
			tile = tile_end.instantiate()
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
		elif tile_score == 15:
			tile = tile_crossroads.instantiate()
			tile_rotation = Vector3(0,0,0)
			
		add_child(tile)
		tile.global_position = Vector3(_pg.get_path_tile(i).x, 0, _pg.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation
	

