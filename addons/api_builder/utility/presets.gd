# =============================================================================
# ENHANCED ANALYZER PRESETS - OPTIMIZED ANALYSIS CONFIGURATIONS
# =============================================================================

@tool
class_name AnalyzerPresets

const VERSION := "1.1.0.09"
const MANIFEST := {
	"script_name": "presets.gd", 
	"script_path": "res://addons/script_analyzer/utility/presets.gd",
	"class_name": "AnalyzerPresets",
	"version": "1.1.0",
	"description": "Predefined analysis presets for different use cases. Provides optimized configurations for AI integration, documentation generation, dependency analysis, and custom workflows.",
	"required_dependencies": [],
	"optional_dependencies": [],
	"features": [
		"predefined_analysis_configurations",
		"use_case_optimized_presets",
		"ai_integration_preset",
		"documentation_generation_preset",
		"dependency_analysis_preset",
		"minimal_summary_preset",
		"custom_configuration_support",
		"preset_name_mapping"
	],
	"preset_types": {
		"AI_INTEGRATION": "Comprehensive analysis for AI tools and documentation",
		"QUICK_REFERENCE_GUIDE": "Balanced analysis for human developers",
		"DOCSTRING_ONLY": "Focus on documentation extraction", 
		"MINIMAL_SUMMARY": "Essential information only",
		"API_DOC_COMPLETE": "Complete API documentation generation",
		"CUSTOM": "User-defined configuration"
	},
	"preset_features": [
		"class_inheritance_tracking",
		"method_signature_extraction",
		"property_and_variable_analysis",
		"signal_and_connection_mapping",
		"dependency_relationship_analysis", 
		"node_tree_requirements",
		"usage_example_generation"
	],
	"use_cases": [
		"ai_code_analysis",
		"documentation_generation",
		"dependency_mapping",
		"architecture_overview",
		"quick_script_summary",
		"integration_planning"                 #               .     .
	],                                         #               |\___/|
	"entry_points": [                          #               )     (
		"get_preset_options",                  #              =\     /=
		"get_preset_names"                     #                )===(
	],                                         #               /     \         
	"api_version": "script-analyzer-v2.1.0",   #               |     |
	"last_updated": "2025-08-09"               #              /       \
}                                              #              \       /
# =============================================================\__  _/=========
# ENHANCED ANALYZER PRESETS - ANALYSIS CONFIGURATIONS            ( (
# ================================================================\ \===========
											   #                   ) )
enum PresetType {                              #                   |/
	ALL,
	QUICK_REFERENCE_GUIDE,
	DOCSTRING_ONLY,
	MINIMAL_SUMMARY,
	API_DOC_COMPLETE,
	CUSTOM
}

static func get_preset_options(preset: PresetType) -> Dictionary:
	match preset:
		PresetType.QUICK_REFERENCE_GUIDE:
			return {
				"class_name": true,
				"inheritance": true,
				"methods": true,
				"properties": true,
				"constants": true,
				"signals": true,
				"groups": false,
				"cross_script_calls": true,
				"node_tree": true,
				"connections": true,
				"external_resources": false,
				"object_method_calls": false,
				"builtin_overrides": false,
				"usage_example": true
			}

		PresetType.MINIMAL_SUMMARY:
			return {
				"class_name": true,
				"inheritance": true,
				"methods": true,
				"properties": true,
				"constants": false,
				"signals": true,
				"groups": false,
				"cross_script_calls": false,
				"node_tree": false,
				"connections": false,
				"external_resources": false,
				"object_method_calls": false,
				"builtin_overrides": false,
				"usage_example": false
			}

		PresetType.ALL:
			return {
				"class_name": true,
				"inheritance": true,
				"methods": true,
				"properties": true,
				"constants": true,
				"signals": true,
				"groups": true,
				"cross_script_calls": true,
				"node_tree": true,
				"connections": true,
				"external_resources": true,
				"object_method_calls": true,
				"builtin_overrides": true,
				"usage_example": true
			}

		PresetType.API_DOC_COMPLETE:
			return {
				"class_name": true,
				"inheritance": true,
				"methods": true,
				"properties": true,
				"constants": true,
				"signals": true,
				"groups": true,
				"cross_script_calls": true,
				"node_tree": true,
				"connections": true,
				"external_resources": true,
				"object_method_calls": true,
				"builtin_overrides": true,
				"usage_example": false
			}

		PresetType.DOCSTRING_ONLY:
			return {
				"class_name": true,
				"inheritance": false,
				"methods": true,  # Only for docstrings
				"properties": false,
				"constants": false,
				"signals": false,
				"groups": false,
				"cross_script_calls": false,
				"node_tree": false,
				"connections": false,
				"external_resources": false,
				"object_method_calls": false,
				"builtin_overrides": false,
				"usage_example": false
			}
		_:
			return {}

static func get_preset_names() -> Array:
	return ["AI Integration", "Dependency Complete", "Human Integration", "Docstring Only", "Minimal Summary", "Custom"]
