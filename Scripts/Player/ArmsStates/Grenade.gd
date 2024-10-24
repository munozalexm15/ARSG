extends ArmsState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	arms.animationPlayer.play("Reload")
	await arms.animationPlayer.animation_finished
	arms.player.player_body.LeftHandB_Attachment.get_child(0).visible = false
	arms.player.player_body.RightHandB_Attachment.get_child(0).visible = true
	arms.grenade.animPlayer.play("Grenade_Prepare")
	arms.player.player_body.animationTree.set("parameters/Reloads/transition_request", "Grenade_Prepare")
	arms.weaponHolder.visible = false
	arms.player.player_body.leftArmIKSkeleton.interpolation = 0
	arms.player.player_body.rightArmIKSkeleton.interpolation = 0
		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Grenade_Prepare":
		prepare_grenade()
		arms.grenade.animPlayer.play("Grenade_Throw")
		arms.player.player_body.animationTree.set("parameters/Reloads/transition_request", "Grenade_Throw")
		
	
	if anim_name == "Grenade_Throw":
		arms.player.player_body.LeftHandB_Attachment.get_child(0).visible = true
		arms.readyToThrow = false
		arms.animationPlayer.play("Reload", -1, -1, true)
		if arms.player.camera.current:
			arms.weaponHolder.visible = true
		state_machine.transition_to("Idle")
		arms.player.player_body.leftArmIKSkeleton.interpolation = 0.5
		arms.player.player_body.rightArmIKSkeleton.interpolation = 1


func prepare_grenade():
	arms.grenade.grenadeThrown = arms.grenade.grenadeScene.instantiate()
	arms.grenade.add_child(arms.grenade.grenadeThrown)
	arms.grenade.grenadeThrown.visible = false
	arms.grenade.grenadeThrown.mass = 1
	arms.grenade.grenadeThrown.add_collision_exception_with(arms.player)
	arms.grenade.grenadeThrown.global_position = arms.grenade.grenadeParent.get_child(1).global_position
	arms.readyToThrow = true
