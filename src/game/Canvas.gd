extends Node2D

onready var projectiles = $Projectiles
onready var player = $Player
onready var speed_lines = $SpeedLines
onready var sun = $Sun

onready var orbitable_nodes = get_tree().get_nodes_in_group("orbitable")
onready var orbitables = {
	"ships": {},
	"stations": {},
	"asteroids": {},
}

var previous_velocity = Vector2(0, 0)

var last_timestamp = null

onready var start_time = OS.get_datetime()

func get_orbitable_type(orbitable):
	if orbitable.is_in_group("ships"):
		return "ship"
	elif orbitable.is_in_group("stations"):
		return "station"
	elif orbitable.is_in_group("asteroids"):
		return "station"

func _ready():
	player.connect("shoot", projectiles, "_on_projectile_fired")
	AudioEngine.play_background_music("flight")

	for orbitable in orbitable_nodes:
		if get_orbitable_type(orbitable) == "ship":
			orbitables.ships[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}
		elif get_orbitable_type(orbitable) == "station":
			orbitables.stations[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}
		elif get_orbitable_type(orbitable) == "asteroid":
			orbitables.asteroids[orbitable] = {
				"distance": sun.position.distance_to(orbitable.position),
				"original_position": orbitable.position
			}


	last_timestamp = date_to_day_percentage()
	update_orbitables(true)




func date_to_day_percentage():
	var now = OS.get_unix_time()
	return float(now % 86400) / 86400


func update_orbitables(include_ships = false):
	for station in orbitables.stations:
		var station_data = orbitables.stations[station]
		station.position = (station_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position

	for asteroid in orbitables.asteroids:
		var asteroid_data = orbitables.asteroids[asteroid]
		asteroid.position = (asteroid_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position

	if include_ships:
		for ship in orbitables.ships:
			var ship_data = orbitables.ships[ship]
			ship.position = (ship_data.original_position - sun.position).rotated(last_timestamp * 2 * PI) + sun.position



func _process(delta):
	if (date_to_day_percentage() != last_timestamp):
		update_orbitables(false)

	var velocity = player.velocity
	if velocity.length() > 380:
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	# intention here is that we can see if the velocity still changes (player is turning/accelerating at lower speeds, will turn off)
	elif velocity.length() > 100 and velocity.normalized() == previous_velocity.normalized():
		speed_lines.visible = true
		speed_lines.spawn_speedline(player)
	else:
		speed_lines.visible = false

	previous_velocity = velocity

