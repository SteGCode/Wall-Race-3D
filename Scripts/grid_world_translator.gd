extends RefCounted

class_name Grid_World_Translator

var cell_scale : Vector3
var spacing : float
var centering_x : float
var centering_z : float
var size_x:float
var size_y:float


func _init(cellscale:Vector3,space:float,gridx:int,gridy:int) -> void:
	cell_scale=cellscale
	spacing =space
	size_x=gridx
	size_y=gridy
	
	centering_x=(gridx*(cell_scale.x+spacing)-(cell_scale.x+spacing))/2
	centering_z=(gridy*(cell_scale.z+spacing)-(cell_scale.z+spacing))/2
	
func grid_to_world(grid_coordinates:Vector2i, height:float) -> Vector3:
	
	var world_x:float=grid_coordinates.x*(cell_scale.x)+(grid_coordinates.x)*spacing - centering_x
	var world_z:float=grid_coordinates.y*(cell_scale.z)+(grid_coordinates.y)*spacing - centering_z
	var result: Vector3
	result.x=world_x
	result.z=world_z
	result.y=height
	return result
	
func world_to_grid(world_coordinates:Vector3) -> Vector2i:
	var world_cell_size_x=cell_scale.x+spacing
	var world_cell_size_z=cell_scale.z+spacing
	var grid_x : int = roundi(world_coordinates.x / world_cell_size_x + (size_x-1)/2)
	var grid_y : int = roundi(world_coordinates.z / world_cell_size_z + (size_y-1)/2)
	return Vector2i(grid_x,grid_y)
	
func world_to_wall_grid(world_coordinates:Vector3) -> Vector2i:
	var world_cell_size_x=cell_scale.x+spacing
	var world_cell_size_z=cell_scale.z+spacing
	var grid_x : int = roundi(world_coordinates.x / world_cell_size_x + (size_x-1)/2-0.5)
	var grid_y : int = roundi(world_coordinates.z / world_cell_size_z + (size_y-1)/2-0.5)
	return Vector2i(grid_x,grid_y)
	
func wall_grid_to_world(wall_centre: Vector2i, height: float) -> Vector3:
	var tile_a: Vector3 = grid_to_world(wall_centre, height)
	var tile_b: Vector3 = grid_to_world(wall_centre + Vector2i(1, 1), height)
	return (tile_a + tile_b) / 2.0
