{ lib }:
let
  inherit (lib)
    mkOption
    optionalString
    concatStringsSep
    filter
    filterAttrs
    head
    attrNames
    ;
  inherit (lib.types)
    nullOr
    str
    number
    submodule
    enum
    ;

  ifPresent = x: optionalString (x != null);
  luaConcat = fields: concatStringsSep ", " (filter (s: s != "") fields);
  callNestedBuilders =
    builders: params:
    let
      active = filterAttrs (_: v: v != null) params;
      name = head (attrNames active);
    in
    builders.${name} active.${name};

  luaBuilders = {
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

    workspace = callNestedBuilders workspaceBuilders;
  };

  workspaceBuilders = {
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

  optionHelpers = {
    simpleStr = mkOption { type = str; };
    nullableStr = mkOption {
      type = nullOr str;
      default = null;
    };
    nullableNumber = mkOption {
      type = nullOr number;
      default = null;
    };
    empty = mkOption {
      type = nullOr (submodule { });
      default = null;
    };
    nullableSubmodule =
      opts:
      mkOption {
        type = nullOr (submodule {
          options = opts;
        });
        default = null;
      };
  };

  types = with optionHelpers; {
    workspaceType = nullableSubmodule {
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
  };
in
{
  type = submodule {
    options = with optionHelpers; {
      exec_cmd = nullableStr;
      exec_raw = nullableStr;
      exit = empty;
      submap = nullableStr;
      pass = nullableSubmodule { window = simpleStr; };
      send_shortcut = types.send_shortcutType;
      send_key_state = types.send_key_stateType;
      layout = nullableStr;
      dpms = types.dpmsType;
      event = nullableStr;
      global = nullableStr;
      force_idle = nullableNumber;
      no_op = empty;
      workspace = types.workspaceType;
    };
  };

  mkLuaDispatcher = name: params: luaBuilders.${name} params;
}
