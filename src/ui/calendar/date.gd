class_name Date

var day : int setget set_day
var month : int setget set_month
var year : int setget set_year

func _init(today: int = OS.get_datetime()["day"], 
		this_month: int = OS.get_datetime()["month"], 
		this_year: int = OS.get_datetime()["year"]):
	self.day = today
	self.month = this_month
	self.year = this_year

func date(date_format = "DD-MM-YY") -> String:
	if("DD".is_subsequence_of(date_format)):
		date_format = date_format.replace("DD", str(get_day()).pad_zeros(2))
	if("MM".is_subsequence_of(date_format)):
		date_format = date_format.replace("MM", str(get_month()).pad_zeros(2))
	if("YYYY".is_subsequence_of(date_format)):
		date_format = date_format.replace("YYYY", str(get_year()))
	elif("YY".is_subsequence_of(date_format)):
		date_format = date_format.replace("YY", str(get_year()).substr(2,3))
	return date_format

func get_day() -> int:
	return day

func get_month() -> int:
	return month

func get_year() -> int:
	return year

func set_day(var _day : int):
	day = _day

func set_month(var _month : int):
	month = _month

func set_year(var _year : int):
	year = _year

func change_to_today() -> void:
	set_day(OS.get_datetime()["day"])
	set_month(OS.get_datetime()["month"])
	set_year(OS.get_datetime()["year"])

func change_to_prev_month():
	var selected_month = get_month()
	selected_month -= 1
	if(selected_month < 1):
		set_month(12)
		set_year(get_year() - 1)
	else:
		set_month(selected_month)

func change_to_next_month():
	var selected_month = get_month()
	selected_month += 1
	if(selected_month > 12):
		set_month(1)
		set_year(get_year() + 1)
	else:
		set_month(selected_month)

func change_to_prev_year():
	set_year(get_year() - 1)

func change_to_next_year():
	set_year(get_year() + 1)
