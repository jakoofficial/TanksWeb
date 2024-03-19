extends Control

@export var scores = []

var score: int = 0

func _ready():
	$Score.text = ""

func _process(delta):
	$Score.text = "Score: %s" % score
