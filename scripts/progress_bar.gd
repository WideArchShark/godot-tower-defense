extends ProgressBar

var health_stylebox:StyleBoxFlat
const health_bar_gradient = preload("res://resources/health_bar_colours.res")

func _ready():
	health_stylebox = get_theme_stylebox("fill")
	
func _on_value_changed(new_value):
	health_stylebox.bg_color = health_bar_gradient.gradient.sample(new_value / max_value)
