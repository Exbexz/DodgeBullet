extends Area2D

var damage = 50
var speed = 0
@onready var timer = $Timer


func deal_damage(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_area_entered(area):
	var body = area.get_parent()
	deal_damage(body)
	timer.start()

	
func _on_timer_timeout():
	if has_overlapping_areas():
		var body = get_overlapping_areas()[0].get_parent()
		deal_damage(body)


func _on_area_exited(_area):
	timer.stop()
	timer.wait_time = 1
	
