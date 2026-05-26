{ lib }:
let
  inherit (lib.types) str bool int;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat luaField;
  inherit (helpers.options) nullableSubmodule simple nullable;

  toggleType = nullableSubmodule { window = nullable str; };

  nextType = nullableSubmodule { window = nullable str; };

  prevType = nullableSubmodule { window = nullable str; };

  activeType = nullableSubmodule {
    index = simple int;
    window = nullable str;
  };

  move_windowType = nullableSubmodule {
    forward = nullable bool;
    window = nullable str;
  };

  lockType = nullableSubmodule {
    action = nullable str;
    window = nullable str;
  };

  lock_activeType = nullableSubmodule { action = nullable str; };
in
{
  options = {
    toggle = toggleType;
    next = nextType;
    prev = prevType;
    active = activeType;
    move_window = move_windowType;
    lock = lockType;
    lock_active = lock_activeType;
  };

  builders = {
    toggle = args: "hl.dsp.group.toggle({${luaField args "window"}})";
    next = args: "hl.dsp.group.next({${luaField args "window"}})";
    prev = args: "hl.dsp.group.prev({${luaField args "window"}})";
    active =
      args:
      "hl.dsp.group.active({${
        luaConcat [
          (luaField args "index")
          (luaField args "window")
        ]
      }})";
    move_window =
      args:
      "hl.dsp.group.move_window({${
        luaConcat [
          (luaField args "forward")
          (luaField args "window")
        ]
      }})";
    lock =
      args:
      "hl.dsp.group.lock({${
        luaConcat [
          (luaField args "action")
          (luaField args "window")
        ]
      }})";
    lock_active = args: "hl.dsp.group.lock_active({${luaField args "action"}})";
  };
}
