extends Node2D

var texts = []
var completed_100 = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Player.disable()
	Ui.hide()
	$Black.color = Color.BLACK
	
	texts.append("The end!\n")
	texts.append("Laptops: %s/%s" % [Stats.laptops, Stats.laptops_total])
	texts.append("Buddies:")
	for buddy in Stats.visited_buddies.keys():
		texts.append(" " + buddy)
	texts.append("%s/%s" % [Stats.buddies, Stats.buddies_total])
	texts.append("Deaths: %s" % Stats.deaths)
	texts.append("Shots Fired: %s" % Stats.shots)
	
	var completion = Stats.calculate_completion()
	completed_100 = completion >= 100
	texts.append("\nYou got: %s%%!" % completion)
	texts.append("\nThanks for playing!")
	texts.append("Ricket by torcado")
	texts.append("Game by Sciman101")
	
	do_endscreen_sequence()

func duration(duration:float): return get_tree().create_timer(duration).timeout

func make_tween(): return get_tree().create_tween()

func do_endscreen_sequence():
	await duration(2)
	var tween = make_tween()
	tween.set_parallel(true)
	tween.tween_property($Black, 'color', Color.TRANSPARENT, 0.4)
	$Endscreen.position.x += 200
	tween.tween_property($Endscreen, 'position', Vector2.ZERO, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	$Info.position.x -= 200
	tween.tween_property($Info, 'position', Vector2.ZERO, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)	
	await tween.finished
	
	await do_info_sequence()

func do_info_sequence():
	var info_label = $Info/MarginContainer/Label
	for text in texts:
		info_label.text += text + "\n"
		if text.contains("You got:") and completed_100:
			SoundManager.play('children-cheering')
		elif text.contains("Sciman101"):
			SoundManager.play('shotgun-fire')
		else:
			SoundManager.play('shotgun-reload')
		await duration(1.25)
	await do_context_sequence()

func do_context_sequence():
	await duration(5)
	var tween = make_tween()
	var ctx = [$Context1, $Context2]
	ctx[0].show()
	ctx[1].show()
	ctx[0].position.y -= 720
	ctx[1].position.y += 720
	tween.set_parallel(true)
	tween.tween_property(ctx[0],'position', ctx[0].position + Vector2(0,720), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(ctx[1],'position', ctx[1].position - Vector2(0,720), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	await tween.finished
