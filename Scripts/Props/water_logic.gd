extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body == FishSave.fish_bait_node:
		FishSave.fish_bait_node.processing = true
		#get_tree().quit()
		FishSave.fish_bait_node.velocity = Vector3.ZERO
		print("FISH BAIT HERE!")
		FishSave.fish_bait_node.fish_logic()
	else:
		print(body)
