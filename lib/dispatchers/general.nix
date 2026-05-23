{ lib }:
let
  inherit (lib) optionalString;
  inherit (lib.types)
    enum
    str
    number
    ;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat;
  inherit (helpers.options)
    nullableSubmodule
    simple
    nullable
    empty
    ;

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
    exit = _: "hl.dsp.exit()";
    submap = name: ''hl.dsp.submap("${name}")'';
    pass = args: "hl.dsp.pass({ ${optionalString (args ? window) ''window = "${args.window}"''} })";
    send_shortcut =
      args:
      "hl.dsp.send_shortcut({${
        luaConcat [
          ''mods = "${args.mods}"''
          ''key = "${args.key}"''
          (optionalString (args ? window) ''window = "${args.window}"'')
        ]
      }})";
    send_key_state =
      args:
      "hl.dsp.send_shortcut({${
        luaConcat [
          ''mods = "${args.mods}"''
          ''key = "${args.key}"''
          ''state = "${args.state}"''
          (optionalString (args ? window) ''window = "${args.window}"'')
        ]
      }})";
    layout = message: ''hl.dsp.layout("${message}")'';
    dpms =
      args:
      "hl.dsp.dpms({${
        luaConcat [
          (optionalString (args ? action) ''action = "${args.action}"'')
          (optionalString (args ? monitor) ''monitor = "${args.monitor}"'')
        ]
      }})";
    event = message: ''hl.dsp.event("${message}")'';
    global = message: ''hl.dsp.global("${message}")'';
    force_idle = seconds: "hl.dsp.force_idle(${seconds})";
    no_op = _: "hl.dsp.no_op()";
  };
}
