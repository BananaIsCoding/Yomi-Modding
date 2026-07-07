extends Control

class_name SettingsSlider

signal value_changed(value)

onready var slider = $"%HSlider"
var value = 0.0
var mouse_entered = false

export  var default_value = 0.0
export  var min_value = 0.0
export  var max_value = 100.0
export  var step = 0.01




export  var exponential = false


export  var label_text = ""

func _ready():
	if exponential:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.001
	else:
		slider.min_value = min_value
		slider.max_value = max_value
		slider.step = step
	$"%Label".text = label_text if label_text else name
	$"%Value".connect("text_changed", self, "_on_value_text_changed")
	$"%Value".connect("text_entered", self, "_on_value_text_entered")
	$"%Value".connect("focus_exited", self, "_on_value_focus_exited")
	set_value(default_value)

func _input(event):
	
	
	
	
	
	
	
	
	if not slider.has_focus():
		return
	if not (event is InputEventKey) or not event.pressed:
		return
	if event.scancode != KEY_LEFT and event.scancode != KEY_RIGHT:
		return
	var arrow_step = 0.01 if exponential else step
	if event.shift:
		arrow_step *= 10
	var direction = - 1 if event.scancode == KEY_LEFT else 1
	set_value(value + direction * arrow_step)
	get_tree().set_input_as_handled()

func _on_HSlider_value_changed(slider_val):
	if exponential:
		value = _slider_to_value(slider_val)
	else:
		value = slider_val
	emit_signal("value_changed", value)
	
	if not $"%Value".has_focus():
		$"%Value".text = _format_value(value)

func set_value(v):
	v = clamp(v, min_value, max_value)
	if exponential:
		
		
		
		slider.value = _value_to_slider(v)
		value = v
	else:
		slider.value = v
		value = slider.value
	emit_signal("value_changed", value)
	if not $"%Value".has_focus():
		$"%Value".text = _format_value(value)

func _try_parse_value(text):
	var trimmed = text.strip_edges()
	if trimmed == "" or trimmed == "-" or trimmed == "." or trimmed == "-.":
		return null
	if not trimmed.is_valid_float():
		return null
	return float(trimmed)

func _on_value_text_changed(text):
	
	
	
	var parsed = _try_parse_value(text)
	if parsed == null:
		return
	set_value(parsed)

func _on_value_text_entered(_text):
	
	$"%Value".release_focus()

func _on_value_focus_exited():
	$"%Value".text = _format_value(value)

func get_data():
	return value

func set_label_text(text: String):
	label_text = text
	if has_node("%Label"):
		$"%Label".text = text

func _slider_to_value(t):
	if min_value <= 0.0:
		return pow(max_value - min_value + 1.0, t) - 1.0 + min_value
	return min_value * pow(max_value / min_value, t)

func _value_to_slider(v):
	v = clamp(v, min_value, max_value)
	if min_value <= 0.0:
		return log(v - min_value + 1.0) / log(max_value - min_value + 1.0)
	return log(v / min_value) / log(max_value / min_value)

func _format_value(v):
	if exponential:
		return "%.2f" % v
	return str(v)

func _on_ResetButton_pressed():
	set_value(default_value)
