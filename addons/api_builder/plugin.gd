@tool
extends EditorPlugin

const VERSION := "2.1.0.05"
const MANIFEST := {
	"script_name": "plugin.gd",
	"script_path": "res://addons/script_analyzer/plugin.gd", 
	"version": "2.1.0",
	"description": "Enhanced Script Analyzer plugin for Godot Editor. Provides comprehensive script analysis capabilities with directory support, architectural insights, and multiple output formats.",
	"required_dependencies": [
		"UIPanel",
		"ScriptAnalyzer",
		"BatchProcessor"
	],
	"optional_dependencies": [],
	"features": [
		"editor_dock_integration",
		"ui_panel_management",
		"plugin_lifecycle_management",
		"godot_editor_integration",
		"dock_slot_positioning"
	],
	"plugin_info": {
		"name": "Script Dependency Analyzer",
		"dock_name": "Script Analyzer", 
		"dock_position": "DOCK_SLOT_RIGHT_BL",
		"plugin_type": "editor_plugin"
	},
	"integration_points": [
		"editor_dock_system",
		"file_browser_integration",
		"project_management",
		"ui_panel_lifecycle"
	],
	"entry_points": [
		"_enter_tree",
		"_exit_tree"
	],
	"api_version": "script-analyzer-v2.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# API BUILDER PLUGIN
# =============================================================================

const PLUGIN_NAME = "API Builder"
const DOCK_NAME = "API Builder"

var dock

func _enter_tree():
	dock = preload("res://addons/api_builder/ui/ui_panel.tscn").instantiate()
	dock.name = "API Builder"
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	print("API Builder loaded")

func _exit_tree():
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	print("API Builder closed")
