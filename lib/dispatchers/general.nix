{ lib }:
let
  inherit (lib.types)
    enum
    str
    bool
    number
    ;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat luaField;
  inherit (helpers.options)
    nullableSubmodule
    simple
    nullable
    empty
    ;

  focusType = nullableSubmodule {
    direction = nullable (enum [
      "left"
      "right"
      "up"
      "down"
    ]);
    monitor = nullable str;
    workspace = nullable str;
    on_current_monitor = nullable bool;
    window = nullable str;
    urgent_or_last = nullable bool;
    last = nullable bool;
  };

  passType = nullableSubmodule { window = simple str; };

  send_shortcutType = nullableSubmodule {
    mods = simple str;
    key = simple str;
    window = simple str;
  };

  send_key_stateType = nullableSubmodule {
    mods = simple str;
    key = simple str;
    state = simple (enum [
      "up"
      "down"
    ]);
    window = nullable str;
  };

  dpmsType = nullableSubmodule {
    action = nullable str;
    monitor = nullable str;
  };
in
{
  options = {
    exec_cmd = nullable str;
    exec_raw = nullable str;
    focus = focusType;
    exit = empty { };
    submap = nullable str;
    pass = passType;
    send_shortcut = send_shortcutType;
    send_key_state = send_key_stateType;
    layout = nullable str;
    dpms = dpmsType;
    event = nullable str;
    global = nullable str;
    force_idle = nullable number;
    no_op = empty { };
  };

  builders = {
    exec_cmd = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
    exec_raw = cmd: ''hl.dsp.exec_raw("${cmd}")'';
    focus =
      args:
      "hl.dsp.focus({${
        luaConcat [
          (luaField args "direction")
          (luaField args "monitor")
          (luaField args "workspace")
          (luaField args "on_current_monitor")
          (luaField args "window")
          (luaField args "urgent_or_last")
          (luaField args "last")
        ]
      }})";
    exit = _: "hl.dsp.exit()";
    submap = name: ''hl.dsp.submap("${name}")'';
    pass = args: "hl.dsp.pass({${luaField args "window"}})";
    send_shortcut =
      args:
      "hl.dsp.send_shortcut({${
        luaConcat [
          (luaField args "mods")
          (luaField args "key")
          (luaField args "window")
        ]
      }})";
    send_key_state =
      args:
      "hl.dsp.send_shortcut({${
        luaConcat [
          (luaField args "mods")
          (luaField args "key")
          (luaField args "state")
          (luaField args "window")
        ]
      }})";
    layout = message: ''hl.dsp.layout("${message}")'';
    dpms =
      args:
      "hl.dsp.dpms({${
        luaConcat [
          (luaField args "action")
          (luaField args "monitor")
        ]
      }})";
    event = message: ''hl.dsp.event("${message}")'';
    global = message: ''hl.dsp.global("${message}")'';
    force_idle = seconds: "hl.dsp.force_idle(${seconds})";
    no_op = _: "hl.dsp.no_op()";
  };
}
