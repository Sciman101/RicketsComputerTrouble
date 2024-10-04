extends CanvasLayer

@onready var ammo_counter = $AmmoCounter
@onready var popup = $PopupText
@onready var popup_label = $PopupText/MarginContainer/Text
@onready var timer_label = $TimerPanel/Timer
@onready var timer_panel = $TimerPanel

func _ready():
	popup.position.y = -popup.size.y
	ammo_counter.hide()
	timer_panel.hide()

func show_popup(text:String, duration:float=5.0):
	popup_label.text = text
	if popup.position.y != 0:
		var tween = get_tree().create_tween()
		tween.tween_property(popup, 'position:y', 0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		# If the popup changed, don't hide
		if popup_label.text == text:
			hide_popup()

func hide_popup():
	var tween = get_tree().create_tween()
	tween.tween_property(popup, 'position:y', -popup.size.y, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
