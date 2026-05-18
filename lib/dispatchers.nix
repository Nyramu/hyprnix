{ lib }:
let
  inherit (lib)
    mkOption
    optionalString
    concatStringsSep
    filter
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
      ''hl.dsp.send_shortcut({mods = "${mods}", key = "${key}", state = "${state}" ${ifPresent window '', window = "${window}"''}})'';
    layout = message: ''hl.dsp.layout("${message}")'';
    dpms =
      { action, monitor }:
      "hl.dsp.dpms({${
        luaConcat [
          (ifPresent action ''action = "${action}"'')
          (ifPresent monitor ''monitor = "${monitor}"'')
        ]
      })";
    event = message: ''hl.dsp.event("${message}")'';
    global = message: ''hl.dsp.global("${message}")'';
    force_idle = seconds: "hl.dsp.force_idle(${seconds})";
    no_op = _: "hl.dsp.no_op()";
  };

  options = {
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
in
{
  type = submodule {
    options = with options; {
      exec_cmd = nullableStr;
      exec_raw = nullableStr;
      exit = empty;
      submap = nullableStr;

      pass = nullableSubmodule {
        options.window = simpleStr;
      };

      send_shortcut = nullableSubmodule {
        options = {
          mods = simpleStr;
          key = simpleStr;
          window = simpleStr;
        };
      };

      send_key_state = nullableSubmodule {
        options = {
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
      };

      layout = nullableStr;

      dpms = nullableSubmodule {
        options = {
          action = nullableStr;
          monitor = nullableStr;
        };
      };

      event = nullableStr;
      global = nullableStr;
      force_idle = nullableNumber;
      no_op = empty;
    };
  };

  mkLuaDispatcher = name: params: luaBuilders.${name} params;
}
