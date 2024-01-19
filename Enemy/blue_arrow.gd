extends Area2D
@onready var ray_cast = $RayCast2D
@onready var HitBox = $HitBox
const BASE_SPEED = 20
var speed = BASE_SPEED
var damage = 20
var direction : Vector2 = Vector2.RIGHT
var final_des = Vector2.ZERO
var player

func _ready():
	player = get_parent().find_child("Player")
	final_des = transform.x * speed * 10000
	pass

func _physics_process(delta):
	position += transform.x * speed * delta
	_aim()
	#_check_collision()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _aim():
	ray_cast.target_position = to_local(final_des)
	
func _check_collision():
	if ray_cast.get_collider() == player:
		return 1
	else: 
		return 0

func get_HitBox_size():
	return HitBox.get("shape").get_size()


func _on_area_entered(area):
	var body = area.get_parent()
	if body.has_method("take_damage"):
		body.take_damage(damage)
		

func increment_speed(increment):
	speed += (increment/5.0)
	#print(speed)
	
