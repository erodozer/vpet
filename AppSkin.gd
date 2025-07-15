"""
AppSkin

@author Erodozer <ero@erodozer.moe>
@description |>
	Utility for easily applying "skins" to a Godot application.
	This is a stopgap solution until Godot supports things like multiple filesystem
	location Resource Loading with fallback.  It is also to help ease "mod" like
	development that focuses on exact filepath replacement, which can be a bit 
	unweildy to do within Godot's editor.
	
	The largest downside to this library is the fact that Godot's resource loader
	will uncache a resource when there are no more references.  For games that
	are normally aggressive about memory management, this can cause the skin to
	be unloaded and the application will revert to its original files.
	
	To resolve this, this library holds the references of all resources loaded
	in memory.  If you have a lot of resources being skinned and the resources
	are quite large, particularly assets, this can bloat the memory usage
	a bit.  If you do not wish to keep things in memory, you can disable the 
	forced theme caching and just remember to reload the assets regularly.
"""
extends Node

const gdsh = preload("res://addons/godash/godash.gd")
	
func loaded():
	if _loading:
		await theme_applied

@export var hold_cache = true
const overrides = [".png", ".tscn", ".tres", ".json", ".res"]
var _theme_files = []

signal theme_applied
var _loading = true
var _theme = ""

func _ready():
	apply()

## overlays active theme contents onto the game's resources
func apply(theme = ProjectSettings.get_setting_with_override("application/vpet/theme")):
	_loading = true
	
	print("Detecting theme: ", theme)
	
	var theme_filelist = "res://theme/%s.files.txt" % theme
	
	# exported projects can't iterate over folder paths in the res directory
	# so when debugging, we'll be generating a txt file for the theme that keeps a list of all
	# overridden resources.
	if OS.has_feature("editor"):
		var paths = gdsh.enumerate_dir("res://theme/%s" % theme, overrides, true)
		var f = FileAccess.open(theme_filelist, FileAccess.WRITE)
		f.store_string("\n".join(paths))
		f.close()
	
	var filelist = FileAccess.get_file_as_string(theme_filelist).split("\n", false)
	for path in filelist:
		var res = ResourceLoader.load(path)
		print("found: " + res.resource_path)
		var source_path = "res://%s" % res.resource_path.substr(len("res://theme/%s/" % theme))
		if ResourceLoader.exists(source_path):
			res.take_over_path(source_path)
			if hold_cache:
				_theme_files.append(res)
			print("replacing %s" % source_path)
			
	_loading = false
	_theme = theme
	theme_applied.emit()
	
func _exit_tree():
	_theme_files = []
	
func enumerate_dir(path: String, ext = "tres") -> Array:
	return gdsh.enumerate_dir("res://theme/%s/%s" % [_theme, path.substr(len("res://"))], [ext])
