extends ArmsState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	arms.grenadeQuantity -= 1
	arms.player.hud.grenadeCountLabel.text = str(arms.grenadeQuantity)
	
	arms.animationPlayer.play("Reload")
	await arms.animationPlayer.animation_finished
	arms.player.player_body.LeftHandB_Attachment.get_child(0).visible = false
	arms.player.player_body.RightHandB_Attachment.get_child(0).visible = true
	if arms.player.camera.current:
		arms.grenade.visible = true
	arms.grenade.animPlayer.play("Grenade_Prepare")
	arms.grenade.throwSound.play()
	arms.player.player_body.animationTree.set("parameters/Reloads/transition_request", "Grenade_Prepare")
	arms.weaponHolder.visible = false
	arms.player.player_body.leftArmIKSkeleton.interpolation = 0
	arms.player.player_body.rightArmIKSkeleton.interpolation = 0
		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Grenade_Prepare":
		prepare_grenade.rpc(arms.player.name)
		arms.grenade.animPlayer.play("Grenade_Throw")
		arms.player.player_body.animationTree.set("parameters/Reloads/transition_request", "Grenade_Throw")
		
	
	if anim_name == "Grenade_Throw":
		thirdPersonGrenadeFlow.rpc(arms.player.name)


@rpc("any_peer", "call_local")
func prepare_grenade(pID):
	var p : Player = Network.findPlayer(pID)
	p.arms.grenade.grenadeThrown = arms.grenade.grenadeScene.instantiate()
	p.arms.grenade.add_child(arms.grenade.grenadeThrown)
	p.arms.grenade.grenadeThrown.visible = false
	p.arms.grenade.grenadeThrown.mass = 1
	p.arms.grenade.grenadeThrown.add_collision_exception_with(arms.player)
	p.arms.grenade.grenadeThrown.global_position = arms.grenade.grenadeParent.get_child(1).global_position
	p.arms.readyToThrow = true

@rpc("any_peer", "call_local")
func thirdPersonGrenadeFlow(pID):
	var p : Player = Network.findPlayer(pID)
	p.arms.player.player_body.LeftHandB_Attachment.get_child(0).visible = true
	p.arms.readyToThrow = false
	p.arms.animationPlayer.play("Reload", -1, -1, true)
	if p.arms.player.camera.current:
		p.arms.weaponHolder.visible = true
	p.arms.state_machine.transition_to("Idle")
	p.arms.player.player_body.leftArmIKSkeleton.interpolation = 0.5
	p.arms.player.player_body.rightArmIKSkeleton.interpolation = 1
