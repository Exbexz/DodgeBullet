extends CharacterBody2D


@onready var hp_bar = $HealthBar
@onready var animation_tree = $AnimationTree
@onready var player_vision = $PlayerVision
@onready var ai_controller = $AIController2D
@onready var hurt_box = $HurtBox/CollisionShape2D
@onready var collision = $CollisionShape

var is_colliding

const MAX_HP = 200
const MAX_SPEED = 80

var bullet_detected = false
var array_of_bullet = []  

var poison_detected = false
var array_of_poison = []

var direction : Vector2 = Vector2.ZERO
var speed = MAX_SPEED
var hp = MAX_HP
var slowed = 0.7
var reset_position
var bullet_collided = 0


func _ready():
	reset_position = global_position
	ai_controller.init(self)
	hp_bar.max_value = MAX_HP
	set_health_bar()
 
func _physics_process(_delta):
	
	if ai_controller.heuristic == "human":
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		direction = direction.normalized()
	else:
		direction = ai_controller.move_action
	
	if direction != Vector2.ZERO:
		set_walking(true)
		update_blend_position()
	else:
		set_walking(false)
		
	if bullet_detected:
		
		#print()
		#get_MID(array_of_bullet)
		get_bullet_position(get_nearest_bullet(array_of_bullet))
		#get_nearest_bullet(array_of_bullet) 
		pass
		
	velocity = direction * speed
		
	is_colliding = move_and_slide()
	
	if get_slide_collision_count()>1:
		ai_controller.reward =- 5

	
		
func game_over():
	print("\n---------Result---------")
	print("N_STEPS SURVIVED: ",ai_controller.n_steps)
	print("BULLET COLLIDED: ",bullet_collided)
	print("REWARD: ",ai_controller.reward)
	bullet_collided = 0
	ai_controller.done = true
	ai_controller.needs_reset = true

func set_health_bar():
	hp_bar.value = hp
	
func set_walking(value):
	animation_tree["parameters/conditions/is_walking"] = value
	animation_tree["parameters/conditions/idle"] = not value
 
func update_blend_position():
	animation_tree["parameters/idle/blend_position"] = direction
	animation_tree["parameters/walk/blend_position"] = direction
	
func get_nearest_bullet(array_of_bullet):
	if array_of_bullet.is_empty(): return null
	var distances = []
	var closest_bullets = []
	var index = 0
	
	for bullet in array_of_bullet:
		var distance = global_position.distance_squared_to(bullet.global_position)
		distances.append({"distance": distance, "bullet": bullet})

		index += 1
	
	for i in range(distances.size() - 1):
		for j in range(i + 1, distances.size()):
			if distances[i].distance > distances[j].distance:
				var temp = distances[i]
				distances[i] = distances[j]
				distances[j] = temp
				
	var num_closest = min(10, distances.size())

	# Retrieve the 10 closest bullets
	for i in range(num_closest):
		closest_bullets.append(distances[i].bullet)	
		
	return closest_bullets
 
func get_MID(bullets):
	var MID = []
	
	#var player_top_left = to_local(self.global_transform.origin)
	#var player_bottom_right = to_local(self.global_transform.origin) + hurt_box.get("shape").get_size()
	
	var player_top_left = global_position - Vector2(hurt_box.get("shape").get_size().x/2,hurt_box.get("shape").get_size().y/2)
	var player_bottom_right = global_position + Vector2(hurt_box.get("shape").get_size().x/2,hurt_box.get("shape").get_size().y/2)
	
	player_bottom_right = player_bottom_right.normalized()
	player_top_left = player_top_left.normalized()
	if bullets.is_empty(): return null
	for bullet in bullets:

		#var bullet_top_left = to_local(bullet.global_transform.origin)
		var bullet_top_left = bullet.global_position - Vector2(bullet.get_HitBox_size().x/2,bullet.get_HitBox_size().y/2)
		bullet_top_left = bullet_top_left.normalized()
		
		#var bullet_bottom_right = to_local(bullet.global_transform.origin) + bullet.get_HitBox_size()
		var bullet_bottom_right = bullet.global_position + Vector2(bullet.get_HitBox_size().x/2,bullet.get_HitBox_size().y/2)
		bullet_bottom_right = bullet_bottom_right.normalized()

		var horizontal = [player_bottom_right.x,bullet_bottom_right.x].min() - [player_top_left.x,bullet_top_left.x].max()
		var vertical = [player_bottom_right.y,bullet_bottom_right.y].min() - [player_top_left.y,bullet_top_left.y].max()
		
		MID.append(abs([horizontal,vertical].min()))
		
	#print(MID)
	return MID
func get_bullet_position(bullets):
	if bullets.is_empty(): return null
	var dir = []
	for bullet in bullets:
		#dir.append(to_local(bullet.global_position).normalized())
		dir.append(to_local(bullet.global_transform.origin).normalized()) 
		#var distance = to_local(self.global_transform.origin).distance_to(dir)
		#print(dir)
		#var distance = to_local(self.global_transform.origin).distance_to(dir)
		#print(distance)
		#if dir.x >= 0 and dir.y >=0:
		#	print("bullet 4th quarter")
		#if dir.x >= 0 and dir.y <=0:
		#	print("bullet 1st quarter")
		#if dir.x <= 0 and dir.y >=0:
		#	print("bullet 3rd quarter")
		#if dir.x <= 0 and dir.y <=0:
		#	print("bullet 2nd quarter")	
	return dir
	
func get_bullet_speed(array_of_bullet):
	var bullets_speed = []
	for bullet in array_of_bullet:
		var bullet_speed = bullet.speed
		bullets_speed.append(bullet_speed)
	return bullets_speed
		
	
func _on_poison_detection_body_entered(_body):
	speed = (1-slowed) * speed

func _on_poison_detection_body_exited(_body):
	speed = MAX_SPEED
	
func take_damage(damage):
	bullet_collided +=1

	hp -= damage
	ai_controller.reward -= damage
	if hp <= 0:
		game_over()
	set_health_bar()

func _on_player_vision_area_entered(area):
	bullet_detected = true
	if len(array_of_bullet) < 10:
		array_of_bullet.append(area)


func _on_player_vision_body_entered(body):
	poison_detected = true
	array_of_poison.append(body)

func _on_player_vision_area_exited(area):
	array_of_bullet.erase(area)
	if array_of_bullet.is_empty():
		bullet_detected = false


func _on_player_vision_body_exited(body):
	array_of_poison.erase(body)
	if array_of_poison.is_empty():
		poison_detected = false
	
