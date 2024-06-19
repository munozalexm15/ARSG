extends StaticBody3D
class_name Target

signal hitmark

@onready var animationPlayer: AnimationPlayer = $"../../../AnimationPlayer"
@onready var headArea: Area3D = $"../HeadArea"

@onready var healthBar : ProgressBar = $"../../../SubViewport/ProgressBar"

var targetData : HumanTargetData
var isHeadshot : bool = false
var isDowned = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if targetData.actualHealth == targetData.health or targetData.actualHealth <= 0:
		healthBar.visible = false
	
	if targetData.actualHealth <= 0 and not isDowned:
		animationPlayer.play("Down")
		isDowned = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Down":
		await get_tree().create_timer(targetData.downTime).timeout
		animationPlayer.play("Up")
		isHeadshot = false
	
	if anim_name == "Up":
		isDowned = false
		healthBar.value = healthBar.max_value
		targetData.actualHealth = targetData.health

func _on_head_area_body_entered(body):
	if body is Bullet:
		targetData.actualHealth -= body.damage
		if targetData.actualHealth < 0 and body.instigator.hud.timerContainer.visible:
			body.instigator.hud.pointsLabel.text = str(int(body.instigator.hud.pointsLabel.text) + 15)
		
		tween_health()
		
func tween_health():
	create_tween().tween_property(healthBar, "value", targetData.actualHealth, 0.2)

func tween_healthBar_visibility():
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_interval(2.0)
	fade_tween.tween_property(healthBar, "modulate:a", 0, 0.2)
	fade_tween.play()
	
	await fade_tween.finished
	
	healthBar.visible = false
	healthBar.modulate.a = 255
