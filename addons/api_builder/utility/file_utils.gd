# =============================================================================
# ENHANCED FILE UTILS - ADVANCED DIRECTORY OPERATIONS
# =============================================================================

@tool
class_name FileUtils

const VERSION := "1.1.0.18"
const MANIFEST := {
	"script_name": "file_utils.gd",
	"script_path": "res://addons/api_builder/utility/file_utils.gd",
	"class_name": "FileUtils",
	"version": "1.1.0",
	"description": "Enhanced file utilities with advanced directory scanning, filtering, validation, and project structure analysis capabilities.",
	"required_dependencies": [],
	"optional_dependencies": [],
	"features": [
		"recursive_directory_scanning",
		"advanced_wildcard_filtering",
		"exclude_pattern_support",
		"directory_validation",
		"file_size_analysis",
		"project_structure_mapping",
		"naming_convention_detection",
		"comprehensive_directory_reports",
		"path_normalization",
		"file_type_categorization"
	],
	"filter_types": {
		"wildcard_patterns": "Support for *.gd, *player*.gd, etc.",
		"exclude_patterns": "Skip directories/files matching patterns",
		"extension_filtering": "Filter by file extensions",
		"size_filtering": "Filter by file size ranges"
	},
	"analysis_capabilities": [
		"directory_structure_analysis",
		"file_size_distribution",
		"naming_convention_detection",
		"project_depth_analysis",
		"subdirectory_counting",
		"file_type_categorization"
	],
	"validation_types": ["script_path", "directory_path", "project_structure"],
	"entry_points": [
		"get_all_scripts_in_directory",
		"get_scripts_in_directory_filtered", 
		"get_directory_info",
		"get_project_structure",
		"validate_script_path",
		"validate_directory_path"
	],
	"api_version": "api-builder-v1.1.0",
	"last_updated": "2025-08-09"
}

# =============================================================================
# CORE DIRECTORY SCANNING FUNCTIONS
# =============================================================================

static func get_all_scripts_in_directory(dir_path: String, file_extension: String = ".gd") -> Array[String]:
	"""Get all script files recursively from a directory"""
	var scripts: Array[String] = []
	var dir = DirAccess.open(dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = dir_path + "/" + file_name
			
			if dir.current_is_dir() and not file_name.begins_with("."):
				# Recursively search subdirectories
				scripts.append_array(get_all_scripts_in_directory(full_path, file_extension))
			elif file_name.ends_with(file_extension):
				scripts.append(full_path)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return scripts

# =============================================================================
# ADVANCED FILTERING AND PATTERN MATCHING
# =============================================================================

static func get_scripts_in_directory_filtered(dir_path: String, include_subdirs: bool = true, file_filter: String = "*.gd", exclude_patterns: Array[String] = []) -> Array[String]:
	"""Get script files with advanced filtering options"""
	var scripts: Array[String] = []
	var dir = DirAccess.open(dir_path)
	
	if not dir:
		push_error("Cannot open directory: " + dir_path)
		return scripts
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path + "/" + file_name
		
		# Skip hidden files and directories
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		
		# Skip excluded patterns
		var should_exclude = false
		for pattern in exclude_patterns:
			if file_name.match(pattern) or full_path.match(pattern):
				should_exclude = true
				break
		
		if should_exclude:
			file_name = dir.get_next()
			continue
		
		if dir.current_is_dir() and include_subdirs:
			# Recursively search subdirectories
			scripts.append_array(get_scripts_in_directory_filtered(full_path, include_subdirs, file_filter, exclude_patterns))
		elif not dir.current_is_dir():
			# Check if file matches filter
			if _matches_filter(file_name, file_filter):
				scripts.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return scripts

static func _matches_filter(filename: String, filter: String) -> bool:
	"""Check if filename matches the given filter pattern"""
	if filter == "*" or filter.is_empty():
		return true
	
	# Handle simple wildcard patterns
	if filter.begins_with("*."):
		var extension = filter.substr(2)
		return filename.ends_with("." + extension)
	elif filter.ends_with("*"):
		var prefix = filter.substr(0, filter.length() - 1)
		return filename.begins_with(prefix)
	elif "*" in filter:
		# More complex wildcard - use regex
		var regex_pattern = filter.replace("*", ".*").replace("?", ".")
		var regex = RegEx.new()
		regex.compile("^" + regex_pattern + "$")
		return regex.search(filename) != null
	else:
		# Exact match
		return filename == filter

# =============================================================================
# DIRECTORY INFORMATION AND ANALYSIS
# =============================================================================

static func get_directory_info(dir_path: String) -> Dictionary:
	"""Get comprehensive information about a directory"""
	var info = {
		"path": dir_path,
		"exists": DirAccess.dir_exists_absolute(dir_path),
		"total_files": 0,
		"script_files": 0,
		"subdirectories": 0,
		"total_size": 0,
		"file_types": {},
		"largest_file": {"path": "", "size": 0},
		"directory_tree": []
	}
	
	if not info.exists:
		return info
	
	_analyze_directory_recursive(dir_path, info, 0)
	return info

static func _analyze_directory_recursive(dir_path: String, info: Dictionary, depth: int):
	"""Recursively analyze directory contents"""
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		
		var full_path = dir_path + "/" + file_name
		
		if dir.current_is_dir():
			info.subdirectories += 1
			info.directory_tree.append({
				"name": file_name,
				"path": full_path,
				"type": "directory",
				"depth": depth
			})
			_analyze_directory_recursive(full_path, info, depth + 1)
		else:
			info.total_files += 1
			
			# Get file extension
			var extension = file_name.get_extension().to_lower()
			if extension.is_empty():
				extension = "no_extension"
			
			info.file_types[extension] = info.file_types.get(extension, 0) + 1
			
			# Check if it's a script file
			if extension == "gd" or extension == "cs":
				info.script_files += 1
			
			# Get file size
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				var size = file.get_length()
				info.total_size += size
				
				if size > info.largest_file.size:
					info.largest_file.path = full_path
					info.largest_file.size = size
				
				file.close()
			
			info.directory_tree.append({
				"name": file_name,
				"path": full_path,
				"type": "file",
				"extension": extension,
				"depth": depth
			})
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# =============================================================================
# PROJECT STRUCTURE ANALYSIS
# =============================================================================

static func get_project_scripts(exclude_addons: bool = true) -> Array[String]:
	"""Get all scripts in the project with options to exclude certain directories"""
	var exclude_patterns = []
	if exclude_addons:
		exclude_patterns.append("*/addons/*")
		exclude_patterns.append("addons/*")
	
	return get_scripts_in_directory_filtered("res://", true, "*.gd", exclude_patterns)

static func get_project_structure() -> Dictionary:
	"""Get detailed project structure information"""
	var structure = {
		"project_path": "res://",
		"analysis_timestamp": Time.get_datetime_string_from_system(),
		"directories": {},
		"scripts_by_directory": {},
		"total_scripts": 0,
		"depth_distribution": {},
		"naming_analysis": {
			"snake_case": 0,
			"camel_case": 0,
			"pascal_case": 0,
			"mixed": 0
		}
	}
	
	var all_scripts = get_project_scripts()
	structure.total_scripts = all_scripts.size()
	
	# Analyze by directory
	for script_path in all_scripts:
		var dir_path = script_path.get_base_dir()
		var depth = dir_path.count("/")
		
		# Track depth distribution
		structure.depth_distribution[depth] = structure.depth_distribution.get(depth, 0) + 1
		
		# Track scripts by directory
		if not structure.scripts_by_directory.has(dir_path):
			structure.scripts_by_directory[dir_path] = []
		structure.scripts_by_directory[dir_path].append(script_path.get_file())
		
		# Analyze naming convention
		var filename = script_path.get_file().get_basename()
		_analyze_naming_convention(filename, structure.naming_analysis)
	
	return structure

static func _analyze_naming_convention(filename: String, naming_stats: Dictionary):
	"""Analyze and categorize naming convention of a filename"""
	if filename.match("*[a-z]*_[a-z]*"):
		naming_stats.snake_case += 1
	elif filename.match("*[a-z]*[A-Z]*[a-z]*") and not filename.match("*_*"):
		naming_stats.camel_case += 1
	elif filename.match("[A-Z]*[a-z]*[A-Z]*"):
		naming_stats.pascal_case += 1
	else:
		naming_stats.mixed += 1

# =============================================================================
# VALIDATION AND PATH UTILITIES
# =============================================================================

static func validate_script_path(path: String) -> Dictionary:
	"""Validate a script path and return detailed information"""
	var validation = {
		"valid": false,
		"exists": false,
		"is_script": false,
		"is_readable": false,
		"size": 0,
		"error": ""
	}
	
	if path.is_empty():
		validation.error = "Path is empty"
		return validation
	
	validation.exists = FileAccess.file_exists(path)
	if not validation.exists:
		validation.error = "File does not exist"
		return validation
	
	validation.is_script = path.ends_with(".gd") or path.ends_with(".cs")
	if not validation.is_script:
		validation.error = "File is not a script file"
		return validation
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		validation.error = "Cannot read file"
		return validation
	
	validation.is_readable = true
	validation.size = file.get_length()
	file.close()
	
	validation.valid = true
	return validation

static func validate_directory_path(path: String) -> Dictionary:
	"""Validate a directory path and return detailed information"""
	var validation = {
		"valid": false,
		"exists": false,
		"is_readable": false,
		"script_count": 0,
		"subdirectory_count": 0,
		"error": ""
	}
	
	if path.is_empty():
		validation.error = "Path is empty"
		return validation
	
	validation.exists = DirAccess.dir_exists_absolute(path)
	if not validation.exists:
		validation.error = "Directory does not exist"
		return validation
	
	var dir = DirAccess.open(path)
	if not dir:
		validation.error = "Cannot read directory"
		return validation
	
	validation.is_readable = true
	
	# Count contents
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not file_name.begins_with("."):
			if dir.current_is_dir():
				validation.subdirectory_count += 1
			elif file_name.ends_with(".gd") or file_name.ends_with(".cs"):
				validation.script_count += 1
		file_name = dir.get_next()
	
	dir.list_dir_end()
	validation.valid = true
	return validation

static func get_relative_path(full_path: String) -> String:
	"""Convert absolute path to Godot relative path"""
	if full_path.begins_with("res://"):
		return full_path
	
	# Handle different path formats
	var project_path = ProjectSettings.globalize_path("res://")
	if full_path.begins_with(project_path):
		var relative = full_path.substr(project_path.length())
		return "res://" + relative
	
	return "res://" + full_path

# =============================================================================
# DIRECTORY REPORTING AND RECOMMENDATIONS
# =============================================================================

static func create_directory_report(dir_path: String, include_subdirs: bool = true) -> Dictionary:
	"""Create a comprehensive directory analysis report"""
	var report = {
		"directory_path": dir_path,
		"analysis_timestamp": Time.get_datetime_string_from_system(),
		"validation": validate_directory_path(dir_path),
		"scripts": [],
		"structure": {},
		"statistics": {
			"total_scripts": 0,
			"total_size": 0,
			"average_size": 0,
			"largest_script": {"path": "", "size": 0},
			"smallest_script": {"path": "", "size": 999999999}
		},
		"recommendations": []
	}
	
	if not report.validation.valid:
		return report
	
	# Get all scripts
	var scripts = get_scripts_in_directory_filtered(dir_path, include_subdirs, "*.gd")
	report.scripts = scripts
	report.statistics.total_scripts = scripts.size()
	
	# Analyze each script
	for script_path in scripts:
		var file = FileAccess.open(script_path, FileAccess.READ)
		if file:
			var size = file.get_length()
			report.statistics.total_size += size
			
			if size > report.statistics.largest_script.size:
				report.statistics.largest_script.path = script_path
				report.statistics.largest_script.size = size
			
			if size < report.statistics.smallest_script.size:
				report.statistics.smallest_script.path = script_path
				report.statistics.smallest_script.size = size
			
			file.close()
	
	# Calculate averages
	if report.statistics.total_scripts > 0:
		report.statistics.average_size = report.statistics.total_size / report.statistics.total_scripts
	
	# Generate recommendations
	_generate_directory_recommendations(report)
	
	return report

static func _generate_directory_recommendations(report: Dictionary):
	"""Generate recommendations based on directory analysis"""
	var recommendations = []
	
	if report.statistics.total_scripts == 0:
		recommendations.append({
			"type": "warning",
			"message": "No script files found in the directory"
		})
	elif report.statistics.total_scripts > 50:
		recommendations.append({
			"type": "suggestion",
			"message": "Large number of scripts (" + str(report.statistics.total_scripts) + "). Consider organizing into subdirectories."
		})
	
	if report.statistics.largest_script.size > 10000:  # > 10KB
		recommendations.append({
			"type": "suggestion",
			"message": "Large script detected: " + report.statistics.largest_script.path.get_file() + " (" + str(report.statistics.largest_script.size) + " bytes). Consider refactoring."
		})
	
	if report.statistics.average_size > 5000:  # > 5KB average
		recommendations.append({
			"type": "info",
			"message": "High average script size (" + str(report.statistics.average_size) + " bytes). Monitor complexity."
		})
	
	report.recommendations = recommendations
