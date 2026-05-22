{ lib }:
let
  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat ifPresent;
  inherit (helpers.options) nullableSubmodule nullableStr simpleStr;
in
{
  options = nullableSubmodule {
    rename = nullableSubmodule {
      workspace = simpleStr;
      name = nullableStr;
    };
    move = nullableSubmodule {
      workspace = nullableStr;
      monitor = simpleStr;
    };
    swap_monitors = nullableSubmodule {
      monitor1 = simpleStr;
      monitor2 = simpleStr;
    };
    toggle_special = nullableStr;
  };

  builders = {
    rename =
      { workspace, name }:
      "hl.dsp.workspace.rename({${
        luaConcat [
          ''workspace = "${workspace}"''
          (ifPresent name ''name = "${name}"'')
        ]
      }})";
    move =
      { workspace, monitor }:
      "hl.dsp.workspace.move({${
        luaConcat [
          (ifPresent workspace ''workspace = "${workspace}"'')
          ''monitor = "${monitor}"''
        ]
      }})";
    swap_monitors =
      { monitor1, monitor2 }:
      "hl.dsp.workspace.swap_monitors({${
        luaConcat [
          ''monitor1 = "${monitor1}"''
          ''monitor2 = "${monitor2}"''
        ]
      }})";
    toggle_special = name: ''hl.dsp.workspace.toggle_special("${name}")'';
  };

}
