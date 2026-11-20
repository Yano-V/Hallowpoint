
extends Control

@onready var location_label: Label = $Background/LocationLabel

var location_names: Dictionary = {
	"TYK": "Tan Yan Kee Garden",
	"TYK2": "Tan Yan Kee Garden",
	"TUNNEL1": "Tunnel",
	"SFCLobby": "SFC Lobby",
	"SFC2ndFloor": "SFC Second Floor",
	"LBLobby": "LB Lobby",
	"LBFloors": "LB Second Floor",
	"LBFloors2": "LB Third Floor",
	"LBFloors3": "LB Fourth Floor",
	"LBFloors4": "LB Fifth Floor"
}


func update_location(map_name: String) -> void:
	location_label.text = location_names.get(map_name, map_name)
