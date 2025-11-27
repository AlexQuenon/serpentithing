extends RichTextLabel

const DELAY : float = 0.3
const MESSAGE : String = "WINNER!"

@export var colors : PackedColorArray

var wait : float = 0.0
var starting_modulo : int = 0

func _process(delta):
	if not visible:
		return

	wait += delta
	if wait >= DELAY:
		wait -= DELAY
		starting_modulo = (starting_modulo + 1) % colors.size()

	self.clear()
	var modulo = starting_modulo
	for i in range(MESSAGE.length()):
		var color = colors[modulo]
		self.push_color(color)
		self.append_text(MESSAGE[i])
		self.pop()
		modulo = (modulo - 1) % colors.size()

func reset():
	wait = 0.0
	starting_modulo = 0
