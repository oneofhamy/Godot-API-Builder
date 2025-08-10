# =============================================================================
# ENHANCED BATCH PROCESSOR - COMPREHENSIVE DIRECTORY ANALYSIS
# =============================================================================

@tool
class_name BatchProcessor

const VERSION := "1.1.0.22"
const MANIFEST := {
	"script_name": "batch_processor.gd",
	"script_path": "res://addons/api_builder/main/batch_processor.gd",
	"class_name": "BatchProcessor",
	"version": "1.1.0",
	"description": "Enhanced batch processor for comprehensive directory analysis with architectural insights, pattern detection, and quality metrics across multiple scripts.",
	"required_dependencies": [
		"ScriptAnalyzer",
		"OutputFormatters",
		"FileUtils"
	],
	"optional_dependencies": [],
	"features": [
		"batch_script_analysis",
		"comprehensive_directory_analysis",
		"architecture_pattern_detection",
		"cross_reference_mapping",
		"quality_metrics_aggregation",
		"issue_identification",
		"multiple_output_formats",
		"directory_structure_analysis",
		"naming_convention_analysis",
		"file_size_distribution"
	],
	"analysis_types": {
		"batch_analysis": "Analyze multiple scripts with summary statistics",
		"directory_comprehensive": "Full directory analysis with architectural insights",
		"pattern_detection": "Identify common design patterns across codebase",
		"quality_analysis": "Aggregate quality metrics and identify issues"
	},
	"detected_patterns": [
		"singleton", "observer", "state_machine", "factory", 
		"component", "mvc_model", "mvc_view", "mvc_controller"
	],
	"output_formats": ["MARKDOWN", "JSON", "YAML", "PLAIN_TEXT"],
	"entry_points": [
		"analyze_multiple_scripts", 
		"analyze_directory_comprehensive",
		"format_batch_output"
	],
	"api_version": "api-builder-v1.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# CORE BATCH ANALYSIS FUNCTIONS
# =============================================================================

static func analyze_multiple_scripts(script_paths: Array[String], options: Dictionary) -> Dictionary:
	var batch_results = {
		"scripts": [],
		"summary": {
			"total_scripts": script_paths.size(),
			"successful": 0,
			"failed": 0,
			"total_methods": 0,
			"total_properties": 0,
			"total_dependencies": 0,
			"total_signals": 0,
			"total_constants": 0,
			"analysis_timestamp": Time.get_datetime_string_from_system()
		},
		"insights": {
			"most_complex_script": "",
			"most_dependencies": "",
			"largest_script": "",
			"common_patterns": [],
			"potential_issues": []
		},
		"directory_structure": {},
		"cross_references": {}
	}
	
	var scripts_by_complexity = []
	var scripts_by_dependencies = []
	var all_cross_references = {}
	
	for script_path in script_paths:
		var analysis = ScriptAnalyzer.analyze_script(script_path, options)
		
		if analysis.error.is_empty():
			batch_results.summary.successful += 1
			batch_results.summary.total_methods += analysis.methods.size()
			batch_results.summary.total_properties += analysis.properties.size()
			batch_results.summary.total_dependencies += analysis.cross_script_calls.size()
			batch_results.summary.total_signals += analysis.signals.size()
			batch_results.summary.total_constants += analysis.constants.size()
			
			# Track for insights
			scripts_by_complexity.append({
				"path": script_path,
				"complexity": _calculate_script_complexity(analysis)
			})
			
			scripts_by_dependencies.append({
				"path": script_path,
				"dependencies": analysis.cross_script_calls.size()
			})
			
			# Build cross-reference map
			_build_cross_references(script_path, analysis, all_cross_references)
		else:
			batch_results.summary.failed += 1
		
		batch_results.scripts.append(analysis)
	
	# Generate insights
	_generate_batch_insights(batch_results, scripts_by_complexity, scripts_by_dependencies)
	
	# Build directory structure analysis
	batch_results.directory_structure = _analyze_directory_structure(script_paths)
	
	# Store cross-references
	batch_results.cross_references = all_cross_references
	
	return batch_results

# =============================================================================
# COMPREHENSIVE DIRECTORY ANALYSIS
# =============================================================================

static func analyze_directory_comprehensive(directory_path: String, options: Dictionary, include_subdirs: bool = true, file_filter: String = "*.gd") -> Dictionary:
	"""Comprehensive directory analysis with additional insights"""
	
	# Get all script files
	var script_files = _get_filtered_scripts(directory_path, include_subdirs, file_filter)
	
	# Perform standard batch analysis
	var results = analyze_multiple_scripts(script_files, options)
	
	# Add directory-specific analysis
	results.directory_analysis = {
		"root_path": directory_path,
		"total_files": script_files.size(),
		"subdirectory_count": _count_subdirectories(directory_path, include_subdirs),
		"file_size_distribution": _analyze_file_sizes(script_files),
		"naming_conventions": _analyze_naming_conventions(script_files),
		"architecture_patterns": _detect_architecture_patterns(results.scripts)
	}
	
	return results

# =============================================================================
# UTILITY FUNCTIONS - FILE FILTERING AND PROCESSING
# =============================================================================

static func _get_filtered_scripts(directory_path: String, include_subdirs: bool, file_filter: String) -> Array[String]:
	var files: Array[String] = []
	
	if include_subdirs:
		files = FileUtils.get_all_scripts_in_directory(directory_path)
	else:
		# Only get scripts from current directory
		var dir = DirAccess.open(directory_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				if not dir.current_is_dir():
					# Apply filter
					if file_filter == "*.gd" and file_name.ends_with(".gd"):
						files.append(directory_path + "/" + file_name)
					elif file_filter != "*.gd" and file_name.match(file_filter):
						files.append(directory_path + "/" + file_name)
				file_name = dir.get_next()
			
			dir.list_dir_end()
	
	return files

# =============================================================================
# ANALYSIS HELPERS - COMPLEXITY AND CROSS-REFERENCES
# =============================================================================

static func _calculate_script_complexity(analysis: Dictionary) -> float:
	var complexity = 0.0
	complexity += analysis.methods.size() * 1.0
	complexity += analysis.properties.size() * 0.5
	complexity += analysis.cross_script_calls.size() * 1.5
	complexity += analysis.node_tree.size() * 0.8
	complexity += analysis.connections.size() * 1.2
	return complexity

static func _build_cross_references(script_path: String, analysis: Dictionary, all_refs: Dictionary):
	if not all_refs.has(script_path):
		all_refs[script_path] = {
			"references_to": [],
			"referenced_by": []
		}
	
	# Track what this script references
	for call in analysis.cross_script_calls:
		if call.type in ["preload/load", "instance_creation"]:
			var target = call.target
			all_refs[script_path].references_to.append(target)
			
			# Track reverse reference
			if not all_refs.has(target):
				all_refs[target] = {"references_to": [], "referenced_by": []}
			if script_path not in all_refs[target].referenced_by:
				all_refs[target].referenced_by.append(script_path)

# =============================================================================
# INSIGHT GENERATION AND PATTERN DETECTION
# =============================================================================

static func _generate_batch_insights(batch_results: Dictionary, complexity_data: Array, dependency_data: Array):
	# Sort by complexity
	complexity_data.sort_custom(func(a, b): return a.complexity > b.complexity)
	if complexity_data.size() > 0:
		batch_results.insights.most_complex_script = complexity_data[0].path
	
	# Sort by dependencies
	dependency_data.sort_custom(func(a, b): return a.dependencies > b.dependencies)
	if dependency_data.size() > 0:
		batch_results.insights.most_dependencies = dependency_data[0].path
	
	# Detect common patterns
	batch_results.insights.common_patterns = _detect_common_patterns(batch_results.scripts)
	
	# Identify potential issues
	batch_results.insights.potential_issues = _identify_batch_issues(batch_results.scripts)

static func _detect_common_patterns(scripts: Array) -> Array:
	var patterns = []
	var pattern_counts = {}
	
	for script in scripts:
		if script.error.is_empty():
			# Check for singleton pattern
			if _has_singleton_pattern(script):
				pattern_counts["singleton"] = pattern_counts.get("singleton", 0) + 1
			
			# Check for observer pattern (many signals)
			if script.signals.size() > 2:
				pattern_counts["observer"] = pattern_counts.get("observer", 0) + 1
			
			# Check for state machine pattern
			if _has_state_machine_pattern(script):
				pattern_counts["state_machine"] = pattern_counts.get("state_machine", 0) + 1
			
			# Check for component pattern (@export properties)
			if _has_component_pattern(script):
				pattern_counts["component"] = pattern_counts.get("component", 0) + 1
	
	# Convert to array of pattern info
	for pattern_name in pattern_counts:
		patterns.append({
			"name": pattern_name,
			"count": pattern_counts[pattern_name],
			"percentage": float(pattern_counts[pattern_name]) / float(scripts.size()) * 100.0
		})
	
	return patterns

static func _identify_batch_issues(scripts: Array) -> Array:
	var issues = []
	
	var scripts_without_class_names = 0
	var scripts_with_many_methods = 0
	var scripts_with_high_coupling = 0
	
	for script in scripts:
		if script.error.is_empty():
			if script.class_name.is_empty():
				scripts_without_class_names += 1
			
			if script.methods.size() > 15:
				scripts_with_many_methods += 1
			
			if script.cross_script_calls.size() > 8:
				scripts_with_high_coupling += 1
	
	if scripts_without_class_names > scripts.size() * 0.3:
		issues.append({
			"type": "naming",
			"severity": "medium",
			"message": str(scripts_without_class_names) + " scripts lack class_name declarations"
		})
	
	if scripts_with_many_methods > 0:
		issues.append({
			"type": "complexity",
			"severity": "high",
			"message": str(scripts_with_many_methods) + " scripts have >15 methods (consider refactoring)"
		})
	
	if scripts_with_high_coupling > 0:
		issues.append({
			"type": "coupling",
			"severity": "medium", 
			"message": str(scripts_with_high_coupling) + " scripts have high coupling (>8 dependencies)"
		})
	
	return issues

# =============================================================================
# DIRECTORY STRUCTURE ANALYSIS
# =============================================================================

static func _analyze_directory_structure(script_paths: Array[String]) -> Dictionary:
	var structure = {
		"total_scripts": script_paths.size(),
		"directories": {},
		"max_depth": 0,
		"files_per_directory": {}
	}
	
	for script_path in script_paths:
		var dir_path = script_path.get_base_dir()
		var depth = dir_path.count("/")
		
		structure.max_depth = max(structure.max_depth, depth)
		
		if not structure.directories.has(dir_path):
			structure.directories[dir_path] = []
		
		structure.directories[dir_path].append(script_path.get_file())
		structure.files_per_directory[dir_path] = structure.directories[dir_path].size()
	
	return structure

# =============================================================================
# FILE ANALYSIS UTILITIES
# =============================================================================

static func _count_subdirectories(directory_path: String, include_subdirs: bool) -> int:
	if not include_subdirs:
		return 0
	
	var count = 0
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				count += 1
				count += _count_subdirectories(directory_path + "/" + file_name, true)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return count

static func _analyze_file_sizes(script_files: Array[String]) -> Dictionary:
	var sizes = []
	var total_size = 0
	
	for script_path in script_files:
		var file = FileAccess.open(script_path, FileAccess.READ)
		if file:
			var size = file.get_length()
			sizes.append(size)
			total_size += size
			file.close()
	
	sizes.sort()
	
	return {
		"total_size": total_size,
		"average_size": total_size / max(1, sizes.size()),
		"median_size": sizes[sizes.size() / 2] if sizes.size() > 0 else 0,
		"largest_file": sizes[-1] if sizes.size() > 0 else 0,
		"smallest_file": sizes[0] if sizes.size() > 0 else 0
	}

static func _analyze_naming_conventions(script_files: Array[String]) -> Dictionary:
	var conventions = {
		"snake_case_count": 0,
		"camel_case_count": 0,
		"pascal_case_count": 0,
		"mixed_case_count": 0
	}
	
	for script_path in script_files:
		var filename = script_path.get_file().get_basename()
		
		if filename.match("*[a-z]*_[a-z]*"):
			conventions.snake_case_count += 1
		elif filename.match("*[a-z]*[A-Z]*[a-z]*") and not filename.match("*_*"):
			conventions.camel_case_count += 1
		elif filename.match("[A-Z]*[a-z]*[A-Z]*"):
			conventions.pascal_case_count += 1
		else:
			conventions.mixed_case_count += 1
	
	return conventions

static func _detect_architecture_patterns(scripts: Array) -> Dictionary:
	var patterns = {
		"mvc_components": {"models": 0, "views": 0, "controllers": 0},
		"singletons": 0,
		"factories": 0,
		"observers": 0,
		"components": 0
	}
	
	for script in scripts:
		if script.error.is_empty():
			var script_name = script.path.get_file().get_basename().to_lower()
			
			# MVC pattern detection
			if "model" in script_name or "data" in script_name:
				patterns.mvc_components.models += 1
			elif "view" in script_name or "ui" in script_name or "gui" in script_name:
				patterns.mvc_components.views += 1
			elif "controller" in script_name or "manager" in script_name:
				patterns.mvc_components.controllers += 1
			
			# Other patterns
			if _has_singleton_pattern(script):
				patterns.singletons += 1
			
			if _has_factory_pattern(script):
				patterns.factories += 1
			
			if script.signals.size() > 2:
				patterns.observers += 1
			
			if _has_component_pattern(script):
				patterns.components += 1
	
	return patterns

# =============================================================================
# ARCHITECTURE PATTERN DETECTION HELPERS
# =============================================================================

# Helper pattern detection functions
static func _has_singleton_pattern(script: Dictionary) -> bool:
	for prop in script.properties:
		if "instance" in prop.name.to_lower() and prop.context == "global":
			return true
	for method in script.methods:
		if "get_instance" in method.name.to_lower():
			return true
	return false

static func _has_state_machine_pattern(script: Dictionary) -> bool:
	var has_state_enum = false
	var has_state_variable = false
	
	for constant in script.constants:
		if constant.has("type") and constant.type == "enum" and "state" in constant.name.to_lower():
			has_state_enum = true
			break
	
	for prop in script.properties:
		if "state" in prop.name.to_lower():
			has_state_variable = true
			break
	
	return has_state_enum and has_state_variable

static func _has_factory_pattern(script: Dictionary) -> bool:
	var creation_calls = 0
	for call in script.cross_script_calls:
		if call.type == "instance_creation":
			creation_calls += 1
	return creation_calls > 2

static func _has_component_pattern(script: Dictionary) -> bool:
	var exported_props = 0
	for prop in script.properties:
		if prop.exported:
			exported_props += 1
	return exported_props > 2

# =============================================================================
# OUTPUT FORMATTING SYSTEM
# =============================================================================

static func format_batch_output(batch_data: Dictionary, format: OutputFormatters.Format) -> String:
	var output = ""
	
	match format:
		OutputFormatters.Format.MARKDOWN:
			output = format_batch_markdown(batch_data)
		OutputFormatters.Format.JSON:
			output = JSON.stringify(batch_data, "\t")
		OutputFormatters.Format.YAML:
			output = format_batch_yaml(batch_data)
		OutputFormatters.Format.PLAIN_TEXT:
			output = format_batch_plain_text(batch_data)
		_:
			output = format_batch_markdown(batch_data)
	
	return output

static func format_batch_markdown(batch_data: Dictionary) -> String:
	var output = ""
	
	output += "# 📊 Directory Analysis Report\n\n"
	output += "**Generated:** " + batch_data.summary.analysis_timestamp + "\n\n"
	
	# Summary Section
	output += "## 📈 Summary\n\n"
	output += "- **Total Scripts:** " + str(batch_data.summary.total_scripts) + "\n"
	output += "- **Successful:** " + str(batch_data.summary.successful) + "\n"
	output += "- **Failed:** " + str(batch_data.summary.failed) + "\n"
	output += "- **Total Methods:** " + str(batch_data.summary.total_methods) + "\n"
	output += "- **Total Properties:** " + str(batch_data.summary.total_properties) + "\n"
	output += "- **Total Dependencies:** " + str(batch_data.summary.total_dependencies) + "\n"
	output += "- **Total Signals:** " + str(batch_data.summary.total_signals) + "\n"
	output += "- **Total Constants:** " + str(batch_data.summary.total_constants) + "\n\n"
	
	# Insights Section
	if batch_data.has("insights"):
		output += "## 🔍 Key Insights\n\n"
		
		if not batch_data.insights.most_complex_script.is_empty():
			output += "- **Most Complex Script:** `" + batch_data.insights.most_complex_script.get_file() + "`\n"
		
		if not batch_data.insights.most_dependencies.is_empty():
			output += "- **Highest Dependencies:** `" + batch_data.insights.most_dependencies.get_file() + "`\n"
		
		# Common Patterns
		if batch_data.insights.common_patterns.size() > 0:
			output += "\n### 🎯 Detected Patterns\n\n"
			for pattern in batch_data.insights.common_patterns:
				output += "- **" + pattern.name.capitalize() + ":** " + str(pattern.count) + " scripts (" + str(pattern.percentage).pad_decimals(1) + "%)\n"
		
		# Issues
		if batch_data.insights.potential_issues.size() > 0:
			output += "\n### ⚠️ Potential Issues\n\n"
			for issue in batch_data.insights.potential_issues:
				var severity_icon = "🟡" if issue.severity == "medium" else "🔴"
				output += "- " + severity_icon + " **" + issue.type.capitalize() + ":** " + issue.message + "\n"
		
		output += "\n"
	
	# Directory Analysis
	if batch_data.has("directory_analysis"):
		var dir_analysis = batch_data.directory_analysis
		output += "## 📂 Directory Structure\n\n"
		output += "- **Root Path:** `" + dir_analysis.root_path + "`\n"
		output += "- **Subdirectories:** " + str(dir_analysis.subdirectory_count) + "\n"
		
		if dir_analysis.has("file_size_distribution"):
			var sizes = dir_analysis.file_size_distribution
			output += "- **Average File Size:** " + str(sizes.average_size) + " bytes\n"
			output += "- **Largest File:** " + str(sizes.largest_file) + " bytes\n"
		
		output += "\n"
	
	# Individual Scripts (abbreviated for directory analysis)
	output += "## 📄 Script Details\n\n"
	
	for script_data in batch_data.scripts:
		if not script_data.error.is_empty():
			output += "### ❌ " + script_data.path.get_file() + "\n\n"
			output += "**Error:** " + script_data.error + "\n\n"
		else:
			output += "### ✅ " + script_data.path.get_file() + "\n\n"
			output += "- **Class:** `" + script_data.class_name + "`" if not script_data.class_name.is_empty() else "- **No class name**"
			output += "\n"
			output += "- **Methods:** " + str(script_data.methods.size()) + "\n"
			output += "- **Properties:** " + str(script_data.properties.size()) + "\n"
			output += "- **Dependencies:** " + str(script_data.cross_script_calls.size()) + "\n"
			output += "- **Signals:** " + str(script_data.signals.size()) + "\n\n"
		
		output += "---\n\n"
	
	return output

static func format_batch_yaml(batch_data: Dictionary) -> String:
	var output = ""
	output += "directory_analysis:\n"
	output += "  timestamp: \"" + batch_data.summary.analysis_timestamp + "\"\n"
	output += "  summary:\n"
	output += "    total_scripts: " + str(batch_data.summary.total_scripts) + "\n"
	output += "    successful: " + str(batch_data.summary.successful) + "\n"
	output += "    failed: " + str(batch_data.summary.failed) + "\n"
	output += "    total_methods: " + str(batch_data.summary.total_methods) + "\n"
	output += "    total_properties: " + str(batch_data.summary.total_properties) + "\n"
	output += "    total_dependencies: " + str(batch_data.summary.total_dependencies) + "\n"
	
	if batch_data.has("insights") and batch_data.insights.common_patterns.size() > 0:
		output += "  patterns:\n"
		for pattern in batch_data.insights.common_patterns:
			output += "    - name: \"" + pattern.name + "\"\n"
			output += "      count: " + str(pattern.count) + "\n"
			output += "      percentage: " + str(pattern.percentage) + "\n"
	
	output += "  scripts:\n"
	for script_data in batch_data.scripts:
		if script_data.error.is_empty():
			output += "    - path: \"" + script_data.path + "\"\n"
			output += "      class_name: \"" + script_data.class_name + "\"\n"
			output += "      methods: " + str(script_data.methods.size()) + "\n"
			output += "      properties: " + str(script_data.properties.size()) + "\n"
			output += "      dependencies: " + str(script_data.cross_script_calls.size()) + "\n"
	
	return output

static func format_batch_plain_text(batch_data: Dictionary) -> String:
	var output = ""
	
	output += "DIRECTORY ANALYSIS REPORT\n"
	output += "=========================\n\n"
	output += "Generated: " + batch_data.summary.analysis_timestamp + "\n\n"
	
	output += "SUMMARY:\n"
	output += "--------\n"
	output += "Total Scripts: " + str(batch_data.summary.total_scripts) + "\n"
	output += "Successful: " + str(batch_data.summary.successful) + "\n"
	output += "Failed: " + str(batch_data.summary.failed) + "\n"
	output += "Total Methods: " + str(batch_data.summary.total_methods) + "\n"
	output += "Total Properties: " + str(batch_data.summary.total_properties) + "\n"
	output += "Total Dependencies: " + str(batch_data.summary.total_dependencies) + "\n\n"
	
	if batch_data.has("insights"):
		output += "KEY INSIGHTS:\n"
		output += "-------------\n"
		
		if not batch_data.insights.most_complex_script.is_empty():
			output += "Most Complex: " + batch_data.insights.most_complex_script.get_file() + "\n"
		
		if not batch_data.insights.most_dependencies.is_empty():
			output += "Most Dependencies: " + batch_data.insights.most_dependencies.get_file() + "\n"
		
		if batch_data.insights.common_patterns.size() > 0:
			output += "\nCOMMON PATTERNS:\n"
			for pattern in batch_data.insights.common_patterns:
				output += "- " + pattern.name.capitalize() + ": " + str(pattern.count) + " scripts\n"
		
		if batch_data.insights.potential_issues.size() > 0:
			output += "\nPOTENTIAL ISSUES:\n"
			for issue in batch_data.insights.potential_issues:
				output += "- [" + issue.severity.to_upper() + "] " + issue.message + "\n"
		
		output += "\n"
	
	output += "SCRIPT DETAILS:\n"
	output += "---------------\n"
	
	for script_data in batch_data.scripts:
		if script_data.error.is_empty():
			output += script_data.path.get_file() + ":\n"
			output += "  Class: " + (script_data.class_name if not script_data.class_name.is_empty() else "(none)") + "\n"
			output += "  Methods: " + str(script_data.methods.size()) + "\n"
			output += "  Properties: " + str(script_data.properties.size()) + "\n"
			output += "  Dependencies: " + str(script_data.cross_script_calls.size()) + "\n"
			output += "  Signals: " + str(script_data.signals.size()) + "\n\n"
		else:
			output += script_data.path.get_file() + ": ERROR - " + script_data.error + "\n\n"
	
	return output
