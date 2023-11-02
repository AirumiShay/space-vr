extends Node


func Remove_Creatures(id):
	remove_child(id)
	if get_tree().is_network_server():	
		var list = Network.new_creatures_data()
func Remove_Creatures1(id):
	if not get_tree().is_network_server():		
		remove_child(id)
		return 0
