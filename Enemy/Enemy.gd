extends CharacterBody2D

@onready var ray_cast = $RayCast2D
@onready var timer = $RedShotTimer
@onready var blueshot_timer = $BlueShotTimer
@onready var rotater = $Rotator
@onready var level = $LevelTimer
@export var ammo : PackedScene

const bullet_scene = preload("res://Enemy/blue_arrow.tscn")
const rotation_speed = 50

var increment = 0.0

const spawn_point_count = 1
const radius = 5
var player
 
func _ready():
	
	var step = 2 * PI / spawn_point_count
	
	for i in range(spawn_point_count):
		var spawn_point = Node2D.new()
		var pos = Vector2(radius, 0).rotated(step * i)
		spawn_point.position = pos
		spawn_point.rotation = pos.angle()
		rotater.add_child(spawn_point)
		
	blueshot_timer.start()
	player = get_parent().find_child("Player")
	level.start()
 

func _physics_process(delta):
	var new_rotation = rotater.rotation_degrees + rotation_speed * delta
	rotater.rotation_degrees = fmod(new_rotation, 360)
	#print(ray_cast.get_collider())

	_aim()
	_check_player_collision()
 
func _aim():
	ray_cast.target_position = to_local(player.global_position)
 
func _check_player_collision():
	if ray_cast.get_collider() == player and timer.is_stopped():
		timer.start()
	elif ray_cast.get_collider() != player and not timer.is_stopped():
		timer.stop()
 

func _shootRed():
	var bullet = ammo.instantiate()
	bullet.increment_speed(increment)
	bullet.position = position
	bullet.direction = (ray_cast.target_position).normalized()
	get_tree().current_scene.add_child(bullet)		
	
func _shootBlue():
	for s in rotater.get_children():
		var bullet = bullet_scene.instantiate()
		bullet.increment_speed(increment)
		bullet.position = s.global_position
		bullet.rotation = s.global_rotation
		get_tree().current_scene.add_child(bullet)
		
func _on_timer_timeout():
	_shootRed()
	pass


func _on_shotgun_timer_timeout():
	_shootBlue()
	pass


func _on_level_timer_timeout():
	increment += 0.5
	#print(increment)
