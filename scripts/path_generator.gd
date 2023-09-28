extends Object
class_name PathGenerator

var _grid_length:int
var _grid_height:int
var _loop_count:int

var _path: Array[Vector2i]

func _init(length:int, height:int):
	_grid_length = length
	_grid_height = height

func generate_path(add_loops:bool = false):
	_path.clear()
	_loop_count = 0
	randomize()
	
	var x = 0
	var y = int(_grid_height/2)
	
	while x < _grid_length:
		if not _path.has(Vector2i(x,y)):
			_path.append(Vector2i(x,y))
		
		var choice:int = randi_range(0,2)

		if choice == 0 or x < 2 or x % 2 == 0 or x == _grid_length-1:
			x += 1
		elif choice == 1 and y < _grid_height-2 and not _path.has(Vector2i(x,y+1)):
			y += 1
		elif choice == 2 and y > 1 and not _path.has(Vector2i(x,y-1)):
			y -= 1
	
	if add_loops:
		# Running add_loops multiple times, as I think the first time it might miss an opportunity.
		# Haven't quite figured out why yet, but adding it twice adds more loops!
		_add_loops()
		_add_loops()
		_add_loops()
		
	return _path

## Used to evaluate where the path tiles are around the given file. Max value
## is 15.
## Score +1 if path tile above (y-1)
## Score +2 if path tile to the right (x+1)
## Score +4 if path tile below (y+1)
## Score +8 if path tile to the left (x-1)
func get_tile_score(index:int) -> int:
	var score:int = 0
	var x = _path[index].x
	var y = _path[index].y
	
	score += 1 if _path.has(Vector2i(x,y-1)) else 0
	score += 2 if _path.has(Vector2i(x+1,y)) else 0
	score += 4 if _path.has(Vector2i(x,y+1)) else 0
	score += 8 if _path.has(Vector2i(x-1,y)) else 0
	
	return score

func get_path() -> Array[Vector2i]:
	return _path

func _add_loops():
	# See if we can add any loops
	for i in range(_path.size()):
		var loop:Array[Vector2i] = _is_loop_option(i)
		if loop.size() > 0:
			for j in range(loop.size()):
				_path.insert(i+1+j, loop[j])

## For a given index in the path, evaluate whether a loop can be generated
## around it.
func _is_loop_option(index:int) -> Array[Vector2i]:
	var x: int = _path[index].x
	var y: int = _path[index].y
	var return_path:Array[Vector2i]

	#Yellow
	if (x < _grid_length-1 and y > 1
		and _tile_loc_free(x, y-3) and _tile_loc_free(x+1, y-3) and _tile_loc_free(x+2, y-3)		
		and _tile_loc_free(x-1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x+1, y-2) and _tile_loc_free(x+2, y-2) and _tile_loc_free(x+3, y-2)
		and _tile_loc_free(x-1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1) and _tile_loc_free(x+3, y-1)
		and _tile_loc_free(x+1,y) and _tile_loc_free(x+2,y) and _tile_loc_free(x+3,y)
		and _tile_loc_free(x+1,y+1) and _tile_loc_free(x+2,y+1)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y-1), Vector2i(x+2,y-2), Vector2i(x+1,y-2), Vector2i(x,y-2), Vector2i(x,y-1)]

		if _path[index-1].y > y:
			return_path.reverse()
			
		_loop_count += 1
#		print("Yellow")
		return_path.append(Vector2i(x,y))
	#Blue
	elif (x > 2 and y > 1
			and _tile_loc_free(x, y-3) and _tile_loc_free(x-1, y-3) and _tile_loc_free(x-2, y-3)		
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x, y-1) and _tile_loc_free(x-2, y-1) and _tile_loc_free(x-3, y-1)
			and _tile_loc_free(x+1, y-2) and _tile_loc_free(x, y-2) and _tile_loc_free(x-1, y-2) and _tile_loc_free(x-2, y-2) and _tile_loc_free(x-3, y-2)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x-2, y+1)):
		return_path = [Vector2i(x,y-1), Vector2i(x,y-2), Vector2i(x-1,y-2), Vector2i(x-2,y-2), Vector2i(x-2,y-1), Vector2i(x-2,y), Vector2i(x-1,y)]
		
		if _path[index-1].x > x:
			return_path.reverse()

		_loop_count += 1
#		print("Blue")
		return_path.append(Vector2i(x,y))
	#Red
	elif (x < _grid_length-1 and y < _grid_height-2
			and _tile_loc_free(x, y+3) and _tile_loc_free(x+1, y+3) and _tile_loc_free(x+2, y+3)		
			and _tile_loc_free(x+1, y-1) and _tile_loc_free(x+2, y-1)
			and _tile_loc_free(x+1, y) and _tile_loc_free(x+2, y) and _tile_loc_free(x+3, y)
			and _tile_loc_free(x-1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x+2, y+1) and _tile_loc_free(x+3, y+1)
			and _tile_loc_free(x-1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x+1, y+2) and _tile_loc_free(x+2, y+2) and _tile_loc_free(x+3, y+2)):
		return_path = [Vector2i(x+1,y), Vector2i(x+2,y), Vector2i(x+2,y+1), Vector2i(x+2,y+2), Vector2i(x+1,y+2), Vector2i(x,y+2), Vector2i(x,y+1)]

		if _path[index-1].y < y:
			return_path.reverse()
		
		_loop_count += 1
#		print("Red")
		return_path.append(Vector2i(x,y))
	# Brown
	elif (x > 2 and y < _grid_height-2
			and _tile_loc_free(x, y+3) and _tile_loc_free(x-1, y+3) and _tile_loc_free(x-2, y+3)
			and _tile_loc_free(x-1, y-1) and _tile_loc_free(x-2, y-1)
			and _tile_loc_free(x-1, y) and _tile_loc_free(x-2, y) and _tile_loc_free(x-3, y)
			and _tile_loc_free(x+1, y+1) and _tile_loc_free(x, y+1) and _tile_loc_free(x-2, y+1) and _tile_loc_free(x-3, y+1)
			and _tile_loc_free(x+1, y+2) and _tile_loc_free(x, y+2) and _tile_loc_free(x-1, y+2) and _tile_loc_free(x-2, y+2) and _tile_loc_free(x-3, y+2)):
		return_path = [Vector2i(x,y+1	), Vector2i(x,y+2), Vector2i(x-1,y+2), Vector2i(x-2,y+2), Vector2i(x-2,y+1), Vector2i(x-2,y), Vector2i(x-1,y)]

		if _path[index-1].x > x:
			return_path.reverse()
		
		_loop_count += 1
#		print("Brown")
		return_path.append(Vector2i(x,y))
		
	return return_path
	
## Returns true if there is a path tile at the x,y coordinate
func _tile_loc_taken(x: int, y: int) -> bool:
	return _path.has(Vector2i(x,y))
	
## Returns true if there is no path tile at the x,y coordinate
func _tile_loc_free(x: int, y: int) -> bool:
	return not _path.has(Vector2i(x,y))
	
func get_loop_count() -> int:
	return _loop_count
	
func get_path_tile(index:int) -> Vector2i:
	return _path[index]
