extends ArmsState


# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	print(arms.player.state_machine.state.name + " , player state: "+ arms.state_machine.state.name)
	
	if arms.player.state_machine.state.name == "Run":
		arms.player.state_machine.transition_to("Walk")
		arms.animationPlayer.play("ShowKnife")
		
		return
	arms.knife.collisionShape.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	pass

func _on_knife_ended_melee():
	state_machine.transition_to("Idle", {"playHud" : true})
	await get_tree().create_timer(0.1).timeout
	arms.weaponHolder.visible = true
	arms.knife.visible = false
	arms.knife.set_process(false)
	arms.knife.collisionShape.disabled = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "ShowKnife" and arms.state_machine.state.name == "Melee":
		arms.weaponHolder.visible = false
		arms.knife.animationPlayer.play("Knife_Shot", -1, 2, false)
		await get_tree().create_timer(0.1).timeout
		arms.knife.visible = true
