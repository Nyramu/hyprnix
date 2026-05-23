{ lib }:
let
  inherit (lib.types) str;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat luaField;
  inherit (helpers.options) nullableSubmodule simple nullable;
in
{
  options = {
    rename = nullableSubmodule {
      workspace = simple str;
      name = nullable str;
    };
    move = nullableSubmodule {
      workspace = nullable str;
      monitor = simple str;
    };
    swap_monitors = nullableSubmodule {
      monitor1 = simple str;
      monitor2 = simple str;
    };
    toggle_special = nullable str;
  };

  builders = {
    rename =
      args:
      "hl.dsp.workspace.rename({${
        luaConcat [
          (luaField args "workspace")
          (luaField args "name")
        ]
      }})";
    move =
      args:
      "hl.dsp.workspace.move({${
        luaConcat [
          (luaField args "workspace")
          (luaField args "monitor")
        ]
      }})";
    swap_monitors =
      args:
      "hl.dsp.workspace.swap_monitors({${
        luaConcat [
          (luaField args "monitor1")
          (luaField args "monitor2")
        ]
      }})";
    toggle_special = name: ''hl.dsp.workspace.toggle_special("${name}")'';
  };

}
