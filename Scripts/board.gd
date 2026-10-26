class_name Board
extends Node3D

signal state_changed( playing :BoardData.Player, winning : BoardData.Player)

enum Modes {MOVE,WALL}

var mode:Modes=Modes.MOVE

var data: BoardData = BoardData.new()

@export var player_mesh : Mesh = null
@export var wall_mesh : Mesh = BoxMesh.new()
@export var spacing : float=0.1
@export var cell_scale : Vector3= Vector3(1,0.3,1)
@export var tile_blueprint: PackedScene
@export var wall_height: float = 0.5

@export var player_a_color:Color=Color(1,0,0)
@export var player_b_color:Color=Color(0,0,1)

var material_a:StandardMaterial3D
var material_b:StandardMaterial3D

var locked: bool = false
var wall_center: Vector2i


var pr_wall_orientation:BoardData.WallOrientation=BoardData.WallOrientation.HORIZONTAL

var transl:Grid_World_Translator

var player_mesh_a : MeshInstance3D 
var player_mesh_b : MeshInstance3D

var preview_wall : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	transl=Grid_World_Translator.new(cell_scale,spacing,data.grid_size_x,data.grid_size_z)

	if tile_blueprint == null :
		push_error("tile_bluerprint is not set in the inspector in board")
		return
	
	if player_mesh == null :
		push_error("player_mesh is not set in the inspector in board")
		return
		
	material_a=StandardMaterial3D.new()
	material_b=StandardMaterial3D.new()
	
	material_a.albedo_color=player_a_color
	material_b.albedo_color=player_b_color
		
	for i in range(0,data.grid_size_z):
		for j in range(0,data.grid_size_x):
			
			var tile := tile_blueprint.instantiate() as Tile
			if tile == null:
				push_error("tile_blueprint is not an Enemy Scene")
				return
			var grid_pos : Vector2i=Vector2i(j,i)
			var world_pos: Vector3=transl.grid_to_world(grid_pos,-cell_scale.y/2)
			tile.position=world_pos
			tile.grid_pos=grid_pos
			tile.click.connect(_on_tile_clicked)
			tile.tile_size=cell_scale
			add_child(tile)
			
			#print(i,j, " | was instatiated", " and mesh was set", " and position was set")
	player_mesh_a = MeshInstance3D.new()
	player_mesh_a.mesh=player_mesh
	player_mesh_a.material_override=material_a
	add_child(player_mesh_a)
	player_mesh_b = MeshInstance3D.new()
	player_mesh_b.mesh=player_mesh
	player_mesh_b.material_override=material_b
	add_child(player_mesh_b)
	update_pawns()
	
	preview_wall = MeshInstance3D.new()
	preview_wall.mesh= wall_mesh
	preview_wall.mesh.size=Vector3(cell_scale.x*2+spacing,wall_height,0.9*spacing)
	add_child(preview_wall)
	preview_wall.hide()
	
			
func update_pawns() -> void :
	player_mesh_a.position=transl.grid_to_world(data.data_a.position,0.5)
	player_mesh_b.position=transl.grid_to_world(data.data_b.position,0.5)
	
#	Handler function that commes from the emisiion of the tile signal
func _on_tile_clicked(pos:Vector2i) -> void :
	if mode==Modes.WALL:
		return
	
	print("the board received the following click: ", pos)
	var move_happened:bool=data.try_move(pos)
	if move_happened:
		update_pawns()
		state_changed.emit(data.turn,data.winner)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("toggle_mode"):
		if mode==Modes.MOVE:
			mode=Modes.WALL
			
			print("the mode was set to WALL" )
		else:
			mode=Modes.MOVE
			locked=false
			preview_wall.hide()
			print("the mode was set to MOVE" )
		state_changed.emit(data.turn, data.winner)
	if event is InputEventMouseMotion and mode==Modes.WALL and not locked:
		var cam:Camera3D = get_viewport().get_camera_3d()
		var origin: Vector3 = cam.project_ray_origin(event.position)
		var ray_dir: Vector3 = cam.project_ray_normal(event.position)
		var surface:Plane = Plane(Vector3.UP,0)
		var intersection: Variant =surface.intersects_ray(origin,ray_dir)
		if intersection==null:
			return
		var wall_pos:Vector2i=transl.world_to_wall_grid(intersection)
		if wall_pos.x < 0 or wall_pos.y<0 or wall_pos.x>data.grid_size_x-2 or wall_pos.y>data.grid_size_z-2 :
			preview_wall.hide() 
		else:
			preview_wall.position= transl.wall_grid_to_world(wall_pos,wall_height/2)
			wall_center=wall_pos
			preview_wall.show()
			_set_color_by_player(preview_wall,data.turn)
	if event.is_action_pressed("rotate_wall") and mode==Modes.WALL and not locked:
		if pr_wall_orientation==BoardData.WallOrientation.HORIZONTAL:
			pr_wall_orientation=BoardData.WallOrientation.VERTICAL
			preview_wall.rotation_degrees.y=90
		else:
			pr_wall_orientation=BoardData.WallOrientation.HORIZONTAL
			preview_wall.rotation_degrees.y=0
	
	if event.is_action_pressed("confirm_wall") and mode==Modes.WALL and preview_wall.visible and locked:
		var turn_placer:BoardData.Player=data.turn
		if data.try_place_wall(wall_center,pr_wall_orientation):
			var new_wall:MeshInstance3D= MeshInstance3D.new()
			new_wall.mesh=wall_mesh
			new_wall.position=transl.wall_grid_to_world(wall_center,wall_height/2)
			new_wall.rotation_degrees.y=preview_wall.rotation_degrees.y
			_set_color_by_player(new_wall,turn_placer)
			add_child(new_wall)
			locked=false
			preview_wall.hide()
			mode=Modes.MOVE
			state_changed.emit(data.turn,data.winner)
		else:
			print("you cannot build there")
			

	
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.is_pressed() and mode==Modes.WALL and preview_wall.visible:
		locked= not locked
		state_changed.emit(data.turn, data.winner)
		
	if event.is_action_pressed("cancel_wall") and mode==Modes.WALL and locked:
		locked=false
		state_changed.emit(data.turn, data.winner)
		
	
func _set_color_by_player( object:MeshInstance3D, current_player:BoardData.Player) -> void:
	if current_player==BoardData.Player.PLAYER_A:
		object.material_override=material_a
	elif current_player==BoardData.Player.PLAYER_B:
		object.material_override=material_b
	else:
		print("something is wrong in setting a color")
		
