extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	pass
	
	
func _reset():
	var children = get_children()
	for child in children:
		if child.has_method("increment_speed"):			
			child.queue_free()
		if child.has_method("_shootRed"):
			child.increment = 0.0
			
