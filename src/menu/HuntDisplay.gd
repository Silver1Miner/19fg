extends ColorRect

onready var date_display = $DateDisplay
onready var time_display = $GridContainer/TimeValue
onready var shots_display = $GridContainer/ShotsValue
onready var hits_display = $GridContainer/HitsValue
onready var accuracy_display = $GridContainer/AccuracyValue
onready var score_display = $GridContainer/ScoreValue

func default_display() -> void:
	time_display.text = "--:--"
	shots_display.text = "--"
	hits_display.text = "--"
	accuracy_display.text = "--%"
	score_display.text = "--"

func update_date_display(year: int, month: int, day: int) -> void:
	date_display.text = str(year) + "/" + str(month) + "/" + str(day)

func update_time_display(minutes: int, seconds: int) -> void:
	var minute_display = ""
	if minutes < 10:
		minute_display = "0" + str(minutes)
	else:
		minute_display = str(minutes)
	var second_display = ""
	if seconds < 10:
		second_display = "0" + str(int(seconds))
	else:
		second_display = str(int(seconds))
	time_display.text = minute_display + ":" + second_display

func update_accuracy_display(shots: int, hits: int) -> void:
	if shots <= 0:
		push_error("invalid shots value")
		return
	shots_display.text = str(shots)
	hits_display.text = str(hits)
	accuracy_display.text = str(stepify(float(hits)/float(shots) * 100, 0.01)) + "%"

func update_score_display(score: int) -> void:
	score_display.text = str(score)

func attempt_update(data: Dictionary) -> void:
	print(data)
	if data.has("shots") and data.has("hits"):
		update_accuracy_display(data.shots, data.hits)
	if data.has("minutes") and data.has("seconds"):
		update_time_display(data.minutes, data.seconds)
	if data.has("score"):
		update_score_display(data.score)
