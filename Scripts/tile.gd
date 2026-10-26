class_name Tile

extends StaticBody3D


var tile_size:Vector3=Vector3(1,0.3,1)
var grid_pos:Vector2i
var tile_hover_color: Vector3
var tile_click_color: Vector3
signal click(pos:Vector2i)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collid: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	(mesh_instance.mesh as BoxMesh).size=tile_size
	(collid.shape as BoxShape3D).size=tile_size 
	


	
	
	


func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		print(" you clicked at :", grid_pos)
		click.emit(grid_pos)
