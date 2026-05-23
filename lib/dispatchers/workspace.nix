{ lib }:
let
  inherit (lib) optionalString;
  inherit (lib.types) str;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat;
  inherit (helpers.options) nullableSubmodule simple nullable;
in
{
  options = nullableSubmodule {
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
          ''workspace = "${args.workspace}"''
          (optionalString (args ? name) ''name = "${args.name}"'')
        ]
      }})";
    move =
      args:
      "hl.dsp.workspace.move({${
        luaConcat [
          (optionalString (args ? workspace) ''workspace = "${args.workspace}"'')
          ''monitor = "${args.monitor}"''
        ]
      }})";
    swap_monitors =
      args:
      "hl.dsp.workspace.swap_monitors({${
        luaConcat [
          ''monitor1 = "${args.monitor1}"''
          ''monitor2 = "${args.monitor2}"''
        ]
      }})";
    toggle_special = name: ''hl.dsp.workspace.toggle_special("${name}")'';
  };

}
