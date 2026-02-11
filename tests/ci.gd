extends SceneTree

var _src: PackedStringArray = FileAccess.get_file_as_string("res://tests/ci.gd").split("\n")
var fails: int = 0

func v(ver_str: String) -> Version:
    return Version.new(ver_str)

func attest(condition: bool) -> void:
    var line: int = get_stack()[-1]["line"]

    if not condition:
        fails += 1

    print_rich(
        (
            "[color=red]FAIL[/color]" if not condition else "[color=green]PASS[/color]"
        ) + " @ ", line, ": ", _src[line - 1]
            .strip_edges()
            .trim_prefix("attest(")
            .trim_suffix(")")
            .strip_edges()
    )

func _init() -> void:
    print("Testing: parser...")
    attest( v("23.0.0").major == 23 )
    attest( v("1.0.0").minor == 0 )
    attest( v("1.1.2+meta-valid").buildmetadata == "meta-valid" )

    print("Testing: precedence...")
    attest( v("1.0.0").is_greater_than(v("1.0.1")) == false )
    attest( v("1.0.0").is_greater_than(v("1.0.0-alpha")) == true )
    attest( v("1.0.0-alpha").is_lesser_than(v("1.0.1")) == true )
    attest( v("0.69.420").is_equal_to(v("0.69.420")) == true )
    attest( v("1.5.2").is_equal_to(v("2.5.1")) == false )
    attest( v("2.1.1").is_greater_than(v("2.0.5")) == true )

    print("Testing: utility...")
    attest( v("1.0.0").to_dict()["minor"] == 0 )
    attest( str(v("1.0.0-alpha+123456")) == "1.0.0-alpha+123456" )

    print("\nFailed tests: ", fails)

    quit(fails)
