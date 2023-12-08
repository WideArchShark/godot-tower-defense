extends Node3D
class_name Enemy

@export var enemy_settings:EnemySettings
@onready var progress_bar = $HealthBar/ProgressBar

var enemy_health:float

signal enemy_finished

var attackable:bool = true
var distance_travelled:float = 0

var path_3d:Path3D
var path_follow_3d:PathFollow3D

func _ready():
#	print("Ready")
	enemy_health = enemy_settings.health
	progress_bar.max_value = enemy_health
	progress_bar.value = enemy_health
	var enemy_mesh = enemy_settings.enemy_scene.instantiate()
	$Path3D/PathFollow3D/Enemy.add_child(enemy_mesh)
	$Path3D.curve = path_route_to_curve_3d()
	$Path3D/PathFollow3D.progress = 0
	
func _on_spawning_state_entered():
	#print("Spawning")
	attackable = true
	progress_bar.visible = false
	$AnimationPlayer.play("spawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_travelling_state")

func _on_travelling_state_entered():
#	print("Travelling")
	attackable = true
	progress_bar.visible = true

func _on_travelling_state_processing(delta):
	distance_travelled += (delta * enemy_settings.speed)
	var distance_travelled_on_screen:float = clamp(distance_travelled, 0, PathGenInstance.get_path_route().size()-1)
	$Path3D/PathFollow3D.progress = distance_travelled_on_screen
	
	if distance_travelled > PathGenInstance.get_path_route().size()-1:
		$EnemyStateChart.send_event("to_damaging_state")

func _on_despawning_state_entered():
	enemy_finished.emit()
	progress_bar.visible = false
	$AnimationPlayer.play("despawn")
	await $AnimationPlayer.animation_finished
	$EnemyStateChart.send_event("to_remove_enemy_state")

func _on_remove_enemy_state_entered():
	queue_free()

func _on_damaging_state_entered():
	attackable = false
	$EnemyStateChart.send_event("to_despawning_state")

func _on_dying_state_entered():
	attackable = false
	progress_bar.visible = false
	$Path3D/PathFollow3D/Enemy.visible = false
	enemy_finished.emit()
	$Path3D/PathFollow3D/Smoke.emitting = true
	$Path3D/PathFollow3D/Explosion.emitting = true
	get_parent_node_3d().cash += enemy_settings.value

	$ExplosionAudio.play()
	#$Path3D/PathFollow3D/enemy_ufoRed2.visible = false
	await $ExplosionAudio.finished
	$EnemyStateChart.send_event("to_remove_enemy_state")
	
func path_route_to_curve_3d() -> Curve3D:
	var c3d:Curve3D = Curve3D.new()
	
	for element in PathGenInstance.get_path_route():
		c3d.add_point(Vector3(element.x, 0.25, element.y))

	return c3d

func _on_area_3d_area_entered(area):
	if area is Projectile:
		enemy_health -= area.damage
		progress_bar.value = enemy_health

	if enemy_health <= 0:
		$EnemyStateChart.send_event("to_dying_state")
