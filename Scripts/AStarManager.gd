# AStarManager.gd (add as autoload)
extends Node

# Grid settings
var grid_size: float = 2.0  # Size of each grid cell in world units
var world_bounds: Rect2 = Rect2(-1000, -1000, 2000, 2000)  # Adjust to your world size

# Grid data
var grid: Dictionary = {}  # Vector2i (grid coord) -> bool (walkable)
var astar: AStar2D = AStar2D.new()
var chunk_size: int = 50  # Grid cells per chunk
var chunks: Dictionary = {}  # Vector2i (chunk coord) -> Dictionary of cell data

func _ready():
	# Initialize with empty grid - we'll mark obstacles later
	pass

func world_to_grid(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / grid_size),
		floor(world_pos.z / grid_size)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(
		grid_pos.x * grid_size + grid_size/2,
		0,
		grid_pos.y * grid_size + grid_size/2
	)

func set_cell_walkable(grid_pos: Vector2i, walkable: bool):
	var id = _get_cell_id(grid_pos)
	if walkable:
		if not astar.has_point(id):
			astar.add_point(id, Vector2(grid_pos.x, grid_pos.y))
			_connect_to_neighbors(grid_pos)
	else:
		if astar.has_point(id):
			astar.remove_point(id)
	
	# Store in chunk
	var chunk_coord = Vector2i(
		floor(float(grid_pos.x) / chunk_size),
		floor(float(grid_pos.y) / chunk_size)
	)
	if not chunks.has(chunk_coord):
		chunks[chunk_coord] = {}
	chunks[chunk_coord][grid_pos] = walkable

func _get_cell_id(grid_pos: Vector2i) -> int:
	return grid_pos.x * 1000000 + grid_pos.y  # Simple unique ID

func _connect_to_neighbors(grid_pos: Vector2i):
	var id = _get_cell_id(grid_pos)
	var neighbors = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),  # Cardinal
		Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)  # Diagonal
	]
	
	for offset in neighbors:
		var neighbor_pos = grid_pos + offset
		var neighbor_id = _get_cell_id(neighbor_pos)
		if astar.has_point(neighbor_id):
			var weight = 1.0 if abs(offset.x) + abs(offset.y) == 1 else 1.4  # Diagonal cost
			if not astar.are_points_connected(id, neighbor_id):
				astar.connect_points(id, neighbor_id, weight)

func get_path_world(world_start: Vector3, world_end: Vector3) -> Array[Vector3]:
	var start_grid = world_to_grid(world_start)
	var end_grid = world_to_grid(world_end)
	
	var start_id = _get_cell_id(start_grid)
	var end_id = _get_cell_id(end_grid)
	
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return []  # No path
	
	var path_ids = astar.get_id_path(start_id, end_id)
	var world_path: Array[Vector3] = []
	
	for id in path_ids:
		var grid_pos = Vector2i(
			floor(float(id) / 1000000),
			id % 1000000
		)
		world_path.append(grid_to_world(grid_pos))
	
	return world_path

# Load chunk data (call this when loading areas)
func load_chunk(chunk_coord: Vector2i, walkable_cells: Array[Vector2i]):
	for cell in walkable_cells:
		set_cell_walkable(cell, true)

# Mark obstacles (walls, etc)
func mark_obstacle(world_pos: Vector3):
	var grid_pos = world_to_grid(world_pos)
	set_cell_walkable(grid_pos, false)
