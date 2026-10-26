extends Label

@export var info: Board


func _ready() -> void:
	if info == null:
		push_error("You haven't assigned the board to the UI honey...")
		return
	info.state_changed.connect(_on_board_state_changed)
	_on_board_state_changed(info.data.turn, info.data.winner)


func _on_board_state_changed(playing: BoardData.Player, winner: BoardData.Player) -> void:
	if winner != BoardData.Player.NOBODY:
		text = _player_name(winner) + " wins!\n\nRestart the game to play again."
		return

	var lines: PackedStringArray = []
	lines.append(_player_name(playing) + "'s turn")
	lines.append(_mode_text())
	lines.append("")
	lines.append(_player_name(BoardData.Player.PLAYER_A) + " walls left: " + str(info.data.data_a.remaining_walls))
	lines.append(_player_name(BoardData.Player.PLAYER_B) + " walls left: " + str(info.data.data_b.remaining_walls))
	lines.append("")
	lines.append("Space: switch move / wall    Right-click: rotate")
	lines.append("Left-click: lock wall    Enter: place    Esc: unlock")
	text = "\n".join(lines)


func _mode_text() -> String:
	if info.mode == Board.Modes.MOVE:
		return "Mode: MOVE (click a tile next to your pawn)"
	if info.locked:
		return "Mode: WALL (locked, press Enter to place)"
	return "Mode: WALL (aim with the mouse, left-click to lock)"


func _player_name(player: BoardData.Player) -> String:
	return BoardData.Player.keys()[player].capitalize()
