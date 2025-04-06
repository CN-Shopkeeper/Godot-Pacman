extends Control
@onready var back_to_main_menucolor_rect: ColorRect = $BackToMainMenu/ColorRect
@onready var back_to_main_menu: CenterContainer = $BackToMainMenu
@onready var back_to_main_menu_no_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/No
@onready var back_to_main_menu_yes_button: AnimatedButton = $BackToMainMenu/VBoxContainer/HBoxContainer/Yes

const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"
func _ready() -> void:
	back_to_main_menucolor_rect.color = GlobalVariables.main_menu_color

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		back_to_main_menu.visible = !back_to_main_menu.visible
		if back_to_main_menu.visible:
			back_to_main_menu_no_button.grab_focus()


func _on_no_button_pressed() -> void:
	back_to_main_menu.hide()

func _on_yes_button_pressed() -> void:
	print("111")
	IndieBlueprintSceneTransitioner.transition_to(
		MAIN_MENU_PATH,
		IndieBlueprintPremadeTransitions.Dissolve,
		IndieBlueprintPremadeTransitions.Dissolve,
				{
	"in": {
		"color": GlobalVariables.scene_transition_color,
		"duration": 1,
		"texture": IndieBlueprintPremadeTransitions.Squares
	},
	"out": {
		"color": GlobalVariables.scene_transition_color,
		"duration": 1,
		"texture": IndieBlueprintPremadeTransitions.Squares
	},
}
	)
