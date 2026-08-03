class_name StatusEffectCard
extends PanelContainer

func show_effect(definition: StatusDefinition, instance: StatusInstance) -> void:
	%Title.text = definition.display_name
	%Meta.text = "Stacks %d  •  %d turn(s)" % [instance.stacks, instance.remaining_turns]
	%Description.text = definition.description
	%Accent.color = definition.accent_color

func show_shield(value: int) -> void:
	%Title.text = "Shield"
	%Meta.text = "%d integrity" % value
	%Description.text = "Absorbs incoming damage before health."
	%Accent.color = Color("56d8ff")
