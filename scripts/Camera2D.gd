extends Camera2D

var target = null

func _process(delta):
	if target:
		position = Vector2(
			target.position.x+Global.TILE_WIDTH/2,
			target.position.y+Global.TILE_HEIGHT/2
		)
	# makes camera follow its target tightly
	align() 

