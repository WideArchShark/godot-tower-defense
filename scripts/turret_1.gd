extends Node3D

var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var current_enemy_targetted:bool = false
var acquire_slerp_progress:float = 0

#NEW
var last_fire_time:int
@export var fire_rate_ms:int = 1000
@export var projectile_type:PackedScene

func _on_patrol_zone_area_entered(area):
	#print(area, " entered")
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)
	#print(enemies_in_range.size())

func _on_patrol_zone_area_exited(area):
	#print(area, " exited")
	enemies_in_range.erase(area)
	#print(enemies_in_range.size())

func set_patrolling(patrolling:bool):
	$PatrolZone.monitoring = patrolling
	
func rotate_towards_target(rtarget, delta):
	var target_vector = $Cannon.global_position.direction_to(Vector3(rtarget.global_position.x, global_position.y, rtarget.global_position.z))
	var target_basis:Basis = Basis.looking_at(target_vector)
	$Cannon.basis = $Cannon.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta
	
	if acquire_slerp_progress > 1:
		$StateChart.send_event("to_attacking_state")

func _on_patrolling_state_state_processing(_delta):
	if enemies_in_range.size() > 0:
		# current_enemy = enemies_in_range[enemies_in_range.size()-1]
		current_enemy = enemies_in_range[0]
		$StateChart.send_event("to_acquiring_state")

func _on_acquiring_state_state_entered():
	current_enemy_targetted = false
	acquire_slerp_progress = 0

func _on_acquiring_state_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		rotate_towards_target(current_enemy, delta)
	else:
		#print("Enemy disappeared while acquiring!")
		$StateChart.send_event("to_patrolling_state")

func _on_attacking_state_state_physics_processing(_delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$Cannon.look_at(current_enemy.global_position)
		#NEW
		_maybe_fire()
	else:
		#print("Enemy disappeared!")
		$StateChart.send_event("to_patrolling_state")

#NEW
func _maybe_fire():
	if Time.get_ticks_msec() > (last_fire_time+fire_rate_ms):
		#print("Fire!!")
		var projectile:Projectile = projectile_type.instantiate()
		projectile.starting_position = $Cannon/projectile_spawn.global_position
		projectile.target = current_enemy
		add_child(projectile)
		last_fire_time = Time.get_ticks_msec()
		
func _on_attacking_state_state_entered():
	#print("Taget acquired")
	#NEW
	last_fire_time = 0
