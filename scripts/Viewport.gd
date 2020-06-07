extends Viewport


func _ready():
	$Camera2D.target = $Level.p
	$Camera2D.limit_top = 0
	$Camera2D.limit_bottom = max(size.y, $Level.height * Global.TILE_HEIGHT)
	$Camera2D.limit_left = 0
	$Camera2D.limit_right = max(size.x, $Level.width * Global.TILE_WIDTH)
	
