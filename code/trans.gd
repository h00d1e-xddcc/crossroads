extends Control

func _ready() -> void:
	arc.retranslate.connect(translate)

func translate() :
	self.text = tr(name)
