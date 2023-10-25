extends Node3D

var enemies_in_range:Array[Node3D]

func _on_patrol_zone_area_entered(area):
	print(area, " entered")
	enemies_in_range.append(area.get_node("../../.."))
	print(enemies_in_range.size())

func _on_patrol_zone_area_exited(area):
	print(area, " exited")
	enemies_in_range.erase(area.get_node("../../.."))
	print(enemies_in_range.size())

func set_patrolling(patrolling:bool):
	$PatrolZone.monitoring = patrolling
