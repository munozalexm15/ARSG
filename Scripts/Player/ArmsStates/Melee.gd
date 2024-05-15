extends ArmsState


# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	pass

func _on_knife_ended_melee():
	state_machine.transition_to("Idle", {"playHud" : true})
	await get_tree().create_timer(0.1).timeout
	arms.weaponHolder.visible = true
	arms.knife.visible = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "SwapWeapon" and arms.state_machine.state.name == "Melee":
		arms.weaponHolder.visible = false
		arms.knife.animationPlayer.play("Knife_Shot")
		await get_tree().create_timer(0.1).timeout
		arms.knife.visible = true
