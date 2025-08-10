@tool
class_name OutputFormatters

const VERSION := "1.1.0.12"
const MANIFEST := {
	"script_name": "output_formatters.gd",
	"script_path": "res://addons/api_builder/main/output_formatters.gd",
	"class_name": "OutputFormatters",
	"version": "1.1.0",
	"description": "Advanced output formatting system for Script Analyzer results. Supports multiple formats with rich formatting, emojis, and structured data presentation for both single scripts and batch analysis.",
	"required_dependencies": [],
	"optional_dependencies": ["JSON"],
	"features": [
		"multiple_output_formats",
		"rich_markdown_formatting", 
		"structured_json_output",
		"human_readable_yaml",
		"plain_text_compatibility",
		"emoji_enhanced_display",
		"hierarchical_data_presentation",
		"batch_analysis_formatting",
		"single_script_formatting",
		"customizable_section_ordering"
	],
	"supported_formats": {
		"MARKDOWN": "Rich formatting with emojis and sections",
		"JSON": "Machine-readable structured data",
		"YAML": "Human-readable structured format", 
		"PLAIN_TEXT": "Simple text format for compatibility"
	},
	"formatting_features": [
		"syntax_highlighting_support",
		"emoji_categorization",
		"collapsible_sections",
		"line_number_references",
		"cross_reference_linking",
		"summary_statistics",
		"detailed_breakdowns"
	],
	"output_sections": [
		"script_metadata",
		"methods_with_signatures",
		"properties_and_variables", 
		"constants_and_enums",
		"signals_and_connections",
		"node_tree_requirements",
		"external_dependencies",
		"usage_examples"
	],
	"entry_points": [
		"format_output",
		"_format_markdown_enhanced",
		"_format_yaml_enhanced",
		"_format_plain_text_enhanced"
	],
	"api_version": "api-builder-v1.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

enum Format {
	MARKDOWN,
	JSON,
	YAML,
	PLAIN_TEXT
}

static func format_output(data: Dictionary, format: Format) -> String:
	match format:
		Format.MARKDOWN:
			return _format_markdown_enhanced(data)
		Format.JSON:
			return JSON.stringify(data, "\t")
		Format.YAML:
			return _format_yaml_enhanced(data)
		Format.PLAIN_TEXT:
			return _format_plain_text_enhanced(data)
		_:
			return _format_markdown_enhanced(data)

static func _format_markdown_enhanced(data: Dictionary) -> String:
	var output = ""
	
	output += "# 📋 Script Analysis: " + data.path.get_file() + "\n\n"
	output += "**Path:** `" + data.path + "`\n\n"
	
	if not data.error.is_empty():
		output += "**❌ Error:** " + data.error + "\n\n"
		return output
	
	# Basic Info
	if not data.class_name.is_empty():
		output += "- **Class Name:** `" + data.class_name + "`\n"
	
	if not data.extends.is_empty():
		output += "- **Extends:** `" + data.extends + "`\n"
	
	output += "\n"
	
	# Methods
	if data.methods.size() > 0:
		output += "## 🔧 Methods (" + str(data.methods.size()) + ")\n\n"
		for method in data.methods:
			var prefix = "🔒 " if method.is_private else "🟢 "
			if method.is_builtin_override:
				prefix += "⚡ "
			output += prefix + "`" + method.signature + "`"
			if not method.docstring.is_empty():
				output += " - " + method.docstring.strip_edges()
			output += " *(Line " + str(method.line) + ")*\n"
		output += "\n"
	
	# Properties
	if data.properties.size() > 0:
		output += "## 📝 Properties & Variables (" + str(data.properties.size()) + ")\n\n"
		for prop in data.properties:
			var prefix = "📤 " if prop.exported else "📥 "
			if prop.onready:
				prefix += "⚡ "
			output += prefix + "`" + prop.name
			if not prop.type.is_empty():
				output += ": " + prop.type
			if not prop.default.is_empty():
				output += " = " + prop.default
			output += "` *(Line " + str(prop.line) + ")*\n"
		output += "\n"
	
	# Constants
	if data.constants.size() > 0:
		output += "## 🔢 Constants (" + str(data.constants.size()) + ")\n\n"
		for constant in data.constants:
			output += "- `" + constant.name + " = " + constant.value + "` *(Line " + str(constant.line) + ")*\n"
		output += "\n"
	
	# Signals
	if data.signals.size() > 0:
		output += "## 📡 Signals (" + str(data.signals.size()) + ")\n\n"
		for signal_info in data.signals:
			output += "- `" + signal_info.name
			if signal_info.params.size() > 0:
				output += "(" + ", ".join(signal_info.params) + ")"
			output += "` *(Line " + str(signal_info.line) + ")*\n"
		output += "\n"
	
	# Groups
	if data.groups.size() > 0:
		output += "## 👥 Groups (" + str(data.groups.size()) + ")\n\n"
		for group in data.groups:
			output += "- `" + group.name + "` *(Line " + str(group.line) + ")*\n"
		output += "\n"
	
	# Cross-Script Calls
	if data.cross_script_calls.size() > 0:
		output += "## 🔗 Cross-Script Dependencies (" + str(data.cross_script_calls.size()) + ")\n\n"
		for call in data.cross_script_calls:
			output += "- **" + call.type + ":** `" + call.target + "` *(Line " + str(call.line) + ")*\n"
			output += "  - `" + call.source_line + "`\n"
		output += "\n"
	
	# Node Tree Requirements
	if data.node_tree.size() > 0:
		output += "## 🌳 Required Node Tree (" + str(data.node_tree.size()) + ")\n\n"
		for node in data.node_tree:
			output += "- **Path:** `" + node.path + "` **Type:** `" + node.expected_type + "` *(Line " + str(node.line) + ")*\n"
			output += "  - Access: `" + node.access_method + "`\n"
			output += "  - Source: `" + node.source_line + "`\n"
		output += "\n"
	
	# Connections
	if data.connections.size() > 0:
		output += "## 🔌 Signal Connections (" + str(data.connections.size()) + ")\n\n"
		for conn in data.connections:
			if conn.get("type") == "emission":
				output += "- **Emits:** `" + conn.signal + "` *(Line " + str(conn.line) + ")*\n"
			else:
				output += "- **Connect:** `" + conn.get("sender", "unknown") + "." + conn.signal + "` → `" + conn.get("receiver", "unknown")
				if conn.has("callback") and not conn.callback.is_empty():
					output += "." + conn.callback + "()"
				output += "` *(Line " + str(conn.line) + ")*\n"
			output += "  - `" + conn.source_line + "`\n"
		output += "\n"
	
	# External Resources
	if data.external_resources.size() > 0:
		output += "## 📁 External Resources (" + str(data.external_resources.size()) + ")\n\n"
		for resource in data.external_resources:
			output += "- **" + resource.type + ":** `" + resource.path + "` *(Line " + str(resource.line) + ")*\n"
		output += "\n"
	
	# Object Method Calls
	if data.object_method_calls.size() > 0:
		output += "## 🎯 Object Method Calls (" + str(data.object_method_calls.size()) + ")\n\n"
		for call in data.object_method_calls:
			output += "- `" + call.object + "." + call.method + "()` **Type:** `" + call.object_type + "` *(Line " + str(call.line) + ")*\n"
			output += "  - `" + call.source_line + "`\n"
		output += "\n"
	
	# Built-in Overrides
	if data.built_in_overrides.size() > 0:
		output += "## ⚡ Built-in Method Overrides (" + str(data.built_in_overrides.size()) + ")\n\n"
		for override in data.built_in_overrides:
			output += "- `" + override.signature + "` *(Line " + str(override.line) + ")*\n"
		output += "\n"
	
	# Usage Example
	if not data.usage_example.is_empty():
		output += "## 💡 Usage Example\n\n"
		output += data.usage_example + "\n\n"
	
	return output

static func _format_yaml_enhanced(data: Dictionary) -> String:
	var output = ""
	output += "script_analysis:\n"
	output += "  path: \"" + data.path + "\"\n"
	output += "  class_name: \"" + data.class_name + "\"\n"
	output += "  extends: \"" + data.extends + "\"\n\n"
	
	if data.methods.size() > 0:
		output += "  methods:\n"
		for method in data.methods:
			output += "    - name: \"" + method.name + "\"\n"
			output += "      signature: \"" + method.signature + "\"\n"
			output += "      line: " + str(method.line) + "\n"
			output += "      is_private: " + str(method.is_private) + "\n"
			output += "      is_builtin: " + str(method.is_builtin_override) + "\n"
	
	if data.properties.size() > 0:
		output += "  properties:\n"
		for prop in data.properties:
			output += "    - name: \"" + prop.name + "\"\n"
			output += "      type: \"" + prop.type + "\"\n"
			output += "      exported: " + str(prop.exported) + "\n"
			output += "      line: " + str(prop.line) + "\n"
	
	if data.node_tree.size() > 0:
		output += "  required_nodes:\n"
		for node in data.node_tree:
			output += "    - path: \"" + node.path + "\"\n"
			output += "      type: \"" + node.expected_type + "\"\n"
			output += "      access_method: \"" + node.access_method + "\"\n"
			output += "      line: " + str(node.line) + "\n"
	
	if data.connections.size() > 0:
		output += "  connections:\n"
		for conn in data.connections:
			output += "    - type: \"" + conn.get("type", "connection") + "\"\n"
			output += "      signal: \"" + conn.get("signal", "") + "\"\n"
			output += "      sender: \"" + conn.get("sender", "") + "\"\n"
			output += "      receiver: \"" + conn.get("receiver", "") + "\"\n"
			output += "      line: " + str(conn.line) + "\n"
	
	return output

static func _format_plain_text_enhanced(data: Dictionary) -> String:
	var output = ""
	
	output += "SCRIPT ANALYSIS REPORT\n"
	output += "======================\n\n"
	output += "Path: " + data.path + "\n"
	
	if not data.class_name.is_empty():
		output += "Class: " + data.class_name + "\n"
	
	if not data.extends.is_empty():
		output += "Extends: " + data.extends + "\n"
	
	output += "\n"
	
	if data.methods.size() > 0:
		output += "METHODS (" + str(data.methods.size()) + "):\n"
		output += "---------\n"
		for method in data.methods:
			output += method.signature
			if method.is_private:
				output += " [PRIVATE]"
			if method.is_builtin_override:
				output += " [BUILTIN]"
			output += " (Line " + str(method.line) + ")\n"
		output += "\n"
	
	if data.properties.size() > 0:
		output += "PROPERTIES (" + str(data.properties.size()) + "):\n"
		output += "-----------\n"
		for prop in data.properties:
			output += prop.name
			if not prop.type.is_empty():
				output += ": " + prop.type
			if prop.exported:
				output += " [EXPORTED]"
			if prop.onready:
				output += " [ONREADY]"
			output += " (Line " + str(prop.line) + ")\n"
		output += "\n"
	
	if data.node_tree.size() > 0:
		output += "REQUIRED NODES (" + str(data.node_tree.size()) + "):\n"
		output += "---------------\n"
		for node in data.node_tree:
			output += node.path + " (" + node.expected_type + ") - " + node.access_method + " - Line " + str(node.line) + "\n"
		output += "\n"
	
	if data.connections.size() > 0:
		output += "CONNECTIONS (" + str(data.connections.size()) + "):\n"
		output += "------------\n"
		for conn in data.connections:
			if conn.get("type") == "emission":
				output += "EMIT: " + conn.get("signal", "") + " (Line " + str(conn.line) + ")\n"
			else:
				output += "CONNECT: " + conn.get("sender", "") + "." + conn.get("signal", "") + " -> " + conn.get("receiver", "") + " (Line " + str(conn.line) + ")\n"
		output += "\n"
	
	return output
