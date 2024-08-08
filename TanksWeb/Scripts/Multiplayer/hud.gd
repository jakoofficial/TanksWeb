extends Control

var score: int = 0
var playersOnline: int = 0

func _ready():
	$Score.text = ""
	$PlayerCounter.text = "Players: "

func _process(delta):
	$Score.text = "Score: %s" % score
	var counts = get_tree().get_nodes_in_group("Player").size()
	$PlayerCounter.text = "Players: %s" %counts
