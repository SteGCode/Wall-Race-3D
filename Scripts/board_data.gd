extends RefCounted


class_name BoardData

var grid_size_x:int = 11
var grid_size_z : int = 11

enum Player {PLAYER_A,PLAYER_B,NOBODY}
enum WallOrientation {VERTICAL,HORIZONTAL}
var walls: Dictionary[Vector2i,WallOrientation]= {}



var turn:Player=Player.PLAYER_A

var winner:Player=Player.NOBODY

var data_a:PlayerData=PlayerData.new()
var data_b:PlayerData=PlayerData.new()

var init_pos_a:Vector2i=Vector2i(grid_size_x/2,grid_size_z-1)
var init_pos_b:Vector2i=Vector2i(grid_size_x/2,0)

var number_of_walls:int=12

func _init() -> void:
	data_a.position=init_pos_a
	data_a.remaining_walls=number_of_walls
	data_b.position=init_pos_b
	data_b.remaining_walls=number_of_walls
	print("player a is at : ",init_pos_a, " and player be is at : ", init_pos_b)



func is_move_legal(target_square:Vector2i) -> bool:
	var current_pos: Vector2i= get_player(turn).position
	var diff:Vector2i=current_pos-target_square
	
	if winner!=Player.NOBODY:
		return false
	if abs(diff.x)+abs(diff.y)!=1 :
		return false
	if (target_square.x < 0 or target_square.x > grid_size_x-1):
		return false
	if (target_square.y <0 or target_square.y > grid_size_z-1):
		return false
	if _is_wall_between(current_pos,target_square):
		return false
	if (target_square==get_player(opponent(turn)).position):
		return false
	
	return true
	
func get_player(id:Player)-> PlayerData: 
	var player:PlayerData
	if id==Player.PLAYER_A :
		player=data_a
	elif id==Player.PLAYER_B:
		player=data_b
	else:
		push_error("no one is playing the Player is : ",id)
	return player
	
func opponent(id:Player) -> Player:
	if id==Player.PLAYER_A:
		return Player.PLAYER_B
	elif id==Player.PLAYER_B:
		return Player.PLAYER_A
	else:
		push_error("there is no player and thus there is no opponent :", id)
		return Player.NOBODY
		
func try_move(spot:Vector2i) -> bool :
	var playing:PlayerData=get_player(turn)
	
	if not is_move_legal(spot):
		return false
	playing.position=spot
	
	if (playing == data_a and spot.y == 0) or (playing == data_b and  spot.y == grid_size_z-1):
		winner=turn
		return true
		
	turn=opponent(turn)
	
	return true
	
func _is_wall_between(a:Vector2i,b:Vector2i) -> bool:
	var smaller:Vector2i=a.min(b)
	if _is_move_along_y(a,b):
		if _has_wall(Vector2i(smaller.x-1,smaller.y),WallOrientation.HORIZONTAL) or _has_wall(Vector2i(smaller.x,smaller.y),WallOrientation.HORIZONTAL):
			return true
		return false
	else:
		if _has_wall(Vector2i(smaller.x,smaller.y-1),WallOrientation.VERTICAL) or _has_wall(Vector2i(smaller.x,smaller.y),WallOrientation.VERTICAL):
			return true
	return false
func _is_move_along_y(a:Vector2i,b:Vector2i) -> bool:
	if a.x==b.x:
		return true
	else : 
		return false

func _has_wall(center:Vector2i,orientation:WallOrientation) -> bool:
	return walls.has(center) and walls[center]==orientation
	

func _can_place_wall(center:Vector2i,orientation:WallOrientation) -> bool:
	
	var right:Vector2i = center + Vector2i(1,0)
	var left:Vector2i = center + Vector2i(-1,0)
	var front:Vector2i = center + Vector2i(0,-1)
	var back:Vector2i = center + Vector2i(0,1)
	
	if winner!=Player.NOBODY:
		print("the game is over")
		return false
	if center.x>grid_size_x-2 or center.y>grid_size_z-2 or center.x<0  or center.y<0:
		print("wall out of grid")
		return false
	if walls.has(center):
		print("id there a wall there already")
		return false
	if orientation==WallOrientation.HORIZONTAL:
		if walls.has(right) and walls[right]==WallOrientation.HORIZONTAL or walls.has(left) and walls[left]==WallOrientation.HORIZONTAL:
			print("walls overlaping")
			return false
	elif walls.has(front) and walls[front]==WallOrientation.VERTICAL or walls.has(back) and walls[back]==WallOrientation.VERTICAL:
			print("wall overlaping")
			return false
	if get_player(turn).remaining_walls <= 0 :
		print("no remaining walls")
		return false
	return true
	
func try_place_wall(center:Vector2i,orientation:WallOrientation) -> bool:
	if not _can_place_wall(center,orientation):
		return false
	walls[center]=orientation
	get_player(turn).remaining_walls -=1
	turn=opponent(turn)
	return true
	
	
	
	
