extends Control

func _ready():
#	$Menu/LocalIP.text = "Local IP: " + Network.get_IP()
#	$Menu/Connect/IP.placeholder_text = Network.get_IP()
#	$Menu/Error.hide()
	print ("IP-address")
	print(str(IP.get_local_addresses()))
	pass
	
func _on_Host_pressed():
	if $Menu/Username.text == "":
		$Menu/Username.text = "Anonymous"
	
	Network.create_server($Menu/Username.text)

func _on_Join_pressed():
	if $Menu/Connect/IP.text == "":
		$Menu/Connect/IP.text = $Menu/Connect/IP.placeholder_text
	if $Menu/Username.text == "":
		$Menu/Username.text = "Anonymous"
	
	Network.join_server($Menu/Connect/IP.text, $Menu/Username.text)

func _on_text_entered(new_text):
	_on_Join_pressed()


func _on_Update_Build_Timer_timeout():
	pass # Replace with function body.
