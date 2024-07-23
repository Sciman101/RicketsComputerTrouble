extends CharacterBody2D

const SHOTGUN_REST_POS = Vector2(0,3)
const MAX_AMMO := 3
const MAX_DEFAULT_AMMO := 1

# -- other scenes --
@onready var Bullet = preload("res://partial/bullet.tscn")
@onready var Corpse = preload("res://partial/corpse.tscn")

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

# -- nodes --
@onready var appearance = $Appearance
@onready var shotgun_sprite = $Appearance/ShotgunSprite
@onready var superbounce_graphic = $Appearance/ShotgunSprite/Superbounce

@onready var reload_timer = $ReloadTimer
@onready var bounce_raycast = $BounceRaycast

@onready var sfx_bounce = $SFX/Bounce
@onready var sfx_reload = $SFX/Reload
@onready var sfx_fire = $SFX/Fire

var gravity : float
var jump_velocity : float
var facing : int = 1
var ignore_horizontal_input_buffer : float = 0

var was_on_floor : bool = false
var superbounce_timer : float = 0

var aiming_down : bool = false
var ammo : int = MAX_DEFAULT_AMMO
var target_gun_angle : float = 0
var gun_rotational_velocity : float = 0
var gun_velocity : Vector2

# The last door we were at
var last_door : Node2D

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

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	elif Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= jump_release_brake
	
	# Handle bounce
	var did_bounce : bool = false
	if aiming_down and bounce_raycast.is_colliding() and velocity.y > 0:
		velocity.y = max(-velocity.y, -jump_velocity)
		if velocity.y < -100:
			superbounce_timer = 0.05
			shotgun_sprite.position += Vector2.UP * 4
			did_bounce = true
			sfx_bounce.play()
		else:
			aiming_down = false
	
	# Add the gravity.
	if not is_on_floor() and not did_bounce:
		velocity.y += gravity * delta
		
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")
	if direction and ignore_horizontal_input_buffer <= 0:
		velocity.x = move_toward(velocity.x, move_speed * direction, delta * acceleration)
		if sign(direction) != facing:
			facing = sign(direction)
			if not aiming_down:
				shotgun_sprite.rotation_degrees = 10
		appearance.scale.x = facing
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * acceleration)
	
	if ignore_horizontal_input_buffer > 0:
		ignore_horizontal_input_buffer -= delta
	if superbounce_timer > 0:
		superbounce_timer -= delta
		superbounce_graphic.hide()
	
	was_on_floor = is_on_floor()
	
	move_and_slide()

func _handle_gun(delta):
	
	if not aiming_down and Input.is_action_pressed("down") and not is_on_floor():
		aiming_down = true
	elif Input.is_action_just_released("down"):
		aiming_down = false
	
	bounce_raycast.enabled = aiming_down and not is_on_floor()
	
	# Make the shotgun wobble a little
	if not aiming_down:
		target_gun_angle = velocity.y * -.05
	else:
		target_gun_angle = 90
	
	# Interpolate gun
	gun_rotational_velocity = Utils.spring(shotgun_sprite.rotation_degrees, target_gun_angle, gun_rotational_velocity, 10, 0.6)
	shotgun_sprite.rotation_degrees += gun_rotational_velocity * delta
	
	gun_velocity = Utils.spring(shotgun_sprite.position, SHOTGUN_REST_POS, gun_velocity, 10, 0.6)
	shotgun_sprite.position += gun_velocity * delta
	
	if Input.is_action_just_pressed("shoot") and can_shoot():
		shoot()
		if is_on_floor():
			# Start timer before we can reload again
			reload_timer.start()

func can_shoot():
	return ammo > 0

func get_shell():
	ammo = min(ammo + 1, MAX_AMMO)
	Ui.ammo_counter.set_amount(ammo)

func reload_shotgun():
	if not can_shoot():
		ammo = MAX_DEFAULT_AMMO
		sfx_reload.play()
		if aiming_down:
			shotgun_sprite.position += Vector2(0, 2)
		else:
			shotgun_sprite.position += Vector2(-2, 0)
	Ui.ammo_counter.set_amount(ammo)

func shoot():
	var bullet_direction = Vector2.RIGHT * facing
	if aiming_down:
		bullet_direction = Vector2.DOWN
	
	# Create scenes
	for i in range(-1,2):
		var bullet = Bullet.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position + bullet_direction * 32
		var dir = bullet_direction.rotated(deg_to_rad(i * bullet_spread))
		bullet.rotation = -dir.angle_to(Vector2.RIGHT)
		bullet.motion = dir * bullet_speed
	
	sfx_fire.play()
	# Apply velocity
	if not is_on_floor():
		if aiming_down:
			velocity.y = min(-gun_vertical_launch_speed, velocity.y - gun_vertical_launch_speed)
			if superbounce_timer > 0:
				superbounce_graphic.show()
		else:
			ignore_horizontal_input_buffer = 0.1
			velocity.x = gun_horizontal_launch_speed * -facing
			velocity.y -= gun_horizontal_launch_vertical_boost_speed
	
	bullet_direction.x = abs(bullet_direction.x)
	shotgun_sprite.position -= bullet_direction * 8
	shotgun_sprite.frame = 1
	
	ammo -= 1
	Ui.ammo_counter.set_amount(ammo)
	
	Utils.camera.kick(bullet_direction * -4)
	
	await get_tree().create_timer(0.1).timeout
	shotgun_sprite.frame = 0

func die():
	disable()
	
	# Create corpse
	var corpse = Utils.spawn(Corpse, position, get_parent())
	corpse.velocity = Vector2(randf_range(-100,100),randf_range(-500,-200))
	corpse.angular_velocity = randf_range(-2,2)
	corpse.gravity = gravity
	
	Utils.camera.add_screenshake(8)
	
	Stats.deaths += 1 

func warp_to_door(door):
	last_door = door
	position = door.position + Vector2(0,-16)
	reset_state()

func reset_state():
	velocity = Vector2.ZERO
	aiming_down = false
	enable()

func enable():
	show()
	set_process(true)
	set_physics_process(true)

func disable():
	hide()
	set_process(false)
	set_physics_process(false)

func respawn():
	warp_to_door(last_door)
	reset_state()

func _on_hazard_detector_body_entered(body):
	if last_door:
		die()
		await get_tree().create_timer(0.75).timeout
		respawn()
