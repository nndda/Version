# Version

Tiny Semantic Version parser and utility for Godot 4.

## Installation

Copy the content of `addons/` to your project directory.

## Usage

```gdscript
var ver_current = Version.new("1.2.0")
var ver_latest = Version.new("1.3.2")

var update_needed = ver_current.is_lesser_than(ver_latest) # true

print("You are on: ", str(ver_current))
# You are on: 1.2.0
```
```gdscript
var version = Version.new("3.9.52-alpha.6+abc123")

print(version.major) # 3
print(version.minor) # 9
print(version.patch) # 52
print(version.prerelease) # ['alpha', '6']
print(version.buildmetadata) # 'abc123'
```

More information available through the built-in documentation. Press <kbd>f1</kbd>, and look for `Version` class.

## License

Licensed under MIT license (see [LICENSE](LICENSE)).

Copyright &copy; 2026 nnda
