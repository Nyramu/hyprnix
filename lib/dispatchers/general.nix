{ lib }:
let
  inherit (lib) mkOption;
  inherit (lib.types) enum;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat ifPresent;
  inherit (helpers.options)
    nullableSubmodule
    nullableStr
    simpleStr
    nullableNumber
    empty
    ;

  passType = nullableSubmodule { window = simpleStr; };

  send_shortcutType = nullableSubmodule {
    mods = simpleStr;
    key = simpleStr;
    window = simpleStr;
  };

  send_key_stateType = nullableSubmodule {
    mods = simpleStr;
    key = simpleStr;
    state = mkOption {
      type = enum [
        "up"
        "down"
      ];
    };
    window = nullableStr;
  };

  dpmsType = nullableSubmodule {
    action = nullableStr;
    monitor = nullableStr;
  };
in
{
  options = {
    exec_cmd = nullableStr;
    exec_raw = nullableStr;
    exit = empty;
    submap = nullableStr;
    pass = passType;
    send_shortcut = send_shortcutType;
    send_key_state = send_key_stateType;
    layout = nullableStr;
    dpms = dpmsType;
    event = nullableStr;
    global = nullableStr;
    force_idle = nullableNumber;
    no_op = empty;
  };

  builders = {
    exec_cmd = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
    exec_raw = cmd: ''hl.dsp.exec_raw("${cmd}")'';
    exit = _: "hl.dsp.exit()";
    submap = name: ''hl.dsp.submap("${name}")'';
    pass = { window }: "hl.dsp.pass({ ${ifPresent window ''window = "${window}"''} })";
    send_shortcut =
      {
        mods,
        key,
        window,
      }:
      ''hl.dsp.send_shortcut({mods = "${mods}", key = "${key}" ${ifPresent window '', window = "${window}"''}})'';
    send_key_state =
      {
        mods,
        key,
        state,
        window,
      }:
      "hl.dsp.send_shortcut({${
        luaConcat [
          ''mods = "${mods}"''
          ''key = "${key}"''
          ''state = "${state}"''
          (ifPresent window ''window = "${window}"'')
        ]
      }})";
    layout = message: ''hl.dsp.layout("${message}")'';
    dpms =
      { action, monitor }:
      "hl.dsp.dpms({${
        luaConcat [
          (ifPresent action ''action = "${action}"'')
          (ifPresent monitor ''monitor = "${monitor}"'')
        ]
      }})";
    event = message: ''hl.dsp.event("${message}")'';
    global = message: ''hl.dsp.global("${message}")'';
    force_idle = seconds: "hl.dsp.force_idle(${seconds})";
    no_op = _: "hl.dsp.no_op()";
  };
}
