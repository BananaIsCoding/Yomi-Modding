extends BaseProjectile

class_name TemporalPath














const LINE_GREY = Color("404040")
const LINE_PURPLE = Color("4b2bd9")

const LINE_WIDTH_GREY = 1.0
const LINE_WIDTH_PURPLE = 3.0


export  var ricochet_count = 3
export  var active_frames = 30


export  var fade_frames = 10


export  var delay_fast = 18
export  var delay_normal = 51


export  var segment_cap = 10000


var fast = false
var dir_x = "0"
var dir_y = "0"

var di_x = "0"
var di_y = "0"



var path_x = []
var path_y = []

var activated = false


var line_width = LINE_WIDTH_GREY

func init(pos = null):
	.init(pos)

func _draw():
	if disabled:
		return
	if path_x.size() < 2:
		return
	if line_width <= 0.0:
		return
	var col = LINE_PURPLE if activated else LINE_GREY
	for i in range(path_x.size() - 1):
		var a = to_local(Vector2(path_x[i], path_y[i]))
		var b = to_local(Vector2(path_x[i + 1], path_y[i + 1]))
		draw_line(a, b, col, line_width)
