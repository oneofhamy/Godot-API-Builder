@tool
class_name ScriptAnalyzer

const VERSION := "1.1.0.45"
const MANIFEST := {
	"script_name": "analyzer.gd",
	"script_path": "res://addons/api_builder/main/analyzer.gd",
	"class_name": "ScriptAnalyzer",
	"version": "1.1.0",
	"description": "Comprehensive GDScript analyzer with advanced parsing, reflection analysis, and code quality assessment. Supports detailed extraction of methods, properties, dependencies, node relationships, and architectural patterns.",
	"required_dependencies": [],
	"optional_dependencies": ["GDScript", "RegEx"],
	"features": [
		"comprehensive_script_parsing",
		"reflection_analysis",
		"code_quality_assessment",
		"dependency_tracking",
		"node_tree_analysis",
		"signal_connection_mapping",
		"builtin_method_detection",
		"cross_script_relationship_analysis",
		"usage_example_generation",
		"architectural_pattern_detection",
		"filter_system_support",
		"multiple_analysis_contexts"
	],
	"analysis_categories": {
		"basic_structure": ["class_name", "inheritance", "methods", "properties"],
		"advanced_features": ["constants", "signals", "groups", "cross_script_calls"],
		"dependency_analysis": ["node_tree", "connections", "external_resources"],
		"code_patterns": ["object_method_calls", "builtin_overrides"],
		"quality_metrics": ["complexity_score", "maintainability_score", "readability_score"]
	},
	"detection_capabilities": [
		"variable_declarations_all_types",
		"method_signatures_with_context", 
		"signal_definitions_and_emissions",
		"node_access_patterns",
		"resource_loading_patterns",
		"connection_establishment",
		"builtin_method_overrides",
		"enum_and_class_definitions"
	],
	"quality_analysis": [
		"complexity_calculation",
		"maintainability_scoring",
		"readability_assessment",
		"issue_identification",
		"improvement_suggestions"
	],
	"entry_points": [
		"analyze_script",
		"generate_usage_example",
		"analyze_script_dependencies",
		"generate_script_summary",
		"analyze_code_quality",
		"analyze_script_architecture"
	],
	"api_version": "api-builder-v1.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# ENHANCED SCRIPT ANALYZER - COMPREHENSIVE GDSCRIPT ANALYSIS ENGINE
# =============================================================================

static func analyze_script(script_path: String, options: Dictionary) -> Dictionary:
	var result = {
		"path": script_path,
		"class_name": "",
		"extends": "",
		"methods": [],
		"properties": [],
		"constants": [],
		"signals": [],
		"groups": [],
		"cross_script_calls": [],
		"node_tree": [],
		"connections": [],
		"external_resources": [],
		"object_method_calls": [],
		"built_in_overrides": [],
		"usage_example": "",
		"error": ""
	}
	
	if not FileAccess.file_exists(script_path):
		result.error = "File does not exist: " + script_path
		return result
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		result.error = "Cannot read file: " + script_path
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# Parse script content with enhanced detection
	_parse_script_content_enhanced(content, result, options)
	
	# Try to load script for reflection analysis
	var script = load(script_path)
	if script and script is GDScript:
		_analyze_script_reflection(script, result, options)
	
	# Generate usage example if requested
	if options.get("generate_usage", false):
		result.usage_example = generate_usage_example(result)
	
	# Apply filters if specified
	if options.has("filters"):
		_apply_filters(result, options.filters)
	
	return result

static func get_default_options() -> Dictionary:
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
		"generate_usage": false,
		"include_private": true,
		"include_builtin_overrides": true,
		"filters": {}
	}

static func _apply_filters(result: Dictionary, filters: Dictionary):
	# Filter methods if requested
	if filters.has("method_filter"):
		var method_filter = filters.method_filter
		if method_filter.has("exclude_private") and method_filter.exclude_private:
			var filtered_methods = []
			for method in result.methods:
				if not method.is_private:
					filtered_methods.append(method)
			result.methods = filtered_methods
		
		if method_filter.has("exclude_builtin_overrides") and method_filter.exclude_builtin_overrides:
			var filtered_methods = []
			for method in result.methods:
				if not method.is_builtin_override:
					filtered_methods.append(method)
			result.methods = filtered_methods
	
	# Filter properties if requested
	if filters.has("property_filter"):
		var prop_filter = filters.property_filter
		if prop_filter.has("only_exported") and prop_filter.only_exported:
			var filtered_props = []
			for prop in result.properties:
				if prop.exported:
					filtered_props.append(prop)
			result.properties = filtered_props
	
	# Filter by context
	if filters.has("context_filter"):
		var context = filters.context_filter
		for key in ["methods", "properties", "constants", "signals"]:
			if result.has(key):
				var filtered_items = []
				for item in result[key]:
					if item.context == context or context == "all":
						filtered_items.append(item)
				result[key] = filtered_items

static func _parse_script_content_enhanced(content: String, result: Dictionary, options: Dictionary):
	var lines = content.split("\n")
	var current_function_context = "global"
	var current_docstring = ""
	var in_multiline_comment = false
	var in_function = false
	var function_indent = 0
	
	for i in range(lines.size()):
		var line = lines[i]
		var trimmed_line = line.strip_edges()
		var line_number = i + 1
		
		# Skip empty lines
		if trimmed_line.is_empty():
			continue
		
		# Get current indentation
		var indent_level = line.length() - line.lstrip("\t ").length()
		
		# Handle multiline comments/docstrings
		if trimmed_line.begins_with('"""') or trimmed_line.begins_with("'''"):
			if in_multiline_comment:
				in_multiline_comment = false
				current_docstring = ""
			else:
				in_multiline_comment = true
				current_docstring = trimmed_line
			continue
			
		if in_multiline_comment:
			current_docstring += "\n" + trimmed_line
			continue
		
		# Skip single-line comments (but process them for special patterns)
		if trimmed_line.begins_with("#"):
			continue
		
		# Update function context
		if trimmed_line.begins_with("func "):
			in_function = true
			function_indent = indent_level
			var func_signature = trimmed_line.replace("func ", "").strip_edges()
			current_function_context = func_signature.split("(")[0]
		elif in_function and indent_level <= function_indent and not trimmed_line.begins_with("#"):
			in_function = false
			current_function_context = "global"
		
		# 1. CLASS NAME AND INHERITANCE
		if trimmed_line.begins_with("class_name ") and options.get("class_name", true):
			result.class_name = trimmed_line.replace("class_name ", "").strip_edges()
		
		if trimmed_line.begins_with("extends ") and options.get("inheritance", true):
			result.extends = trimmed_line.replace("extends ", "").strip_edges()
		
		# 2. ALL METHODS (including private and built-ins)
		if trimmed_line.begins_with("func ") and options.get("methods", true):
			var func_signature = trimmed_line.replace("func ", "").strip_edges()
			var method_name = func_signature.split("(")[0]
			var method_info = {
				"name": method_name,
				"signature": "func " + func_signature,
				"line": line_number,
				"context": current_function_context if current_function_context != method_name else "global",
				"docstring": current_docstring,
				"is_private": method_name.begins_with("_"),
				"is_builtin_override": _is_builtin_method(method_name),
				"source_line": trimmed_line
			}
			result.methods.append(method_info)
			
			# Track built-in overrides separately if requested
			if method_info.is_builtin_override and options.get("builtin_overrides", true):
				result.built_in_overrides.append(method_info)
		
		# 3. ALL PROPERTIES AND VARIABLES
		if options.get("properties", true):
			_extract_variables(trimmed_line, line_number, current_function_context, result)
		
		# 4. ALL CONSTANTS
		if trimmed_line.begins_with("const ") and options.get("constants", true):
			var const_def = trimmed_line.replace("const ", "").strip_edges()
			var const_parts = const_def.split("=")
			var const_info = {
				"name": const_parts[0].strip_edges(),
				"value": const_parts[1].strip_edges() if const_parts.size() > 1 else "",
				"line": line_number,
				"context": current_function_context,
				"source_line": trimmed_line
			}
			result.constants.append(const_info)
		
		# 5. ALL SIGNALS
		if trimmed_line.begins_with("signal ") and options.get("signals", true):
			var signal_def = trimmed_line.replace("signal ", "").strip_edges()
			var signal_name = signal_def.split("(")[0]
			var params = ""
			if "(" in signal_def:
				params = signal_def.substr(signal_def.find("(") + 1, signal_def.rfind(")") - signal_def.find("(") - 1)
			
			var signal_info = {
				"name": signal_name,
				"params": params.split(",") if not params.is_empty() else [],
				"line": line_number,
				"context": current_function_context,
				"source_line": trimmed_line
			}
			result.signals.append(signal_info)
		
		# 6. ALL GROUP MEMBERSHIPS
		if trimmed_line.contains("add_to_group(") and options.get("groups", true):
			var group_name = _extract_string_from_function_call(trimmed_line, "add_to_group")
			if group_name:
				result.groups.append({
					"name": group_name,
					"line": line_number,
					"context": current_function_context,
					"source_line": trimmed_line
				})
		
		# 7. ALL CROSS-SCRIPT CALLS
		if options.get("cross_script_calls", true):
			extract_cross_script_calls(trimmed_line, line_number, current_function_context, result)
		
		# 8. ALL NODE TREE ACCESS
		if options.get("node_tree", true):
			_extract_node_access(trimmed_line, line_number, current_function_context, result)
		
		# 9. ALL CONNECTIONS AND SIGNALS
		if options.get("connections", true):
			_extract_connections(trimmed_line, line_number, current_function_context, result)
		
		# 10. ALL EXTERNAL RESOURCES
		if options.get("external_resources", true):
			_extract_external_resources(trimmed_line, line_number, current_function_context, result)
		
		# 11. OBJECT METHOD CALLS
		if options.get("object_method_calls", true):
			_extract_object_method_calls(trimmed_line, line_number, current_function_context, result)
		
		# 12. ENUM DEFINITIONS
		if options.get("constants", true):
			_extract_enum_definitions(trimmed_line, line_number, current_function_context, result)
		
		# 13. INNER CLASS DEFINITIONS
		if options.get("cross_script_calls", true):
			_extract_class_definitions(trimmed_line, line_number, current_function_context, result)
		
		# 14. ADVANCED NODE PATTERNS
		if options.get("node_tree", true):
			_extract_advanced_node_patterns(trimmed_line, line_number, current_function_context, result)
		
		# Reset docstring after processing
		if trimmed_line.begins_with("func "):
			current_docstring = ""

# COMPLETE VARIABLE EXTRACTION WITH ALL PATTERNS
static func _extract_variables(line: String, line_number: int, context: String, result: Dictionary):
	var var_patterns = [
		# Standard var declarations
		r"var\s+(\w+)(?:\s*:\s*([A-Za-z_][A-Za-z0-9_]*))?\s*(?:=\s*([^#]+?))?(?:\s*#.*)?$",
		# @export var declarations
		r"@export(?:\([^)]*\))?\s+var\s+(\w+)(?:\s*:\s*([A-Za-z_][A-Za-z0-9_]*))?\s*(?:=\s*([^#]+?))?(?:\s*#.*)?$",
		# @onready var declarations
		r"@onready\s+var\s+(\w+)(?:\s*:\s*([A-Za-z_][A-Za-z0-9_]*))?\s*=\s*([^#]+?)(?:\s*#.*)?$"
	]
	
	for pattern in var_patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		var regex_result = regex.search(line)
		if regex_result:
			var var_name = regex_result.get_string(1)
			var var_type = regex_result.get_string(2) if regex_result.get_group_count() >= 2 else ""
			var var_default = regex_result.get_string(3) if regex_result.get_group_count() >= 3 else ""
			
			var var_info = {
				"name": var_name,
				"type": var_type,
				"default": var_default.strip_edges(),
				"line": line_number,
				"context": context,
				"exported": line.contains("@export"),
				"onready": line.contains("@onready"),
				"source_line": line.strip_edges()
			}
			result.properties.append(var_info)
			break

# COMPLETE CROSS-SCRIPT CALL EXTRACTION
static func extract_cross_script_calls(line: String, line_number: int, context: String, result: Dictionary):
	# 1. Preload/Load calls - extract resource path
	var preload_patterns = [
		"preload\\s*\\(\\s*[\"']([^\"']+)[\"']\\s*\\)",
		"load\\s*\\(\\s*[\"']([^\"']+)[\"']\\s*\\)"
	]
	
	for pattern in preload_patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		var preload_result = regex.search(line)
		if preload_result:
			var resource_path = preload_result.get_string(1)
			var call_data = {}
			call_data.type = "preload/load"
			call_data.target = resource_path
			call_data.target_type = infer_resource_type(resource_path)
			call_data.line = line_number
			call_data.context = context
			call_data.source_line = line.strip_edges()
			result.cross_script_calls.append(call_data)
	
	# 2. Instance creation - ClassName.new()
	var new_regex = RegEx.new()
	new_regex.compile("([A-Za-z_][A-Za-z0-9_]*)\\.new\\s*\\(")
	var search_pos = 0
	var new_result = new_regex.search(line, search_pos)
	while new_result != null:
		var target_class = new_result.get_string(1)  # Changed from class_name to target_class
		if not is_builtin_type(target_class):  # Updated variable reference
			var call_data = {}
			call_data.type = "instance_creation"
			call_data.target = target_class  # Updated variable reference
			call_data.target_type = "class"
			call_data.line = line_number
			call_data.context = context
			call_data.source_line = line.strip_edges()
			result.cross_script_calls.append(call_data)
		search_pos = new_result.get_end()
		new_result = new_regex.search(line, search_pos)
	
	# 3. Dynamic calls - call_deferred, rpc, etc.
	var dynamic_calls = ["call_deferred", "rpc", "rpc_id", "call_group", "call_group_flags"]
	for call_type in dynamic_calls:
		if line.find(call_type + "(") != -1:
			var target_method = extract_first_string_parameter(line, call_type)
			var call_data = {}
			call_data.type = call_type
			call_data.target = target_method
			call_data.target_type = "method"
			call_data.line = line_number
			call_data.context = context
			call_data.source_line = line.strip_edges()
			result.cross_script_calls.append(call_data)
			
	# 4. Scene instantiation
	if line.contains(".instantiate(") or line.contains(".instance("):
		var instance_regex = RegEx.new()
		instance_regex.compile("([A-Za-z_][A-Za-z0-9_]*)\\.(?:instantiate|instance)\\s*\\(")
		var instance_result = instance_regex.search(line)
		if instance_result:
			var call_data = {}
			call_data.type = "scene_instantiation"
			call_data.target = instance_result.get_string(1)
			call_data.target_type = "scene"
			call_data.line = line_number
			call_data.context = context
			call_data.source_line = line.strip_edges()
			result.cross_script_calls.append(call_data)

# Helper function placeholders
static func infer_resource_type(resource_path: String) -> String:
	if resource_path.ends_with(".tscn"):
		return "scene"
	elif resource_path.ends_with(".gd"):
		return "script"
	else:
		return "resource"

static func is_builtin_type(type_name: String) -> bool:
	var builtin_types = ["String", "int", "float", "bool", "Array", "Dictionary", "Vector2", "Vector3", "Node", "RefCounted"]
	return builtin_types.has(type_name)

static func extract_first_string_parameter(line: String, function_name: String) -> String:
	var regex = RegEx.new()
	regex.compile(function_name + "\\s*\\(\\s*[\"']([^\"']+)[\"']")
	var result = regex.search(line)
	if result:
		return result.get_string(1)
	return ""
# COMPLETE NODE ACCESS EXTRACTION WITH ALL PATTERNS
static func _extract_node_access(line: String, line_number: int, context: String, result: Dictionary):
	var node_patterns = [
		# get_node with string path
		{
			"pattern": r'get_node\s*\(\s*["\']([^"\']+)["\']\s*\)',
			"method": "get_node",
			"group": 1
		},
		# $ shorthand node access
		{
			"pattern": r'\$([A-Za-z_][A-Za-z0-9_/]*)',
			"method": "$",
			"group": 1
		},
		# find_child calls
		{
			"pattern": r'find_child\s*\(\s*["\']([^"\']+)["\']\s*[,)]',
			"method": "find_child",
			"group": 1
		},
		# @onready with get_node
		{
			"pattern": r'@onready\s+var\s+\w+\s*(?::\s*\w+)?\s*=\s*get_node\s*\(\s*["\']([^"\']+)["\']\s*\)',
			"method": "get_node",
			"group": 1
		},
		# @onready with $
		{
			"pattern": r'@onready\s+var\s+(\w+)\s*(?::\s*(\w+))?\s*=\s*\$([A-Za-z_][A-Za-z0-9_/]*)',
			"method": "$",
			"group": 3,
			"var_name_group": 1,
			"type_group": 2
		},
		# get_node_or_null
		{
			"pattern": r'get_node_or_null\s*\(\s*["\']([^"\']+)["\']\s*\)',
			"method": "get_node_or_null",
			"group": 1
		},
		# has_node
		{
			"pattern": r'has_node\s*\(\s*["\']([^"\']+)["\']\s*\)',
			"method": "has_node",
			"group": 1
		}
	]
	
	for pattern_info in node_patterns:
		var regex = RegEx.new()
		regex.compile(pattern_info.pattern)
		var regex_result = regex.search(line)
		if regex_result:
			var node_path = regex_result.get_string(pattern_info.group)
			var expected_type = "Node"
			
			# Try to infer type from @onready declaration
			if pattern_info.has("type_group") and regex_result.get_group_count() >= pattern_info.type_group:
				var declared_type = regex_result.get_string(pattern_info.type_group)
				if not declared_type.is_empty():
					expected_type = declared_type
			else:
				expected_type = _infer_node_type_from_context(line)
			
			var node_info = {
				"path": node_path,
				"expected_type": expected_type,
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges(),
				"access_method": pattern_info.method
			}
			
			# Add variable name if it's an @onready declaration
			if pattern_info.has("var_name_group"):
				node_info["variable_name"] = regex_result.get_string(pattern_info.var_name_group)
			
			result.node_tree.append(node_info)
			break
	
	# Advanced node access patterns
	var advanced_patterns = [
		{"pattern": r'get_viewport\s*\(\)', "method": "get_viewport", "path": "viewport"},
		{"pattern": r'get_tree\s*\(\)', "method": "get_tree", "path": "scene_tree"},
		{"pattern": r'get_parent\s*\(\)', "method": "get_parent", "path": "parent"},
		{"pattern": r'get_owner\s*\(\)', "method": "get_owner", "path": "owner"},
		{"pattern": r'get_children\s*\(\)', "method": "get_children", "path": "children"},
		{"pattern": r'find_parent\s*\(\s*["\']([^"\']+)["\']\s*\)', "method": "find_parent", "group": 1}
	]
	
	for pattern_info in advanced_patterns:
		var regex = RegEx.new()
		regex.compile(pattern_info.pattern)
		var regex_result = regex.search(line)
		if regex_result:
			var node_path = ""
			if pattern_info.has("group"):
				node_path = regex_result.get_string(pattern_info.group)
			else:
				node_path = pattern_info.path
			
			result.node_tree.append({
				"path": node_path,
				"expected_type": _get_expected_type_for_method(pattern_info.method),
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges(),
				"access_method": pattern_info.method
			})

# COMPLETE CONNECTION AND SIGNAL EXTRACTION
static func _extract_connections(line: String, line_number: int, context: String, result: Dictionary):
	# 1. Signal connect() calls with full parameter extraction
	var connect_patterns = [
		# object.signal.connect(callback)
		r'([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*connect\s*\(\s*([^,)]+)(?:\s*,\s*([^,)]*))?(?:\s*,\s*([^)]*))?\s*\)',
		# connect(signal_name, target, method)
		r'connect\s*\(\s*["\']?([^"\'(),]+)["\']?\s*,\s*([^,)]+)\s*,\s*["\']?([^"\'(),]*)["\']?(?:\s*,\s*([^)]*))?\s*\)',
		# signal_name.connect(callback)
		r'([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*connect\s*\(\s*([^,)]+)(?:\s*,\s*([^,)]*))?(?:\s*,\s*([^)]*))?\s*\)'
	]
	
	for i in range(connect_patterns.size()):
		var regex = RegEx.new()
		regex.compile(connect_patterns[i])
		var connect_result = regex.search(line)
		if connect_result:
			var connection_info = {
				"type": "connection",
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges()
			}
			
			if i == 0:  # object.signal.connect
				connection_info["sender"] = connect_result.get_string(1)
				connection_info["signal"] = connect_result.get_string(2)
				connection_info["callback"] = connect_result.get_string(3)
				connection_info["receiver"] = _extract_receiver_from_callback(connect_result.get_string(3))
			elif i == 1:  # connect(signal, target, method)
				connection_info["signal"] = connect_result.get_string(1)
				connection_info["receiver"] = connect_result.get_string(2)
				connection_info["callback"] = connect_result.get_string(3)
				connection_info["sender"] = "self"
			else:  # signal.connect
				connection_info["signal"] = connect_result.get_string(1)
				connection_info["callback"] = connect_result.get_string(2)
				connection_info["receiver"] = _extract_receiver_from_callback(connect_result.get_string(2))
				connection_info["sender"] = "self"
			
			result.connections.append(connection_info)
			break
	
	# 2. Signal emission detection
	var emit_patterns = [
		r'([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*emit\s*\(',
		r'emit_signal\s*\(\s*["\']([^"\']+)["\']\s*[,)]',
		r'([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*emit_signal\s*\('
	]
	
	for i in range(emit_patterns.size()):
		var regex = RegEx.new()
		regex.compile(emit_patterns[i])
		var emit_result = regex.search(line)
		if emit_result:
			var emission_info = {
				"type": "emission",
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges(),
				"sender": "self"
			}
			
			if i == 0:  # signal.emit()
				emission_info["signal"] = emit_result.get_string(1)
			elif i == 1:  # emit_signal("signal_name")
				emission_info["signal"] = emit_result.get_string(1)
			else:  # object.emit_signal()
				emission_info["sender"] = emit_result.get_string(1)
				emission_info["signal"] = "unknown"
			
			result.connections.append(emission_info)
			break

# COMPLETE EXTERNAL RESOURCE EXTRACTION
static func _extract_external_resources(line: String, line_number: int, context: String, result: Dictionary):
	# Resource path patterns in strings
	var resource_patterns = [
		r'["\'](?:res://|user://|uid://)[^"\']*\.[a-zA-Z0-9]+["\']',
		r'["\']([^"\']*\.(gd|cs|png|jpg|jpeg|svg|wav|ogg|mp3|tscn|scn|tres|res|json|txt|cfg))["\']'
	]
	
	for pattern in resource_patterns:
		var regex = RegEx.new()
		regex.compile(pattern)
		var resource_results = regex.search_all(line)
		for regex_match in resource_results:
			var full_path = regex_match.get_string(0).strip_edges()
			var quote_regex = RegEx.new()
			quote_regex.compile("^[\"']|[\"']$")
			full_path = quote_regex.sub(full_path, "", true)
			
			# Skip if it's a common non-resource string
			if _is_likely_resource_path(full_path):
				result.external_resources.append({
					"path": full_path,
					"type": _infer_resource_type(full_path),
					"line": line_number,
					"context": context,
					"source_line": line.strip_edges()
				})

# COMPLETE OBJECT METHOD CALL EXTRACTION
static func _extract_object_method_calls(line: String, line_number: int, context: String, result: Dictionary):
	# Pattern for object.method() calls
	var method_call_regex = RegEx.new()
	method_call_regex.compile(r'([A-Za-z_][A-Za-z0-9_]*)\s*\.\s*([A-Za-z_][A-Za-z0-9_]*)\s*\(')
	var method_results = method_call_regex.search_all(line)
	
	for regex_match in method_results:
		var object_name = regex_match.get_string(1)
		var method_name = regex_match.get_string(2)
		
		# Skip self references, common built-ins, and certain patterns
		if object_name not in ["self", "super"] and not _is_common_builtin_object(object_name) and not _is_builtin_type(object_name):
			# Try to determine object type
			var object_type = _infer_object_type(object_name, line)
			
			result.object_method_calls.append({
				"object": object_name,
				"method": method_name,
				"object_type": object_type,
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges()
			})

# ENHANCED HELPER FUNCTIONS WITH COMPLETE IMPLEMENTATIONS
static func _is_builtin_method(method_name: String) -> bool:
	var builtin_methods = [
		"_ready", "_process", "_physics_process", "_draw", "_input", "_unhandled_input",
		"_enter_tree", "_exit_tree", "_notification", "_init", "_get", "_set",
		"_get_property_list", "_validate_property", "_to_string", "_can_drop_data",
		"_drop_data", "_get_drag_data", "_gui_input", "_on_area_entered", "_on_body_entered",
		"_integrate_forces", "_on_timeout", "_on_pressed", "_on_toggled"
	]
	return method_name in builtin_methods

static func _extract_string_from_function_call(line: String, func_name: String) -> String:
	var regex = RegEx.new()
	regex.compile(func_name + r'\s*\(\s*["\']([^"\']+)["\']\s*[,)]')
	var regex_result = regex.search(line)
	if regex_result:
		return regex_result.get_string(1)
	return ""

static func _extract_first_string_parameter(line: String, func_name: String) -> String:
	var regex = RegEx.new()
	regex.compile(func_name + r'\s*\(\s*["\']([^"\']+)["\']')
	var regex_result = regex.search(line)
	if regex_result:
		return regex_result.get_string(1)
	return ""

static func _infer_node_type_from_context(line: String) -> String:
	# Try to infer type from variable declaration
	var type_regex = RegEx.new()
	type_regex.compile(r':\s*([A-Za-z_][A-Za-z0-9_]*)')
	var type_result = type_regex.search(line)
	if type_result:
		return type_result.get_string(1)
	
	# Infer from common patterns
	if "Sprite" in line:
		return "Sprite2D"
	elif "Label" in line:
		return "Label"
	elif "Button" in line:
		return "Button"
	elif "Area" in line:
		return "Area2D"
	elif "Body" in line:
		return "RigidBody2D"
	
	return "Node"

static func _infer_resource_type(path: String) -> String:
	var extension = path.get_extension().to_lower()
	var type_map = {
		"gd": "GDScript",
		"cs": "C# Script",
		"png": "Texture2D",
		"jpg": "Texture2D",
		"jpeg": "Texture2D",
		"svg": "Texture2D",
		"wav": "AudioStream",
		"ogg": "AudioStream",
		"mp3": "AudioStream",
		"tscn": "PackedScene",
		"scn": "PackedScene",
		"tres": "Resource",
		"res": "Resource",
		"json": "JSON",
		"txt": "Text File",
		"cfg": "Configuration"
	}
	
	return type_map.get(extension, "Resource")

static func _is_common_builtin_object(object_name: String) -> bool:
	var builtins = ["print", "push_warning", "push_error", "len", "range", "str", "int", "float", "bool", "Vector2", "Vector3", "Color"]
	return object_name in builtins

static func _is_builtin_type(type_name: String) -> bool:
	var builtin_types = [
		"int", "float", "bool", "String", "Vector2", "Vector3", "Color", "Array", "Dictionary",
		"PackedStringArray", "PackedByteArray", "PackedInt32Array", "PackedFloat32Array",
		"Node", "Control", "Sprite2D", "Area2D", "RigidBody2D", "CharacterBody2D", "Timer", "AudioStreamPlayer"
	]
	return type_name in builtin_types

static func _extract_receiver_from_callback(callback: String) -> String:
	# Extract receiver from callback like "self._on_signal" or "object.method"
	var parts = callback.split(".")
	if parts.size() > 1:
		return parts[0].strip_edges()
	return "self"

static func _is_likely_resource_path(path: String) -> bool:
	# Check if the string is likely a resource path (not just any string)
	return (path.begins_with("res://") or path.begins_with("user://") or path.begins_with("uid://") or 
			path.contains(".gd") or path.contains(".tscn") or path.contains(".png") or 
			path.contains(".jpg") or path.contains(".wav") or path.contains(".ogg"))

static func _infer_object_type(object_name: String, line: String) -> String:
	# Try to infer object type from context
	if object_name in ["player", "Player"]:
		return "Player"
	elif object_name in ["enemy", "Enemy"]:
		return "Enemy"
	elif object_name.ends_with("_timer") or object_name.contains("Timer"):
		return "Timer"
	elif object_name.contains("sprite") or object_name.contains("Sprite"):
		return "Sprite2D"
	elif object_name.contains("label") or object_name.contains("Label"):
		return "Label"
	return "Object"

static func _get_expected_type_for_method(method: String) -> String:
	var method_types = {
		"get_viewport": "Viewport",
		"get_tree": "SceneTree",
		"get_parent": "Node",
		"get_owner": "Node",
		"get_children": "Array[Node]",
		"find_parent": "Node"
	}
	return method_types.get(method, "Node")

static func _extract_enum_definitions(line: String, line_number: int, context: String, result: Dictionary):
	if line.strip_edges().begins_with("enum "):
		var enum_match = RegEx.new()
		enum_match.compile(r'enum\s+(\w+)\s*\{')
		var enum_result = enum_match.search(line)
		if enum_result:
			result.constants.append({
				"name": enum_result.get_string(1),
				"value": "enum",
				"line": line_number,
				"context": context,
				"type": "enum",
				"source_line": line.strip_edges()
			})

static func _extract_class_definitions(line: String, line_number: int, context: String, result: Dictionary):
	# Inner class definitions
	if line.strip_edges().begins_with("class "):
		var class_match = RegEx.new()
		class_match.compile(r'class\s+(\w+)(?:\s+extends\s+(\w+))?')
		var class_result = class_match.search(line)
		if class_result:
			result.cross_script_calls.append({
				"type": "inner_class",
				"target": class_result.get_string(1),
				"extends": class_result.get_string(2) if class_result.get_group_count() >= 2 else "",
				"line": line_number,
				"context": context,
				"source_line": line.strip_edges()
			})

static func _extract_advanced_node_patterns(line: String, line_number: int, context: String, result: Dictionary):
	# This is already handled in _extract_node_access, so we can make this a no-op
	pass

static func _analyze_script_reflection(script: GDScript, result: Dictionary, options: Dictionary):
	# Enhanced reflection analysis using GDScript's get_script_method_list, etc.
	if script.has_method("get_script_method_list"):
		var methods = script.get_script_method_list()
		for method_info in methods:
			# Cross-reference with parsed methods to add additional info
			for parsed_method in result.methods:
				if parsed_method.name == method_info.name:
					parsed_method["return_type"] = method_info.get("return", {}).get("type", "")
					parsed_method["args"] = method_info.get("args", [])
					break
	
	# Get script constants via reflection
	var script_constants = script.get_script_constant_map()
	for constant_name in script_constants:
		# Add reflection info to parsed constants
		for parsed_const in result.constants:
			if parsed_const.name == constant_name:
				parsed_const["reflected_value"] = str(script_constants[constant_name])
				break

static func generate_usage_example(result: Dictionary) -> String:
	var example = "```gdscript\n"
	
	if not result.class_name.is_empty():
		example += "# Using " + result.class_name + "\n"
		example += "const " + result.class_name + " = preload(\"" + result.path + "\")\n"
		example += "var instance = " + result.class_name + ".new()\n"
	else:
		example += "# Using script\n"
		example += "var instance = load(\"" + result.path + "\").new()\n"
	
	# Add initialization if _ready exists
	var has_ready = false
	for method in result.methods:
		if method.name == "_ready":
			has_ready = true
			break
	
	if has_ready:
		example += "# _ready() will be called automatically when added to scene tree\n"
		example += "add_child(instance)\n"
	
	# Add some method calls (non-private, non-built-in)
	for method in result.methods:
		var method_name = method.name
		if not method_name.begins_with("_") and method_name != "new" and not method.is_builtin_override:
			example += "instance." + method_name + "()\n"
			break
	
	# Add signal connections if any
	if result.signals.size() > 0:
		var first_signal = result.signals[0]
		example += "instance." + first_signal.name + ".connect(_on_signal_received)\n"
	
	# Show required nodes if any
	if result.node_tree.size() > 0:
		example += "\n# Required node structure:\n"
		for node in result.node_tree:
			if node.path != "viewport" and node.path != "scene_tree":
				example += "# - " + node.path + " (" + node.expected_type + ")\n"
	return example
# UTILITY FUNCTIONS FOR SCRIPT ANALYSIS

static func analyze_script_dependencies(script_path: String) -> Array:
	"""Get all dependencies (scripts, scenes, resources) that this script references"""
	var options = get_default_options()
	var result = analyze_script(script_path, options)
	var dependencies = []
	
	# Add cross-script calls
	for call in result.cross_script_calls:
		if call.type in ["preload/load", "scene_instantiation"]:
			dependencies.append({
				"path": call.target,
				"type": call.target_type,
				"usage": call.type,
				"line": call.line
			})
	
	# Add external resources
	for resource in result.external_resources:
		dependencies.append({
			"path": resource.path,
			"type": resource.type,
			"usage": "resource_reference",
			"line": resource.line
		})
	
	return dependencies

static func generate_script_summary(script_path: String) -> Dictionary:
	"""Generate a comprehensive summary of the script"""
	var options = get_default_options()
	options.generate_usage = true
	var result = analyze_script(script_path, options)
	
	var summary = {
		"overview": {
			"path": script_path,
			"class_name": result.class_name,
			"extends": result.extends,
			"total_lines": _count_lines_in_file(script_path)
		},
		"structure": {
			"method_count": result.methods.size(),
			"property_count": result.properties.size(),
			"signal_count": result.signals.size(),
			"constant_count": result.constants.size()
		},
		"complexity": {
			"public_methods": _count_public_methods(result.methods),
			"private_methods": _count_private_methods(result.methods),
			"builtin_overrides": result.built_in_overrides.size(),
			"node_dependencies": result.node_tree.size(),
			"external_dependencies": result.external_resources.size()
		},
		"patterns": {
			"uses_signals": result.signals.size() > 0,
			"uses_groups": result.groups.size() > 0,
			"exports_properties": _has_exported_properties(result.properties),
			"has_onready_vars": _has_onready_vars(result.properties)
		}
	}
	
	return summary

static func find_unused_methods(script_path: String) -> Array:
	"""Find methods that might be unused (not called within the script)"""
	var result = analyze_script(script_path, get_default_options())
	var unused = []
	var called_methods = []
	
	# Collect all method calls
	for call in result.object_method_calls:
		called_methods.append(call.method)
	
	# Check each method
	for method in result.methods:
		var method_name = method.name
		# Skip built-in overrides and private methods starting with _on_
		if not method.is_builtin_override and not method_name.begins_with("_on_"):
			if method_name not in called_methods:
				unused.append(method)
	
	return unused

static func validate_node_references(script_path: String) -> Dictionary:
	"""Validate that node references are consistent"""
	var result = analyze_script(script_path, get_default_options())
	var validation = {
		"valid_references": [],
		"potential_issues": [],
		"suggestions": []
	}
	
	for node_ref in result.node_tree:
		var issue_found = false
		
		# Check for absolute vs relative paths
		if node_ref.path.begins_with("/"):
			validation.potential_issues.append({
				"type": "absolute_path",
				"line": node_ref.line,
				"message": "Absolute node path '" + node_ref.path + "' may break if scene structure changes"
			})
			issue_found = true
		
		# Check for deeply nested paths
		if node_ref.path.count("/") > 3:
			validation.potential_issues.append({
				"type": "deep_nesting",
				"line": node_ref.line,
				"message": "Deep node path '" + node_ref.path + "' may be fragile"
			})
			issue_found = true
		
		if not issue_found:
			validation.valid_references.append(node_ref)
	return validation
# HELPER FUNCTIONS FOR SUMMARIES AND ANALYSIS

static func _count_lines_in_file(file_path: String) -> int:
	if not FileAccess.file_exists(file_path):
		return 0
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return 0
	
	var content = file.get_as_text()
	file.close()
	
	return content.split("\n").size()

static func _count_public_methods(methods: Array) -> int:
	var count = 0
	for method in methods:
		if not method.is_private and not method.is_builtin_override:
			count += 1
	return count

static func _count_private_methods(methods: Array) -> int:
	var count = 0
	for method in methods:
		if method.is_private and not method.is_builtin_override:
			count += 1
	return count

static func _has_exported_properties(properties: Array) -> bool:
	for prop in properties:
		if prop.exported:
			return true
	return false

static func _has_onready_vars(properties: Array) -> bool:
	for prop in properties:
		if prop.onready:
			return true
	return false

# ADVANCED ANALYSIS FUNCTIONS

static func analyze_script_architecture(script_path: String) -> Dictionary:
	"""Analyze the architectural patterns used in the script"""
	var result = analyze_script(script_path, get_default_options())
	var architecture = {
		"design_patterns": [],
		"coupling_level": "unknown",
		"cohesion_score": 0.0,
		"responsibilities": []
	}
	
	# Detect common design patterns
	_detect_design_patterns(result, architecture)
	
	# Analyze coupling (dependencies on external scripts/scenes)
	architecture.coupling_level = _analyze_coupling_level(result)
	
	# Calculate cohesion score (how related the methods are)
	architecture.cohesion_score = _calculate_cohesion_score(result)
	
	# Identify main responsibilities
	architecture.responsibilities = identify_responsibilities(result)
	
	return architecture

static func _detect_design_patterns(result: Dictionary, architecture: Dictionary):
	var patterns = []
	
	# Singleton pattern detection
	if _has_singleton_pattern(result):
		patterns.append("Singleton")
	
	# Observer pattern (signals)
	if result.signals.size() > 2:
		patterns.append("Observer")
	
	# State pattern (enum + match statements)
	if _has_state_pattern(result):
		patterns.append("State")
	
	# Factory pattern (multiple .new() calls)
	if _has_factory_pattern(result):
		patterns.append("Factory")
	
	architecture.design_patterns = patterns

static func _has_singleton_pattern(result: Dictionary) -> bool:
	# Look for static instance variables and getInstance methods
	for prop in result.properties:
		if "instance" in prop.name.to_lower() and prop.context == "global":
			return true
	for method in result.methods:
		if "get_instance" in method.name.to_lower():
			return true
	return false

static func _has_state_pattern(result: Dictionary) -> bool:
	var has_state_enum = false
	var has_state_variable = false
	
	for constant in result.constants:
		if constant.has("type") and constant.type == "enum" and "state" in constant.name.to_lower():
			has_state_enum = true
			break
	
	for prop in result.properties:
		if "state" in prop.name.to_lower():
			has_state_variable = true
			break
	
	return has_state_enum and has_state_variable

static func _has_factory_pattern(result: Dictionary) -> bool:
	var creation_calls = 0
	for call in result.cross_script_calls:
		if call.type == "instance_creation":
			creation_calls += 1
	return creation_calls > 2

static func _analyze_coupling_level(result: Dictionary) -> String:
	var external_dependencies = result.external_resources.size() + result.cross_script_calls.size()
	
	if external_dependencies == 0:
		return "none"
	elif external_dependencies <= 3:
		return "low"
	elif external_dependencies <= 7:
		return "medium"
	else:
		return "high"

static func _calculate_cohesion_score(result: Dictionary) -> float:
	if result.methods.size() == 0:
		return 0.0
	
	# Simple cohesion metric based on shared data usage
	var total_data_access = 0
	var shared_data_access = 0
	
	# Count property access across methods
	var property_usage = {}
	for prop in result.properties:
		property_usage[prop.name] = 0
	
	# This is a simplified calculation - in a real implementation,
	# you'd analyze method bodies for property access
	for method in result.methods:
		total_data_access += 1
		# Simplified: assume each method accesses some properties
		shared_data_access += 1
	
	if total_data_access == 0:
		return 0.0
	
	return float(shared_data_access) / float(total_data_access)

static func identify_responsibilities(result: Dictionary) -> Array:
	var responsibilities = []
	
	# Analyze method names to infer responsibilities
	var method_categories = {
		"ui": [],
		"physics": [],
		"audio": [],
		"input": [],
		"networking": [],
		"data": [],
		"animation": []
	}
	
	for method in result.methods:
		var method_name = method.name.to_lower()
		
		if "ui" in method_name or "button" in method_name or "menu" in method_name:
			method_categories.ui.append(method.name)
		elif "physics" in method_name or "collision" in method_name or "body" in method_name:
			method_categories.physics.append(method.name)
		elif "audio" in method_name or "sound" in method_name or "music" in method_name:
			method_categories.audio.append(method.name)
		elif "input" in method_name or "key" in method_name or "mouse" in method_name:
			method_categories.input.append(method.name)
		elif "network" in method_name or "rpc" in method_name or "multiplayer" in method_name:
			method_categories.networking.append(method.name)
		elif "save" in method_name or "load" in method_name or "data" in method_name:
			method_categories.data.append(method.name)
		elif "anim" in method_name or "tween" in method_name:
			method_categories.animation.append(method.name)
	
	# Add responsibilities that have methods
	for category in method_categories:
		if method_categories[category].size() > 0:
			responsibilities.append({
				"category": category,
				"methods": method_categories[category],
				"count": method_categories[category].size()
			})
	return responsibilities
# PERFORMANCE AND QUALITY ANALYSIS

static func analyze_code_quality(script_path: String) -> Dictionary:
	"""Analyze code quality metrics"""
	var result = analyze_script(script_path, get_default_options())
	var quality = {
		"complexity_score": 0.0,
		"maintainability_score": 0.0,
		"readability_score": 0.0,
		"issues": [],
		"suggestions": []
	}
	
	# Calculate complexity score
	quality.complexity_score = _calculate_complexity_score(result)
	
	# Calculate maintainability score
	quality.maintainability_score = _calculate_maintainability_score(result)
	
	# Calculate readability score
	quality.readability_score = _calculate_readability_score(result)
	
	# Identify potential issues
	quality.issues = _identify_quality_issues(result)
	
	# Generate improvement suggestions
	quality.suggestions = _generate_quality_suggestions(result, quality)
	
	return quality

static func _calculate_complexity_score(result: Dictionary) -> float:
	var complexity = 0.0
	
	# Method count factor
	complexity += result.methods.size() * 0.1
	
	# Nested method calls factor
	complexity += result.object_method_calls.size() * 0.05
	
	# External dependencies factor
	complexity += (result.external_resources.size() + result.cross_script_calls.size()) * 0.15
	
	# Node tree complexity
	complexity += result.node_tree.size() * 0.08
	
	# Normalize to 0-10 scale
	return min(complexity, 10.0)

static func _calculate_maintainability_score(result: Dictionary) -> float:
	var score = 10.0  # Start with perfect score
	
	# Deduct for high complexity
	var complexity = _calculate_complexity_score(result)
	score -= complexity * 0.3
	
	# Deduct for missing documentation
	var documented_methods = 0
	for method in result.methods:
		if not method.docstring.is_empty():
			documented_methods += 1
	
	if result.methods.size() > 0:
		var doc_ratio = float(documented_methods) / float(result.methods.size())
		score += doc_ratio * 2.0  # Bonus for documentation
	
	# Deduct for too many responsibilities
	var responsibilities = identify_responsibilities(result)
	if responsibilities.size() > 5:
		score -= (responsibilities.size() - 5) * 0.5
	
	return max(0.0, min(score, 10.0))

static func _calculate_readability_score(result: Dictionary) -> float:
	var score = 7.0  # Start with good score
	
	# Bonus for descriptive names
	var well_named_methods = 0
	for method in result.methods:
		if method.name.length() > 3 and not method.name.begins_with("_"):
			well_named_methods += 1
	
	if result.methods.size() > 0:
		var naming_ratio = float(well_named_methods) / float(result.methods.size())
		score += naming_ratio * 1.5
	
	# Bonus for exported properties (good for editor integration)
	if _has_exported_properties(result.properties):
		score += 0.5
	
	# Deduct for too many private methods (might indicate poor organization)
	var private_method_count = _count_private_methods(result.methods)
	var total_methods = result.methods.size()
	if total_methods > 0 and float(private_method_count) / float(total_methods) > 0.7:
		score -= 1.0
	
	return max(0.0, min(score, 10.0))

static func _identify_quality_issues(result: Dictionary) -> Array:
	var issues = []
	
	# Too many methods in one script
	if result.methods.size() > 20:
		issues.append({
			"type": "complexity",
			"severity": "medium",
			"message": "Script has many methods (" + str(result.methods.size()) + "). Consider splitting into smaller classes."
		})
	
	# Missing class name
	if result.class_name.is_empty() and result.methods.size() > 5:
		issues.append({
			"type": "organization",
			"severity": "low",
			"message": "Consider adding a class_name for better organization and reusability."
		})
	
	# Too many external dependencies
	var external_deps = result.external_resources.size() + result.cross_script_calls.size()
	if external_deps > 10:
		issues.append({
			"type": "coupling",
			"severity": "high",
			"message": "High number of external dependencies (" + str(external_deps) + "). Consider reducing coupling."
		})
	
	# No signals but many methods (might need better event handling)
	if result.signals.size() == 0 and result.methods.size() > 10:
		issues.append({
			"type": "design",
			"severity": "low",
			"message": "Consider using signals for better decoupling and event-driven architecture."
		})
	
	return issues

static func _generate_quality_suggestions(result: Dictionary, quality: Dictionary) -> Array:
	var suggestions = []
	
	# Suggest documentation if lacking
	var documented_methods = 0
	for method in result.methods:
		if not method.docstring.is_empty():
			documented_methods += 1
	
	if result.methods.size() > 0 and float(documented_methods) / float(result.methods.size()) < 0.3:
		suggestions.append("Add docstrings to methods for better maintainability")
	
	# Suggest refactoring if complex
	if quality.complexity_score > 7.0:
		suggestions.append("Consider breaking down complex methods into smaller, focused functions")
	
	# Suggest using @export for configuration
	var has_constants = result.constants.size() > 0
	var has_exports = _has_exported_properties(result.properties)
	if has_constants and not has_exports:
		suggestions.append("Consider using @export for configurable constants to make them editable in the editor")
	
	# Suggest signal usage for decoupling
	if result.methods.size() > 8 and result.signals.size() == 0:
		suggestions.append("Consider adding signals to improve modularity and reduce tight coupling")
	
	return suggestions
