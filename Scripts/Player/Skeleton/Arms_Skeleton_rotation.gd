extends Skeleton3D

@onready var right_bone_index = find_bone("UpperArm.R")
@onready var left_bone_index = find_bone("UpperArm.L")

@onready var neck_bone_index = find_bone("Neck")
@onready var chest_bone_index = find_bone("Chest")

@onready var left_org_bone_rot: Quaternion = get_bone_pose_rotation(left_bone_index)
@onready var right_org_bone_rot: Quaternion = get_bone_pose_rotation(right_bone_index)

@onready var neck_org_bone_rot: Quaternion = get_bone_pose_rotation(neck_bone_index)
@onready var chest_org_bone_rot: Quaternion = get_bone_pose_rotation(chest_bone_index)


@onready var skeleton : PlayerSkeleton = $"../../.."
var eyesHolder : Node3D = null

var arms : Arms = null

#-------------Chest
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):

	rotate_arms_bone(right_bone_index, right_org_bone_rot)
	rotate_arms_bone(left_bone_index, left_org_bone_rot)

	rotate_arms_bone(neck_bone_index, neck_org_bone_rot)

func rotate_arms_bone(bone_index, org_bone_rot):
	var bone_rotation: Quaternion = get_bone_pose_rotation(bone_index)
	var bone_parent_bones_rotation: Quaternion = get_bone_global_pose(bone_index).basis.get_rotation_quaternion() * bone_rotation.normalized().inverse()
	var skeleton_global_rotation: Quaternion = transform.basis.get_rotation_quaternion()
	var bone_parents_rotation: Quaternion = skeleton_global_rotation * bone_parent_bones_rotation
	var bone_global_rotation: Quaternion = bone_parents_rotation * org_bone_rot

	var new_bone_global_rotation: Quaternion = Quaternion(Vector3.LEFT, eyesHolder.rotation.x) * bone_global_rotation
	var new_bone_rotation: Quaternion = bone_parents_rotation.inverse() * new_bone_global_rotation
	
	set_bone_pose_rotation(bone_index, new_bone_rotation)



func _on_player_skeleton_updated_pose():
	#reset_bones()
	pass

func reset_bones():
	print("reset")
	set_bone_pose_rotation(left_bone_index, left_org_bone_rot)
	set_bone_pose_rotation(right_bone_index, right_org_bone_rot)
