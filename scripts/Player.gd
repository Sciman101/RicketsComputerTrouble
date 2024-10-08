extends CharacterBody2D

const MAX_AMMO := 3
const MAX_DEFAULT_AMMO := 1
const TAIL_OFFSETS := [12,14,16,14]

# -- other scenes --
@onready var Bullet = preload("res://partial/objects/bullet.tscn")
@onready var Corpse = preload("res://partial/effects/corpse.tscn")
@onready var ShellDebris = preload("res://partial/effects/shell_debris.tscn")

# -- properties --
@export_category("Movement")
@export var move_speed : float = 200
@export var acceleration : float = 200
@export var jump_height : float = 48
@export var jump_time : float = 0.3
@export var jump_release_brake : float = 0.4
@export var fall_gravity_multiplier : float = 1.2

@export_category("Gun")
@export var gun_horizontal_launch_speed : float = 500
@export var gun_horizontal_launch_vertical_boost_speed : float = 200
@export var gun_vertical_launch_speed : float = 400
@export var bounce_velocity_decay : float = 0.75
@export var min_bounce_velocity : float = 300
@export var bullet_speed : float = 250
@export var bullet_spread : float = 7.5

@export_category("Sprites")
@export var default_sprites : SpriteFrames
@export var gunless_sprites : SpriteFrames

# -- nodes --
@onready var appearance = $Appearance
@onready var sprite = $Appearance/RicketSprite
@onready var shotgun_pivot = $Appearance/ShotgunPivot
@onready var shotgun_sprite = $Appearance/ShotgunPivot/ShotgunSprite
@onready var super_dupershotgun_sprite = $Appearance/ShotgunPivot/SuperDuperShotgunSprite
@onready var tail = $Tail

@onready var jump_buffer = $JumpBuffer
@onready var coyote_timer = $CoyoteTimer

@onready var reload_timer = $ReloadTimer
@onready var bounce_raycast = $BounceRaycast

@onready var SHOTGUN_REST_POS = shotgun_pivot.position

var gravity : float
var jump_velocity : float
var facing : int = 1
var ignore_horizontal_input_buffer : float = 0

var enabled := true

var was_on_floor : bool = false
var superbounce_timer : float = 0

var aiming_down : bool = false
var ammo : int = MAX_DEFAULT_AMMO
var target_gun_angle : float = 0
var gun_rotational_velocity : float = 0
var gun_velocity : Vector2

var has_shotgun : bool = true
var super_duper_shotgun : bool = false

var shots_fired : int = 0

# The last door we were at
var last_door : Node2D
var checkpoint : Node2D

signal on_respawn
signal on_move
signal on_jump

func _ready():
	gravity = (2 * jump_height) / (jump_time * jump_time)
	jump_velocity = gravity * jump_time
	
	Ui.ammo_counter.set_amount(ammo, false)
	
	var doors = get_tree().get_nodes_in_group("Door")
	for door in doors:
		if door.default_spawn:
			warp_to_door(door)
			break

func _physics_process(delta):
	_handle_movement(delta)
	_handle_gun(delta)

func _handle_movement(delta : float):
	
	if is_on_floor() and not was_on_floor and not can_shoot():
		reload_timer.stop()
		reload_shotgun()
	elif was_on_floor and not is_on_floor():
		coyote_timer.start()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and not wants_to_jump():
		jump_buffer.start()
		on_jump.emit()
	
	if Input.is_key_pressed(KEY_0):
		set_has_shotgun(true)
		RoomManager.goto("res://rooms/finale.tscn")
		position += Vector2.DOWN * 32
	
	if wants_to_jump() and able_to_jump():
		velocity.y = -jump_velocity
		jump_buffer.stop()
	
	# Handle bounce
	var did_bounce : bool = false
	if aiming_down and bounce_raycast.is_colliding() and velocity.y > 0:
		if velocity.y < 60:
			aiming_down = false
		else:
			velocity.y = max(-velocity.y, -jump_velocity)
			if velocity.y < -100:
				shotgun_pivot.position += Vector2.UP * 4
				did_bounce = true
				SoundManager.play('shotgun-bounce')
			else:
				aiming_down = false
			var col = bounce_raycast.get_collider()
			if col.has_method('on_bounce'):
				col.on_bounce(self)
	
	# Add the gravity.
	if not is_on_floor() and not did_bounce:
		if not reload_timer.is_stopped():
			reload_timer.stop()
		velocity.y += gravity * delta
		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction and ignore_horizontal_input_buffer <= 0:
		# Only accelerate if we won't slow down
		if (direction != sign(velocity.x) and direction != 0) or move_speed > abs(velocity.x) or is_on_floor():
			velocity.x = move_toward(velocity.x, move_speed * direction, delta * acceleration)
		if sign(direction) != facing:
			facing = sign(direction)
			if not aiming_down:
				shotgun_pivot.rotation_degrees = 10
		appearance.scale.x = facing
		sprite.play("run")
		on_move.emit()
		tail.position.y = TAIL_OFFSETS[sprite.frame]
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * acceleration)
		sprite.play("default")
		tail.position.y = 12
	
	if not is_on_floor():
		sprite.play("air")
	
	if ignore_horizontal_input_buffer > 0:
		ignore_horizontal_input_buffer -= delta
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# If we're stuck in something, push us out of it
	if test_move(transform, Vector2.ZERO):
		position += Vector2.UP

func wants_to_jump():
	return not jump_buffer.is_stopped()

func able_to_jump():
	return is_on_floor() or  not coyote_timer.is_stopped()

func _handle_gun(delta):
	
	if not has_shotgun: return
	
	if not aiming_down and Input.is_action_pressed("down") and not is_on_floor():
		aiming_down = true
	elif Input.is_action_just_released("down"):
		aiming_down = false
	
	bounce_raycast.enabled = aiming_down and not is_on_floor()
	bounce_raycast.target_position = velocity * delta
	
	# Make the shotgun wobble a little
	if not aiming_down:
		target_gun_angle = velocity.y * -.05
	else:
		target_gun_angle = 90
	
	# Interpolate gun
	gun_rotational_velocity = Utils.spring(shotgun_pivot.rotation_degrees, target_gun_angle, gun_rotational_velocity, 10, 0.6)
	shotgun_pivot.rotation_degrees += gun_rotational_velocity * delta
	
	gun_velocity = Utils.spring(shotgun_pivot.position, SHOTGUN_REST_POS, gun_velocity, 10, 0.6)
	shotgun_pivot.position += gun_velocity * delta
	
	if Input.is_action_just_pressed("shoot") and can_shoot():
		shoot()
		if is_on_floor():
			# Start timer before we can reload again
			reload_timer.start()
	
	if Input.is_action_just_pressed("restart") and last_door:
		die()

func can_shoot():
	return ammo > 0

func get_shell():
	ammo = MAX_AMMO
	Ui.ammo_counter.set_amount(ammo)

func set_has_shotgun(value:bool):
	self.has_shotgun = value
	Ui.ammo_counter.set_visible(value)
	shotgun_pivot.visible = value
	sprite.sprite_frames = default_sprites if value else gunless_sprites

func set_has_super_duper_shotgun(value:bool):
	self.super_duper_shotgun = value
	shotgun_sprite.visible = not value
	super_dupershotgun_sprite.visible = value

func reload_shotgun():
	if not can_shoot():
		ammo = MAX_DEFAULT_AMMO
		SoundManager.play('shotgun-reload')
		if aiming_down:
			shotgun_pivot.position += Vector2(0, 2)
		else:
			shotgun_pivot.position += Vector2(-2, 0)
			
		# Make shell
		var shell_offset = Vector2.UP if not aiming_down else Vector2(facing, 0)
		var num_shots = 1 if not super_duper_shotgun else 4
		for s in num_shots:
			for i in shots_fired:
				var shell_debris = Utils.spawn(ShellDebris, global_position + shell_offset * 10 * s, RoomManager.current_scene)
				shell_debris.apply_force(Vector2(-facing * 300, randf_range(-300,-200)))
				shell_debris.apply_torque(100)
		shots_fired = 0
	Ui.ammo_counter.set_amount(ammo)

func shoot():
	var bullet_direction = Vector2.RIGHT * facing
	var offset_direction = Vector2.UP
	if aiming_down:
		bullet_direction = Vector2.DOWN
		offset_direction = Vector2(facing, 0)
	
	var num_shots = 1 if not super_duper_shotgun else 4
	var launch_speed_multiplier = 2 if super_duper_shotgun else 1
	
	# Create scenes
	for s in num_shots:
		for i in range(-1,2):
			var bullet = Utils.spawn(Bullet, global_position + bullet_direction * 32 + offset_direction * s * 8, RoomManager.current_scene)
			var dir = bullet_direction.rotated(deg_to_rad(i * bullet_spread))
			# bullet.rotation = -dir.angle_to(Vector2.RIGHT)
			bullet.motion = dir * bullet_speed * randf_range(0.95,1.05)
	
	SoundManager.play('shotgun-fire')
	Stats.shots += 1
	# Apply velocity
	if not is_on_floor():
		if aiming_down:
			velocity.y = min(-gun_vertical_launch_speed * launch_speed_multiplier, velocity.y - gun_vertical_launch_speed * launch_speed_multiplier)
			# Determine if we performed a superbounce
			if velocity.y < -gun_vertical_launch_speed - 200:
				SoundManager.play('ding', 1.5, 0.5)
		else:
			ignore_horizontal_input_buffer = 0.2
			velocity.x = gun_horizontal_launch_speed * -facing * launch_speed_multiplier
			velocity.y -= gun_horizontal_launch_vertical_boost_speed * launch_speed_multiplier
	
	bullet_direction.x = abs(bullet_direction.x)
	shotgun_pivot.position -= bullet_direction * 8
	
	ammo -= 1
	shots_fired += 1
	Ui.ammo_counter.set_amount(ammo)
	
	Utils.camera.kick(bullet_direction * -4)

func die():
	disable()
	SoundManager.play('death')
	shots_fired = 0
	
	# Create corpse
	var corpse = Utils.spawn(Corpse, position, get_parent())
	corpse.velocity = Vector2(randf_range(-100,100),randf_range(-500,-200)) + Vector2.RIGHT * velocity.x
	corpse.angular_velocity = randf_range(-2,2)
	corpse.gravity = gravity
	
	Utils.camera.add_screenshake(8)
	
	Stats.deaths += 1 
	
	await get_tree().create_timer(0.75).timeout
	respawn()

func warp_to_door(door):
	last_door = door
	position = door.position + Vector2(0,-40)
	reset_state()

func mark_checkpoint(check):
	checkpoint = check

func reset_state():
	Ui.ammo_counter.set_amount(ammo)
	velocity = Vector2.ZERO
	aiming_down = false
	ammo = 1
	enable()

func enable():
	show()
	set_process(true)
	set_physics_process(true)
	enabled = true

func disable():
	hide()
	set_process(false)
	set_physics_process(false)
	enabled = false

func respawn():
	if checkpoint:
		warp_to_door(checkpoint)
	else:
		warp_to_door(last_door)
	on_respawn.emit()
	reset_state()

func _on_hazard_detector_body_entered(body):
	if last_door:
		die()
