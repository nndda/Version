# SPDX-License-Identifier: MIT
# MIT License
#
# Copyright (c) 2026 nnda
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends RefCounted
class_name Version

## Tiny utility class to parse and process versioning.
##
## [Version] follows the specification of
## [url=https://semver.org/spec/v2.0.0.html]SemVer 2.0.0[/url].
## Use [code]Version.new()[/code], and pass the version string to create a new [Version] object.
##
## [codeblock]
## var ver_current = Version.new("1.2.0")
## var ver_latest = Version.new("1.3.2")
##
## var update_needed = ver_current.is_lesser_than(ver_latest)
## [/codeblock]
## [br]
## [Version] object also can be represented as string with [method @GlobalScope.str].
## [codeblock]
## var ver_current = Version.new("1.3.0-alpha.5")
##
## print("You are using version: ", str(ver_current))
## # You are using version: 1.3.0-alpha.5
## [/codeblock]
##
## @tutorial(Semantic Versioning 2.0.0 specification): https://semver.org/spec/v2.0.0.html

## The major number of the version.
var major: int
## The minor number of the version.
var minor: int
## The patch number of the version.
var patch: int

## [PackedStringArray] of the pre-release data, separated by dots.
var prerelease: PackedStringArray = []
## The version's build metadata.
var buildmetadata: String = ""

# RegEx suggested by SemVer https://regex101.com/r/Ly7O1x/3/
static var _ver_re: RegEx = RegEx.create_from_string(
    r"^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)(?:-(?P<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"
)

func _init(version_str: String) -> void:
    var re_match: RegExMatch = _ver_re.search(
        version_str.strip_edges()
    )

    if re_match == null:
        assert(false, "Version: error parsing the version string: '%s'" % version_str)
    else:
        major = re_match.get_string("major").to_int()
        minor = re_match.get_string("minor").to_int()
        patch = re_match.get_string("patch").to_int()

        prerelease = re_match.get_string("prerelease").split(".", false)
        buildmetadata = re_match.get_string("buildmetadata")

func _to_string() -> String:
    return "%d.%d.%d" % [major, minor, patch] \
        + ("" if prerelease.is_empty() else "-" + ".".join(prerelease)) \
        + ("" if buildmetadata.is_empty() else "+" + buildmetadata)

## Compare the precedence with the [param ver].
## [br]
## • returns 1 if [param ver] takes lower precedence.
## [br]
## • returns -1 if [param ver] takes higher precedence.
## [br]
## • returns 0 if [param ver] have the same precedence.
func compare(ver: Version) -> int:
    if major != ver.major: return signi(major - ver.major)
    if minor != ver.minor: return signi(minor - ver.minor)
    if patch != ver.patch: return signi(patch - ver.patch)

    return _compare_prerelease(ver)

## Static method to compare two version strings using [method compare].
static func compare_versions(ver_a: String, ver_b: String) -> int:
    return Version.new(ver_a).compare(Version.new(ver_b))

func _compare_prerelease(ver: Version) -> int:
    var prerel_empty_self := prerelease.is_empty()
    var prerel_empty_other := ver.prerelease.is_empty()

    if prerel_empty_self and prerel_empty_other: return 0
    if prerel_empty_self: return 1
    if prerel_empty_other: return -1

    var prerel_self := prerelease
    var prerel_other := ver.prerelease

    var prerel_size_self := prerel_self.size()
    var prerel_size_other := prerel_other.size()

    for n: int in maxi(prerel_size_self, prerel_size_other):
        if n >= prerel_size_self: return -1
        if n >= prerel_size_other: return 1

        var a := prerel_self[n]
        var b := prerel_other[n]

        var a_is_num := a.is_valid_int()
        var b_is_num := b.is_valid_int()

        if a_is_num and b_is_num:
            var diff: int = a.to_int() - b.to_int()
            if diff != 0: return signi(diff)

        if a_is_num and not b_is_num:
            return -1

        if not a_is_num and b_is_num:
            return 1

        if a != b:
            return -1 if a < b else 1

    return 0

## Returns true, if [param ver] have the same precedence.
## This is [i]equal to[/i] (pun intended): [br]
## [gdscript]compare(ver) == 0[/gdscript]
func is_equal_to(ver: Version) -> bool:
    return compare(ver) == 0

## Returns true, if [param ver] have lower precedence.
## This is equal to: [br]
## [gdscript]compare(ver) > 0[/gdscript]
func is_greater_than(ver: Version) -> bool:
    return compare(ver) > 0

## Returns true, if [param ver] have higher precedence.
## This is equal to: [br]
## [gdscript]compare(ver) < 0[/gdscript]
func is_lesser_than(ver: Version) -> bool:
    return compare(ver) < 0

## Converts the [Version] to dictionary format, with the following data:
## [codeblock]
## {
##      "major": major,
##      "minor": minor,
##      "patch": patch,
##      "prerelease": prerelease,
##      "buildmetadata": buildmetadata,
## }
## [/codeblock]
func to_dict() -> Dictionary:
    return {
        "major": major,
        "minor": minor,
        "patch": patch,

        "prerelease": prerelease,
        "buildmetadata": buildmetadata,
    }
