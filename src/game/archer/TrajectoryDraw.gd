extends Node2D

var initial_velocity = Vector2()
var drawing = false
var gravity = 98
var points = {
	"gap": 50,
	"radius": 2,
	"color": Color(1, 0, 0)
}

func draw_trajectory(init_vel: Vector2, from: Vector2, new_gravity = 98):
	initial_velocity = init_vel
	global_position = from
	drawing = true
	gravity = new_gravity
	update()

func clear():
	if !drawing:
		return
	drawing = false
	update()

func _draw() -> void:
	if initial_velocity.length() <= 0:
		return
	var col = points.color
	if drawing:
		var angle = -initial_velocity.angle()
		for i in range (20):
			var x = i * (points.gap)
			var pos = Vector2(x, trajectory_equation(
				x,
				angle,
				gravity,
				initial_velocity.length())
			)
			col.a = 1 - (i / 50.0)
			draw_circle(pos, points.radius * (col.a + 0.1), col)

func trajectory_equation(x: float, teta: float, g: float, v0: float) -> float:
	return -(x * tan(teta) - (g * pow(x, 2)) / (2.0 * pow(v0, 2) * pow(cos(teta), 2)))
