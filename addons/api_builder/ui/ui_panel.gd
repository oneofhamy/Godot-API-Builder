# =============================================================================
# ENHANCED UI PANEL - DIRECTORY ANALYSIS SUPPORT
# =============================================================================

@tool
extends Control

const VERSION := "1.1.0.15"
const MANIFEST := {
	"script_name": "ui_panel.gd",
	"script_path": "res://addons/api_builder/ui/ui_panel.gd",
	"version": "1.1.0",
	"description": "Enhanced UI panel for Script Analyzer with directory analysis support. Provides both single file and batch directory analysis capabilities with real-time progress tracking.",
	"required_dependencies": [
		"ScriptAnalyzer",
		"BatchProcessor", 
		"OutputFormatters",
		"AnalyzerPresets",
		"FileUtils"
	],
	"optional_dependencies": [],
	"features": [
		"single_file_analysis",
		"directory_batch_analysis", 
		"real_time_progress_tracking",
		"advanced_file_filtering",
		"multiple_output_formats",
		"collapsible_ui_panel",
		"preset_configurations",
		"export_functionality"
	],
	"ui_components": {
		"mode_selector": "Switch between single file and directory analysis",
		"file_browser": "Browse and select individual script files",
		"directory_browser": "Browse and select directories for batch analysis",
		"filter_options": "Advanced filtering with wildcards and exclusions",
		"progress_tracking": "Real-time progress bar and status updates",
		"feature_toggles": "Granular control over analysis features",
		"output_preview": "Live preview of analysis results"
	},
	"analysis_modes": ["SINGLE_FILE", "DIRECTORY"],
	"supported_formats": ["Markdown", "JSON", "YAML", "Plain Text"],
	"entry_points": ["_ready", "_on_analyze_pressed", "_on_mode_changed"],
	"api_version": "api-builder-v1.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# UI STATE AND CONFIGURATION
# =============================================================================

# UI State
var is_expanded: bool = true
var target_width: float = 250.0
var collapsed_width: float = 35.0

# Analysis modes
enum AnalysisMode {
	SINGLE_FILE,
	DIRECTORY
}

var current_mode: AnalysisMode = AnalysisMode.SINGLE_FILE

# =============================================================================
# NODE REFERENCES AND UI COMPONENTS
# =============================================================================

# Main containers
@onready var toggle_container: VBoxContainer
@onready var toggle_button: Button
@onready var header_label: Label
@onready var expanded_container: Control
@onready var scroll_container: ScrollContainer

# Mode selection
@onready var mode_option: OptionButton
@onready var target_selection_container: VBoxContainer

# UI Controls for single file
@onready var script_path_line_edit: LineEdit
@onready var browse_button: Button

# UI Controls for directory
@onready var directory_path_line_edit: LineEdit
@onready var browse_dir_button: Button
@onready var include_subdirs_check: CheckBox
@onready var file_filter_line_edit: LineEdit

@onready var refresh_button: Button

# =============================================================================
# FEATURE CONTROL CHECKBOXES
# =============================================================================

# Feature checkboxes
@onready var class_name_check: CheckBox
@onready var inheritance_check: CheckBox
@onready var methods_check: CheckBox
@onready var properties_check: CheckBox
@onready var constants_check: CheckBox
@onready var signals_check: CheckBox
@onready var groups_check: CheckBox
@onready var cross_script_calls_check: CheckBox
@onready var node_tree_check: CheckBox
@onready var connections_check: CheckBox
@onready var external_resources_check: CheckBox
@onready var object_method_calls_check: CheckBox
@onready var builtin_overrides_check: CheckBox
@onready var usage_example_check: CheckBox

# =============================================================================
# CONTROL ELEMENTS AND ACTION BUTTONS
# =============================================================================

# Controls
@onready var preset_option: OptionButton
@onready var format_option: OptionButton
@onready var output_text: TextEdit
@onready var analyze_button: Button
@onready var export_button: Button
@onready var copy_button: Button

# Feature grid for responsive layout
@onready var feature_grid: GridContainer

# Progress tracking for directory analysis
@onready var progress_bar: ProgressBar
@onready var progress_label: Label

# =============================================================================
# DIALOG SYSTEMS AND FILE MANAGEMENT
# =============================================================================

# File dialogs
var file_dialog: EditorFileDialog
var dir_dialog: EditorFileDialog
var export_dialog: EditorFileDialog

var current_script_path: String = ""
var current_directory_path: String = ""
var current_analysis: Dictionary = {}

# =============================================================================
# INITIALIZATION AND SETUP
# =============================================================================

func _ready():
	print("UI Panel _ready() called")
	_assign_node_references()
	_setup_ui()
	_connect_signals()
	_set_initial_state()

# =============================================================================
# NODE REFERENCE ASSIGNMENT
# =============================================================================

func _assign_node_references():
	# Use find_child to be more robust with node references
	# Main containers
	toggle_container = find_child("ToggleContainer")
	toggle_button = find_child("toggle_button")
	header_label = find_child("HeaderLabel")
	expanded_container = find_child("ExpandedContainer")
	scroll_container = find_child("ScrollContainer")
	
	# Mode selection
	mode_option = find_child("mode_option")
	target_selection_container = find_child("TargetSelectionContainer")
	
	# Single file selection
	script_path_line_edit = find_child("script_path_line_edit")
	browse_button = find_child("browse_button")
	
	# Directory selection
	directory_path_line_edit = find_child("directory_path_line_edit")
	browse_dir_button = find_child("browse_dir_button")
	include_subdirs_check = find_child("include_subdirs_check")
	file_filter_line_edit = find_child("file_filter_line_edit")
	
	refresh_button = find_child("refresh_button")
	
	# Progress tracking
	progress_bar = find_child("progress_bar")
	progress_label = find_child("progress_label")
	
	# Feature checkboxes
	feature_grid = find_child("FeatureCheckboxes")
	class_name_check = find_child("class_name_check")
	inheritance_check = find_child("inheritance_check")
	methods_check = find_child("methods_check")
	properties_check = find_child("properties_check")
	constants_check = find_child("constants_check")
	signals_check = find_child("signals_check")
	groups_check = find_child("groups_check")
	cross_script_calls_check = find_child("cross_script_calls_check")
	node_tree_check = find_child("node_tree_check")
	connections_check = find_child("connections_check")
	external_resources_check = find_child("external_resources_check")
	object_method_calls_check = find_child("object_method_calls_check")
	builtin_overrides_check = find_child("builtin_overrides_check")
	usage_example_check = find_child("usage_example_check")
	
	# Controls
	preset_option = find_child("preset_option")
	format_option = find_child("format_option")
	
	# Action buttons
	analyze_button = find_child("analyze_button")
	export_button = find_child("export_button")
	copy_button = find_child("copy_button")
	
	# Output
	output_text = find_child("output_text")

# =============================================================================
# UI SETUP AND CONFIGURATION
# =============================================================================

func _setup_ui():
	# Setup mode options
	mode_option.add_item("Single File")
	mode_option.add_item("Directory")
	mode_option.selected = 0
	
	# Setup preset options
	for preset_name in AnalyzerPresets.get_preset_names():
		preset_option.add_item(preset_name)
	
	# Setup format options
	format_option.add_item("Markdown")
	format_option.add_item("JSON")
	format_option.add_item("YAML")
	format_option.add_item("Plain Text")
	
	# Setup file dialogs
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.gd", "GDScript files")
	add_child(file_dialog)
	
	dir_dialog = EditorFileDialog.new()
	dir_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	add_child(dir_dialog)
	
	export_dialog = EditorFileDialog.new()
	export_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	export_dialog.add_filter("*.md", "Markdown files")
	export_dialog.add_filter("*.json", "JSON files")
	export_dialog.add_filter("*.yaml", "YAML files")
	export_dialog.add_filter("*.txt", "Text files")
	add_child(export_dialog)
	
	# Set default values
	preset_option.selected = 0
	file_filter_line_edit.text = "*.gd"
	include_subdirs_check.button_pressed = true
	
	# Hide progress initially
	progress_bar.visible = false
	progress_label.visible = false
	
	_on_preset_changed(0)
	_on_mode_changed(0)
	_update_button_states()

# =============================================================================
# PANEL STATE MANAGEMENT
# =============================================================================

func _set_initial_state():
	_update_panel_state()

func _update_panel_state():
	if is_expanded:
		toggle_button.text = "🛠"
		header_label.visible = true
		expanded_container.visible = true
		var tween = create_tween()
		tween.tween_method(_set_custom_width, custom_minimum_size.x, target_width, 0.3)
	else:
		toggle_button.text = ">"
		header_label.visible = false
		expanded_container.visible = false
		var tween = create_tween()
		tween.tween_method(_set_custom_width, custom_minimum_size.x, collapsed_width, 0.3)

func _set_custom_width(width: float):
	custom_minimum_size.x = width
	queue_redraw()

# =============================================================================
# SIGNAL CONNECTION SETUP
# =============================================================================

func _connect_signals():
	print("Connecting signals...")
	toggle_button.pressed.connect(_on_toggle_pressed)
	mode_option.item_selected.connect(_on_mode_changed)
	browse_button.pressed.connect(_on_browse_pressed)
	browse_dir_button.pressed.connect(_on_browse_dir_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)
	analyze_button.pressed.connect(_on_analyze_pressed)
	export_button.pressed.connect(_on_export_pressed)
	copy_button.pressed.connect(_on_copy_pressed)
	preset_option.item_selected.connect(_on_preset_changed)
	format_option.item_selected.connect(_on_format_changed)
	
	file_dialog.file_selected.connect(_on_file_selected)
	dir_dialog.dir_selected.connect(_on_directory_selected)
	export_dialog.file_selected.connect(_on_export_file_selected)

# =============================================================================
# EVENT HANDLERS - UI INTERACTIONS
# =============================================================================

func _on_toggle_pressed():
	print("Toggle pressed!")
	is_expanded = !is_expanded
	_update_panel_state()

# =============================================================================
# ANALYSIS MODE MANAGEMENT
# =============================================================================

func _on_mode_changed(index: int):
	current_mode = AnalysisMode.values()[index]
	_update_mode_ui()
	_update_button_states()

func _update_mode_ui():
	var single_file_group = find_child("SingleFileGroup")
	var directory_group = find_child("DirectoryGroup")
	
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			single_file_group.visible = true
			directory_group.visible = false
			usage_example_check.visible = true
		AnalysisMode.DIRECTORY:
			single_file_group.visible = false
			directory_group.visible = true
			usage_example_check.visible = false  # Not applicable for batch analysis

# =============================================================================
# FILE AND DIRECTORY SELECTION HANDLERS
# =============================================================================

func _on_browse_pressed():
	print("Browse button pressed!")
	file_dialog.popup_centered_ratio(0.8)

func _on_browse_dir_pressed():
	print("Browse directory button pressed!")
	dir_dialog.popup_centered_ratio(0.8)

func _on_file_selected(path: String):
	print("File selected: ", path)
	current_script_path = path
	script_path_line_edit.text = path.get_file()
	script_path_line_edit.tooltip_text = path
	_update_button_states()
	if current_mode == AnalysisMode.SINGLE_FILE:
		_analyze_current_script()

func _on_directory_selected(path: String):
	print("Directory selected: ", path)
	current_directory_path = path
	directory_path_line_edit.text = path.get_file()
	directory_path_line_edit.tooltip_text = path
	_update_button_states()

# =============================================================================
# ANALYSIS EXECUTION HANDLERS
# =============================================================================

func _on_refresh_pressed():
	print("Refresh pressed!")
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			if not current_script_path.is_empty():
				_analyze_current_script()
		AnalysisMode.DIRECTORY:
			if not current_directory_path.is_empty():
				_analyze_directory()

func _on_analyze_pressed():
	print("Analyze pressed!")
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			if not current_script_path.is_empty():
				_analyze_current_script()
		AnalysisMode.DIRECTORY:
			if not current_directory_path.is_empty():
				_analyze_directory()

# =============================================================================
# EXPORT AND OUTPUT MANAGEMENT
# =============================================================================

func _on_export_pressed():
	print("Export pressed!")
	if not output_text.text.is_empty():
		var format_names = ["md", "json", "yaml", "txt"]
		var ext = format_names[format_option.selected]
		var filename = ""
		
		match current_mode:
			AnalysisMode.SINGLE_FILE:
				filename = current_script_path.get_file().get_basename() + "_analysis." + ext
			AnalysisMode.DIRECTORY:
				filename = current_directory_path.get_file() + "_directory_analysis." + ext
		
		export_dialog.current_file = filename
		export_dialog.popup_centered_ratio(0.8)

func _on_export_file_selected(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(output_text.text)
		file.close()
		print("✅ Analysis exported to: ", path)
	else:
		push_error("❌ Failed to save file: " + path)

func _on_copy_pressed():
	print("Copy pressed!")
	if not output_text.text.is_empty():
		DisplayServer.clipboard_set(output_text.text)
		print("📋 Analysis copied to clipboard!")

# =============================================================================
# PRESET AND FORMAT CONFIGURATION
# =============================================================================

func _on_preset_changed(index: int):
	print("Preset changed to index: ", index)
	if index >= 0 and index < AnalyzerPresets.PresetType.size():
		var preset_type = AnalyzerPresets.PresetType.values()[index]
		var options = AnalyzerPresets.get_preset_options(preset_type)
		_apply_preset_options(options)
		_refresh_current_analysis()

func _on_format_changed(_index: int):
	print("Format changed")
	_update_output_preview()

# =============================================================================
# ANALYSIS CONFIGURATION AND OPTIONS
# =============================================================================

func _apply_preset_options(options: Dictionary):
	class_name_check.button_pressed = options.get("class_name", false)
	inheritance_check.button_pressed = options.get("inheritance", false)
	methods_check.button_pressed = options.get("methods", false)
	properties_check.button_pressed = options.get("properties", false)
	constants_check.button_pressed = options.get("constants", false)
	signals_check.button_pressed = options.get("signals", false)
	groups_check.button_pressed = options.get("groups", false)
	cross_script_calls_check.button_pressed = options.get("cross_script_calls", false)
	node_tree_check.button_pressed = options.get("node_tree", false)
	connections_check.button_pressed = options.get("connections", false)
	external_resources_check.button_pressed = options.get("external_resources", false)
	object_method_calls_check.button_pressed = options.get("object_method_calls", false)
	builtin_overrides_check.button_pressed = options.get("builtin_overrides", false)
	usage_example_check.button_pressed = options.get("usage_example", false)

func _get_current_options() -> Dictionary:
	return {
		"class_name": class_name_check.button_pressed,
		"inheritance": inheritance_check.button_pressed,
		"methods": methods_check.button_pressed,
		"properties": properties_check.button_pressed,
		"constants": constants_check.button_pressed,
		"signals": signals_check.button_pressed,
		"groups": groups_check.button_pressed,
		"cross_script_calls": cross_script_calls_check.button_pressed,
		"node_tree": node_tree_check.button_pressed,
		"connections": connections_check.button_pressed,
		"external_resources": external_resources_check.button_pressed,
		"object_method_calls": object_method_calls_check.button_pressed,
		"builtin_overrides": builtin_overrides_check.button_pressed,
		"usage_example": usage_example_check.button_pressed and current_mode == AnalysisMode.SINGLE_FILE
	}

# =============================================================================
# ANALYSIS EXECUTION - SINGLE FILE
# =============================================================================

func _refresh_current_analysis():
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			if not current_script_path.is_empty():
				_analyze_current_script()
		AnalysisMode.DIRECTORY:
			if not current_directory_path.is_empty():
				_analyze_directory()

func _analyze_current_script():
	print("Analyzing script: ", current_script_path)
	if current_script_path.is_empty():
		return
	
	var options = _get_current_options()
	current_analysis = ScriptAnalyzer.analyze_script(current_script_path, options)
	
	if options.usage_example and current_analysis.error.is_empty():
		current_analysis.usage_example = ScriptAnalyzer.generate_usage_example(current_analysis)
	
	_update_output_preview()
	_update_button_states()

# =============================================================================
# ANALYSIS EXECUTION - DIRECTORY BATCH
# =============================================================================

func _analyze_directory():
	print("Analyzing directory: ", current_directory_path)
	if current_directory_path.is_empty():
		return
	
	# Show progress
	progress_bar.visible = true
	progress_label.visible = true
	progress_label.text = "Scanning directory..."
	
	# Get script files
	var script_files = _get_script_files_from_directory()
	if script_files.is_empty():
		progress_bar.visible = false
		progress_label.visible = false
		output_text.text = "No script files found in the selected directory."
		return
	
	# Set up progress
	progress_bar.max_value = script_files.size()
	progress_bar.value = 0
	
	# Get analysis options
	var options = _get_current_options()
	
	# Perform batch analysis
	await _perform_batch_analysis(script_files, options)
	
	# Hide progress
	progress_bar.visible = false
	progress_label.visible = false
	
	_update_button_states()

# =============================================================================
# DIRECTORY SCANNING AND FILE PROCESSING
# =============================================================================

func _get_script_files_from_directory() -> Array[String]:
	var files: Array[String] = []
	var filter = file_filter_line_edit.text.strip_edges()
	if filter.is_empty():
		filter = "*.gd"
	
	var include_subdirs = include_subdirs_check.button_pressed
	
	# Use enhanced FileUtils with filtering
	files = FileUtils.get_scripts_in_directory_filtered(
		current_directory_path, 
		include_subdirs, 
		filter,
		["*/.*"]  # Exclude hidden files/folders
	)
	
	return files

func _perform_batch_analysis(script_files: Array[String], options: Dictionary):
	# Use the enhanced BatchProcessor for comprehensive directory analysis
	var batch_results = BatchProcessor.analyze_directory_comprehensive(
		current_directory_path, 
		options, 
		include_subdirs_check.button_pressed,
		file_filter_line_edit.text.strip_edges()
	)
	current_analysis = batch_results
	
	# Update progress during analysis
	for i in range(script_files.size()):
		progress_bar.value = i + 1
		progress_label.text = "Analyzing: " + script_files[i].get_file() + " (" + str(i + 1) + "/" + str(script_files.size()) + ")"
		await get_tree().process_frame  # Allow UI to update
	
	_update_output_preview()

# =============================================================================
# OUTPUT AND PREVIEW MANAGEMENT
# =============================================================================

func _update_output_preview():
	if current_analysis.is_empty():
		output_text.text = "No analysis performed yet."
		return
	
	var format = OutputFormatters.Format.values()[format_option.selected]
	var formatted_output = ""
	
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			formatted_output = OutputFormatters.format_output(current_analysis, format)
		AnalysisMode.DIRECTORY:
			formatted_output = BatchProcessor.format_batch_output(current_analysis, format)
	
	output_text.text = formatted_output

# =============================================================================
# UI STATE AND BUTTON MANAGEMENT
# =============================================================================

func _update_button_states():
	var has_target = false
	var has_output = not output_text.text.is_empty() and not "No analysis" in output_text.text
	
	match current_mode:
		AnalysisMode.SINGLE_FILE:
			has_target = not current_script_path.is_empty()
			analyze_button.text = "🔍 Select Script" if not has_target else "🔍 Analyze"
		AnalysisMode.DIRECTORY:
			has_target = not current_directory_path.is_empty()
			analyze_button.text = "📁 Select Directory" if not has_target else "🔍 Analyze Directory"
	
	analyze_button.disabled = not has_target
	refresh_button.disabled = not has_target
	export_button.disabled = not has_output
	copy_button.disabled = not has_output

# =============================================================================
# RESPONSIVE LAYOUT AND NOTIFICATIONS
# =============================================================================

# Handle responsive layout
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_adjust_for_size()

func _adjust_for_size():
	if not is_expanded or not feature_grid:
		return
		
	var available_width = size.x
	
	# Adjust grid columns based on available width
	if available_width < 200:
		feature_grid.columns = 1
	else:
		feature_grid.columns = 2
