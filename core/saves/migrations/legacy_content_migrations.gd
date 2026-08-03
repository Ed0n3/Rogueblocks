class_name LegacyContentMigrations
extends Resource

@export var aliases: Array[LegacyContentAlias] = []

func resolve(legacy_reference: StringName, expected_type: Variant) -> Resource:
	for alias: LegacyContentAlias in aliases:
		if alias.legacy_id == legacy_reference and is_instance_of(alias.definition, expected_type):
			return alias.definition
	return null
