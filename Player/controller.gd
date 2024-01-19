extends AIController2D

var move_action : Vector2 = Vector2.ZERO

func _physics_process(delta):
	n_steps += 1
	if n_steps > reset_after:
		needs_reset = true
	if needs_reset:
		needs_reset=false
		reset()
	update_reward()
	

func get_obs() -> Dictionary:
	
	var obs = []
	obs.resize(42)
	obs.fill(0)
	
	var bullets = _player.get_nearest_bullet(_player.array_of_bullet)
	
	var player_position = _player.global_position.normalized()
	
	if bullets == null:
		pass
	else:
		var MID = _player.get_MID(bullets)
		var bullets_position = _player.get_bullet_position(bullets)
		for bullet in bullets:
			obs.pop_front()
			obs.pop_front()
			obs.pop_front()
			obs.pop_front()
			
			var bullet_position = bullets_position.pop_front()
			#print(bullet_position)
			obs.append(bullet_position.x)
			obs.append(bullet_position.y)
			obs.append(bullet._check_collision())
			obs.append(MID.pop_front())
			
	
	obs.pop_front()
	obs.pop_front()
	obs.append(player_position.x)
	obs.append(player_position.y)

	
	#var obs = []
	#obs.resize(23)
	#obs.fill(-1.0)
	
	#var bullets = _player.get_nearest_bullet(_player.array_of_bullet)
	#var player_position = _player.global_position
	
	#if bullets == null:
	#	pass
	#else:
	#	for bullet in bullets:
	#		obs.pop_front()
	#		obs.pop_front()
			
	#		var distance = player_position.distance_to(bullet.global_position)
			
	#		if distance == 0.0:
				#print(distance)
	#			obs.append(distance + 0.001)
	#		else:
				#snappedf(distance,0.01)
				#print(typeof(distance))
	#			obs.append(distance)
			#print("pass1")
	#		obs.append(bullet._check_collision())
			#print("pass2")
			
	#obs.pop_front()
	#obs.pop_front()
	#obs.pop_front()
	#obs.append(player_position.x)
	#obs.append(player_position.y)
	#obs.append(_player.speed)
	#print("pass3")
	
	#var obs = []
	#obs.resize(32)
	#obs.fill(0)
	
	#var bullets = _player.get_nearest_bullet(_player.array_of_bullet)
	#var player_position = _player.global_position
	
	#if bullets == null:
	#	pass
	#else:
	#	for bullet in bullets:
	#		obs.pop_front()
	#		obs.pop_front()
	#		obs.pop_front()
	#		obs.append(bullet.global_position.x)
	#		obs.append(bullet.global_position.x)
	#		obs.append(bullet._check_collision())
	#		
	#obs.pop_front()
	#obs.pop_front()
	#obs.append(player_position.x)
	#obs.append(player_position.y)
		
	return {"obs":obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		}
	}
	
func set_action(action) -> void:
		if _player.is_colliding:
			for index in _player.get_slide_collision_count():
				var collision = _player.get_slide_collision(index)
				var body = collision.get_collider()
				if body.name == "TopBarrier":
					move_action.y = clamp(action["move_action"][1],0,1)
					
				if body.name == "BottomBarrier":
					move_action.y = clamp(action["move_action"][1],-1,0)
					
				if body.name == "LeftBarrier":
					move_action.x = clamp(action["move_action"][0],0,1)
					
				if body.name == "RightBarrier":
					move_action.x = clamp(action["move_action"][0],-1,0)
			
			
		else:	
			move_action.x = clamp(action["move_action"][0],-1,1)
			move_action.y = clamp(action["move_action"][1],-1,1)	
		move_action = move_action.normalized()
		
func reset():

	n_steps = 0
	needs_reset = false
	_player.get_parent()._reset()
	
	
	_player.global_position = _player.reset_position
	_player.hp = _player.MAX_HP
	_player.set_health_bar()
	
	
func shaping_reward():
	var bullets = _player.get_nearest_bullet(_player.array_of_bullet)
	var distances = 0.0 
	if bullets == null:
		return 10.0
	for bullet in bullets:
		distances += _player.global_position.distance_to(bullet.global_position)
	distances /= 100.0
	print(distances)
	return distances
	
func update_reward():
	reward += 0.1 # step reward
	#reward += shaping_reward()
	
 
	

