# Enhanced Script Analyzer for Godot

[![Godot Version](https://img.shields.io/badge/Godot-4.0+-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.1.0-orange.svg)](CHANGELOG.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Analyze single files or entire directories with architectural pattern detection, dependency mapping, and quality metrics.

## Features

### **Dual Analysis Modes**
- **Single File Analysis**: Deep dive into individual scripts
- **Directory Batch Analysis**: Comprehensive project-wide insights

### **Architectural Intelligence**
- **Pattern Detection**: Automatic identification of Singleton, Observer, MVC, Factory, and Component patterns
- **Dependency Mapping**: Visual representation of script relationships
- **Quality Metrics**: Complexity scoring, maintainability assessment, and readability evaluation
- **Issue Identification**: Automated detection of potential code problems

### **Advanced Analysis Capabilities**
- **Cross-Script Relationships**: Track dependencies and interactions
- **Node Tree Analysis**: Map required scene structures
- **Signal Connection Mapping**: Understand event flow
- **Resource Usage Tracking**: Monitor external dependencies
- **Built-in Override Detection**: Identify Godot lifecycle methods

### **Rich Output Formats**
- **Markdown**: Beautiful, readable reports with emojis and formatting
- **JSON**: Machine-readable data for further processing
- **YAML**: Structured, human-friendly format
- **Plain Text**: Universal compatibility

### **Developer Experience**
- **Real-time Progress Tracking**: Visual feedback during analysis
- **Advanced Filtering**: Wildcards, exclusions, and custom patterns
- **Preset Configurations**: Optimized settings for different use cases
- **Export & Copy**: Easy sharing and documentation
- **Responsive UI**: Collapsible panel with adaptive layout

## Installation

### Method 1: AssetLib (NOT YET LISTED)
1. Open Godot Editor
2. Go to **AssetLib** tab
3. Search for "Enhanced Script Analyzer"
4. Click **Download** and **Install**
5. Enable the plugin in **Project Settings > Plugins**

### Method 2: Manual Installation
1. Download the latest release from [Releases](https://github.com/oneofhamy/Godot-API-Builder)
2. Extract to your project's `addons/` folder
3. Enable the plugin in **Project Settings > Plugins**

### Method 3: Git Clone
```bash
cd your-godot-project/addons/
git clone https://github.com/oneofhamy/Godot-API-Builder
```

## Quick Start

### 1. **Access the Analyzer**
After installation, find the **Script Analyzer** panel in the right dock of the Godot Editor.

### 2. **Single File Analysis**
```gdscript
# Select "Single File" mode
# Click "Browse" to select a script
# Choose analysis options
# Click "Analyze" for instant results
```

### 3. **Directory Analysis**
```gdscript
# Select "Directory" mode  
# Browse to your scripts folder
# Configure filters (e.g., "*.gd", "*player*")
# Enable/disable subdirectory scanning
# Analyze for comprehensive insights
```

### 4. **Export Results**
- **Copy**: Clipboard for easy sharing
- **Export**: Save as Markdown, JSON, YAML, or Plain Text

## Usage Examples

### Basic Single File Analysis
```gdscript
# Using the programmatic API
var options = AnalyzerPresets.get_preset_options(AnalyzerPresets.PresetType.AI_INTEGRATION)
var result = ScriptAnalyzer.analyze_script("res://player.gd", options)
print("Methods found: ", result.methods.size())
```

### Directory Analysis with Filtering
```gdscript
# Analyze all UI scripts
var ui_scripts = FileUtils.get_scripts_in_directory_filtered(
    "res://ui/",
    true,                           # include subdirectories
    "*ui*.gd",                      # filter pattern
    ["*/test/*", "*/deprecated/*"]  # exclude patterns
)

var analysis = BatchProcessor.analyze_multiple_scripts(ui_scripts, options)
print("Found ", analysis.summary.total_scripts, " UI scripts")
```

### Custom Quality Analysis
```gdscript
# Generate quality report
var quality = ScriptAnalyzer.analyze_code_quality("res://complex_script.gd")
print("Complexity Score: ", quality.complexity_score)
print("Maintainability: ", quality.maintainability_score)
print("Issues Found: ", quality.issues.size())
```

## Analysis Presets

### **Dependency Complete** 
Focus on cross-script relationships and architectural dependencies.

### **Human Integration**
Balanced analysis perfect for code reviews and team collaboration.

### **Docstring Only**
Extract documentation and comments for API reference.

### **Minimal Summary**
Quick overview with essential information only.

### **Custom**
Define your own analysis parameters for specific needs.

## Architecture Patterns Detected

| Pattern | Description | Detection Criteria |
|---------|-------------|--------------------|
| **Singleton** | Single instance classes | Static instance variables + getInstance methods |
| **Observer** | Event-driven communication | Multiple signal definitions and emissions |
| **State Machine** | State-based behavior | State enums + state variables |
| **Factory** | Object creation abstraction | Multiple instance creation calls |
| **Component** | Modular, configurable components | Heavy use of @export properties |
| **MVC** | Model-View-Controller separation | Naming patterns + structural analysis |

## Sample Analysis Output

### Directory Analysis Report
```markdown
# Directory Analysis Report

**Generated:** 2025-08-09 15:30:45

## Summary
- **Total Scripts:** 47
- **Successful:** 45
- **Failed:** 2
- **Total Methods:** 312
- **Total Properties:** 89
- **Total Dependencies:** 156

## Key Insights
- **Most Complex Script:** `player_controller.gd`
- **Highest Dependencies:** `game_manager.gd`

### 🎯 Detected Patterns
- **Singleton:** 3 scripts (6.4%)
- **Observer:** 12 scripts (25.5%)
- **Component:** 8 scripts (17.0%)

### ⚠️ Potential Issues
- 🔴 **Complexity:** 2 scripts have >15 methods (consider refactoring)
- 🟡 **Naming:** 7 scripts lack class_name declarations
```

## Configuration

### Analysis Options
```gdscript
{
    "class_name": true,           # Extract class names
    "inheritance": true,          # Track inheritance chains
    "methods": true,              # Analyze all methods
    "properties": true,           # Extract variables and properties
    "constants": true,            # Find constants and enums
    "signals": true,              # Map signal definitions
    "cross_script_calls": true,   # Track dependencies
    "node_tree": true,            # Required scene structure
    "connections": true,          # Signal connections
    "external_resources": true,   # Resource dependencies
    "object_method_calls": true,  # Method call analysis
    "builtin_overrides": true,    # Godot lifecycle methods
    "usage_example": true         # Generate usage examples
}
```

### Filter Options
```gdscript
{
    "method_filter": {
        "exclude_private": false,
        "exclude_builtin_overrides": false
    },
    "property_filter": {
        "only_exported": false
    },
    "context_filter": "all"  # or specific context
}
```

## UI Features

### **Collapsible Panel Design**
- Minimize when not in use
- Responsive layout adaptation
- Smooth animations

### **Real-time Progress**
- Progress bar for directory analysis
- Status updates during processing
- Cancellable operations

### **Advanced Filtering**
- Wildcard pattern support (`*.gd`, `*player*`)
- Exclude patterns for unwanted files
- Recursive directory options

### **Export Functionality**
- Multiple format support
- Custom filename generation
- Clipboard integration

## Use Cases

### **Project Documentation**
Generate comprehensive API documentation and architectural overviews for new team members.

### **Code Reviews**
Batch analyze changed files to identify potential issues and architectural concerns.

### **Refactoring Planning**
Find overly complex scripts, identify high-coupling areas, and plan architectural improvements.

### **Quality Assurance**
Monitor code complexity trends, ensure naming convention compliance, and track pattern usage.

### **Team Onboarding**
Help new developers understand project structure and architectural patterns.

## Advanced Features

### **Cross-Reference Analysis**
```gdscript
# Track which scripts reference each other
var refs = analysis.cross_references
for script_path in refs:
    print(script_path, " references: ", refs[script_path].references_to)
    print(script_path, " referenced by: ", refs[script_path].referenced_by)
```

### **Quality Metrics**
```gdscript
# Complexity scoring algorithm
complexity = methods.size() * 1.0 + 
             properties.size() * 0.5 + 
             dependencies.size() * 1.5 +
             node_references.size() * 0.8 +
             connections.size() * 1.2
```

### **Directory Structure Analysis**
- File size distribution
- Naming convention compliance
- Depth analysis
- Subdirectory organization

## API Reference

### Core Classes

#### `ScriptAnalyzer`
Main analysis engine with parsing and reflection capabilities.

```gdscript
static func analyze_script(script_path: String, options: Dictionary) -> Dictionary
static func generate_usage_example(result: Dictionary) -> String
static func analyze_code_quality(script_path: String) -> Dictionary
```

#### `BatchProcessor`
Directory analysis and batch processing with insights.

```gdscript
static func analyze_multiple_scripts(script_paths: Array[String], options: Dictionary) -> Dictionary
static func analyze_directory_comprehensive(directory_path: String, options: Dictionary) -> Dictionary
static func format_batch_output(batch_data: Dictionary, format: OutputFormatters.Format) -> String
```

#### `FileUtils`
Advanced file operations and directory scanning.

```gdscript
static func get_scripts_in_directory_filtered(dir_path: String, include_subdirs: bool, file_filter: String, exclude_patterns: Array[String]) -> Array[String]
static func get_project_structure() -> Dictionary
static func validate_script_path(path: String) -> Dictionary
```

#### `OutputFormatters`
Multi-format output generation and presentation.

```gdscript
static func format_output(data: Dictionary, format: Format) -> String
enum Format { MARKDOWN, JSON, YAML, PLAIN_TEXT }
```

## Testing

### Running Tests
```bash
# Unit tests
godot --headless --script test_analyzer.gd

# Integration tests  
godot --headless --script test_batch_processing.gd

# UI tests
godot --headless --script test_ui_panel.gd
```

### Test Coverage
- Core analysis functions
- Pattern detection algorithms
- File filtering and scanning
- Output formatting
- UI interactions
- Error handling

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style
- Follow GDScript style guide
- Add section headers for minimap navigation
- Include comprehensive documentation
- Write meaningful commit messages

## Changelog

### v1.1.0 (Current)
- **NEW**: Comprehensive directory analysis
- **NEW**: Architectural pattern detection
- **NEW**: Real-time progress tracking
- **NEW**: Advanced filtering system
- **IMPROVED**: Enhanced UI with mode switching
- **IMPROVED**: Quality metrics and issue detection
- **IMPROVED**: Cross-reference mapping
- **FIXED**: Memory optimization for large projects

### v1.0.0
- Initial release with single file analysis
- Basic output formatting
- Godot Editor integration

See [CHANGELOG.md](CHANGELOG.md) for complete history.

## Troubleshooting

### Common Issues

#### **Empty Analysis Results**
- Check file paths and permissions
- Verify file filter patterns
- Ensure target directory contains .gd files

#### **Performance Issues**
- Use exclude patterns for large projects
- Analyze subdirectories separately
- Close other applications during analysis

#### **UI Not Responding**
- Check console for error messages
- Restart Godot if panel is not visible
- Verify plugin is enabled in settings

### Getting Help
- 📖 Check the [Wiki](https://github.com/yourusername/enhanced-script-analyzer/wiki)
- 🐛 Report bugs in [Issues](https://github.com/yourusername/enhanced-script-analyzer/issues)
- 💬 Join discussions in [Discussions](https://github.com/yourusername/enhanced-script-analyzer/discussions)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Godot Engine** community for inspiration and support
- **Contributors** who helped improve this tool
- **Beta testers** who provided valuable feedback
- **Open source projects** that influenced this design

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/enhanced-script-analyzer&type=Date)](https://star-history.com/#yourusername/enhanced-script-analyzer&Date)

---

<div align="center">

**Made with ❤️ for the Godot community**

[⬆ Back to Top](#-enhanced-script-analyzer-for-godot)

</div>
