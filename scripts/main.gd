extends Node3D

@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]

## Assumes the path generator has finished, and adds the remaining tiles to fill in the grid.
func _ready():
	_complete_grid()
	
	await get_tree().create_timer(2).timeout
	_pop_along_grid()
	
func _pop_along_grid():
	var box = tile_enemy.instantiate()
	
	var c3d:Curve3D = Curve3D.new()
	
	for element in PathGenInstance.get_path_route():
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
	for x in range(PathGenInstance.path_config.map_length):
		for y in range(PathGenInstance.path_config.map_height):
			if not PathGenInstance.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)
	
	
	for i in range(PathGenInstance.get_path_route().size()):
		var tile_score:int = PathGenInstance.get_tile_score(i)
		
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
		tile.global_position = Vector3(PathGenInstance.get_path_tile(i).x, 0, PathGenInstance.get_path_tile(i).y)
		tile.global_rotation_degrees = tile_rotation
