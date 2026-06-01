{ lib }:
let
  inherit (lib.types) str number ints;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat luaField;
  inherit (helpers.options) nullableSubmodule simple nullable;

  move_to_cornerType = nullableSubmodule {
    corner = simple (ints.between 0 3);
    window = nullable str;
  };

  moveType = nullableSubmodule {
    x = simple number;
    y = simple number;
  };
in
{
  options = {
    move_to_corner = move_to_cornerType;
    move = moveType;
  };

  builders = {
    move_to_corner =
      args:
      "hl.dsp.cursor.move_to_corner({${
        luaConcat [
          (luaField args "corner")
          (luaField args "window")
        ]
      }})";
    move =
      args:
      "hl.dsp.cursor.move({${
        luaConcat [
          (luaField args "x")
          (luaField args "y")
        ]
      }})";
  };
}
