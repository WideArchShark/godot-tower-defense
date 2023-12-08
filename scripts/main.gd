extends Node3D

@export var tile_start:PackedScene
@export var tile_end:PackedScene
@export var tile_straight:PackedScene
@export var tile_corner:PackedScene
@export var tile_crossroads:PackedScene
@export var tile_enemy:PackedScene
@export var tile_empty:Array[PackedScene]

const BASIC_ENEMY_SETTINGS = preload("res://resources/basic_enemy_settings.res")
const POWER_ENEMY_SETTINGS = preload("res://resources/power_enemy_settings.res")

@export var enemy:PackedScene
@export var enemy_waves:Array[Wave]

var wave_spawned:bool = false
var enemies_remaining = 0

@onready var cam = $Camera3D
var RAYCAST_LENGTH:float = 100

var current_wave_index:int = 0

# NEW
@export var cash:int = 100

## Assumes the path generator has finished, and adds the remaining tiles to fill in the grid.
func _ready():
	_complete_grid()

#NEW
func _process(_delta):
	$Control/CashLabel.text = "Cash $%d" % cash

func _spawn_wave():
	var enemy_wave:Array[EnemySettings] = enemy_waves[current_wave_index].enemies
	wave_spawned = false
	enemies_remaining = 0

	for i in range(enemy_wave.size()):
		
		await get_tree().create_timer(enemy_wave[i].next_enemy_delay).timeout
		print("Instantiating enemy")
		var enemy2:Enemy = enemy.instantiate()
		enemy2.enemy_settings = enemy_wave[i]
		
		add_child(enemy2)
		enemy2.add_to_group("enemies")
		enemies_remaining += 1
		enemy2.connect("enemy_finished", _check_wave)
	
	wave_spawned = true
	#$StateChart.send_event("to_complete")

func _check_wave():
	print("Got here!")
	enemies_remaining -= 1
	if enemies_remaining <= 0 and wave_spawned:
		$StateChart.send_event("to_complete")

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


func _on_start_wave_button_pressed():
	$StateChart.send_event("to_active")


func _on_active_state_entered():
	$StartWaveButton.disabled = true
	_spawn_wave()


func _on_complete_state_entered():
	current_wave_index += 1
	$StartWaveButton.disabled = false
