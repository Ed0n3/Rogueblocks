class_name ContentReferenceCodec
extends RefCounted

const LEGACY_MIGRATIONS: LegacyContentMigrations = preload("res://content/legacy_content_migrations.tres")

static func encode(definition: Resource) -> String:
	if definition == null or definition.resource_path.is_empty():
		return ""
	var resource_uid: int = ResourceLoader.get_resource_uid(definition.resource_path)
	if resource_uid != ResourceUID.INVALID_ID:
		return ResourceUID.id_to_text(resource_uid)
	return definition.resource_path

static func decode(reference: String, expected_type: Variant) -> Resource:
	if reference.is_empty():
		return null
	var resource_path: String = reference
	if reference.begins_with("uid://"):
		var resource_uid: int = ResourceUID.text_to_id(reference)
		resource_path = ResourceUID.get_id_path(resource_uid)
	if resource_path.is_empty() or not ResourceLoader.exists(resource_path):
		return null
	var definition: Resource = ResourceLoader.load(resource_path) as Resource
	return definition if is_instance_of(definition, expected_type) else null

static func decode_legacy(reference: String, expected_type: Variant, catalog: ContentCatalog) -> Resource:
	var definition: Resource = decode(reference, expected_type)
	if definition != null or catalog == null:
		return definition
	definition = catalog.resolve_legacy(StringName(reference), expected_type)
	return definition if definition != null else LEGACY_MIGRATIONS.resolve(StringName(reference), expected_type)
