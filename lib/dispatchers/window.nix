{ lib }:
let
  inherit (lib.types)
    str
    bool
    number
    either
    enum
    oneOf
    ;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) luaConcat luaField;
  inherit (helpers.options)
    nullableSubmodule
    simple
    nullable
    empty
    ;

  types = import ../types.nix { inherit lib; };
  inherit (types) tuple;
  inherit (types.hyprland) gradient;

  actionType = enum [
    "toggle"
    "enable"
    "on"
    "disable"
    "off"
  ];

  closeType = nullableSubmodule { window = nullable str; };

  killType = nullableSubmodule { window = nullable str; };

  signalType = nullableSubmodule {
    signal = simple str;
    window = nullable str;
  };

  floatType = nullableSubmodule {
    action = nullable actionType;
    window = nullable str;
  };

  fullscreenType = nullableSubmodule {
    mode = nullable (enum [
      "maximized"
      "fullscreen"
    ]);
    action = nullable actionType;
    window = nullable str;
  };

  fullscreen_stateType = nullableSubmodule {
    internal = simple str;
    client = simple str;
    action = nullable actionType;
    window = nullable str;
  };

  pseudoType = nullableSubmodule {
    action = nullable actionType;
    window = nullable str;
  };

  moveType = nullableSubmodule {
    direction = nullable str;
    group_aware = nullable bool;
    window = nullable str;
    workspace = nullable str;
    follow = nullable bool;
    monitor = nullable str;
    x = nullable number;
    y = nullable number;
    relative = nullable number;
    into_group = nullable str;
    into_or_create_group = nullable str;
    out_of_group = nullable (either bool str);
  };

  swapType = nullableSubmodule {
    direction = nullable str;
    target = nullable str;
    next = nullable bool;
    prev = nullable bool;
  };

  centerType = nullableSubmodule { window = nullable str; };

  cycle_nextType = nullableSubmodule {
    next = nullable bool;
    tiled = nullable bool;
    floating = nullable bool;
    window = nullable str;
  };

  tagType = nullableSubmodule {
    tag = simple str;
    window = nullable str;
  };

  clear_tagsType = nullableSubmodule { window = nullable str; };

  pinType = nullableSubmodule { window = nullable str; };

  alter_zorderType = nullableSubmodule {
    mode = simple (enum [
      "top"
      "bottom"
    ]);
    window = nullable str;
  };

  set_propType = nullableSubmodule {
    prop = simple str;
    value = simple (oneOf [
      str
      number
      bool
      (tuple number 2)
      gradient
    ]);
    window = nullable str;
  };

  deny_from_groupType = nullableSubmodule { action = nullable str; };

  # shared with the mouse version
  resizeType = nullableSubmodule {
    x = nullable number;
    y = nullable number;
    relative = nullable bool;
    window = nullable str;
  };
in
{
  options = {
    close = closeType;
    kill = killType;
    signal = signalType;
    float = floatType;
    fullscreen = fullscreenType;
    fullscreen_state = fullscreen_stateType;
    pseudo = pseudoType;
    move = moveType;
    swap = swapType;
    center = centerType;
    cycle_next = cycle_nextType;
    tag = tagType;
    clear_tags = clear_tagsType;
    toggle_swallow = empty { };
    pin = pinType;
    alter_zorder = alter_zorderType;
    set_prop = set_propType;
    deny_from_group = deny_from_groupType;

    drag = empty { };
    resize = resizeType;
  };

  builders = {
    close = args: "hl.dsp.window.close(${luaField args "window"})";
    kill = args: "hl.dsp.window.kill(${luaField args "window"})";
    signal =
      args:
      "hl.dsp.window.signal({${
        luaConcat [
          (luaField args "signal")
          (luaField args "window")
        ]
      }})";
    float =
      args:
      "hl.dsp.window.float({${
        luaConcat [
          (luaField args "action")
          (luaField args "window")
        ]
      }})";
    fullscreen =
      args:
      "hl.dsp.window.fullscreen({${
        luaConcat [
          (luaField args "mode")
          (luaField args "action")
          (luaField args "window")
        ]
      }})";
    fullscreen_state =
      args:
      "hl.dsp.window.fullscreen_state({${
        luaConcat [
          (luaField args "internal")
          (luaField args "client")
          (luaField args "action")
          (luaField args "window")
        ]
      }})";
    pseudo =
      args:
      "hl.dsp.window.pseudo({${
        luaConcat [
          (luaField args "action")
          (luaField args "window")
        ]
      }})";
    move =
      args:
      "hl.dsp.window.move({${
        luaConcat [
          (luaField args "direction")
          (luaField args "group_aware")
          (luaField args "window")
          (luaField args "workspace")
          (luaField args "follow")
          (luaField args "monitor")
          (luaField args "x")
          (luaField args "y")
          (luaField args "relative")
          (luaField args "into_group")
          (luaField args "into_or_create_group")
          (luaField args "out_of_group")
        ]
      }})";
    swap =
      args:
      "hl.dsp.window.swap({${
        luaConcat [
          (luaField args "direction")
          (luaField args "target")
          (luaField args "next")
          (luaField args "prev")
        ]
      }})";
    center = args: "hl.dsp.window.center({${luaField args "window"}})";
    cycle_next =
      args:
      "hl.dsp.window.cycle_next({${
        luaConcat [
          (luaField args "next")
          (luaField args "tiled")
          (luaField args "floating")
          (luaField args "window")
        ]
      }})";
    tag =
      args:
      "hl.dsp.window.tag({${
        luaConcat [
          (luaField args "tag")
          (luaField args "window")
        ]
      }})";
    clear_tags = args: "hl.dsp.window.clear_tags({${(luaField args "window")}})";
    toggle_swallow = _: "hl.dsp.window.toggle_swallow()";
    pin = args: "hl.dsp.window.pin({${luaField args "window"}})";
    alter_zorder =
      args:
      "hl.dsp.window.alter_zorder({${
        luaConcat [
          (luaField args "mode")
          (luaField args "window")
        ]
      }})";
    set_prop =
      args:
      "hl.dsp.window.set_prop({${
        luaConcat [
          (luaField args "prop")
          (luaField args "value")
          (luaField args "window")
        ]
      }})";
    deny_from_group = args: "hl.dsp.window.deny_from_group({${luaField args "action"}})";
    drag = _: "hl.dsp.window.drag()";
    resize =
      args:
      # for the mouse version
      if builtins.all (v: v == null) (builtins.attrValues args) then
        "hl.dsp.window.resize()"
      else
        "hl.dsp.window.resize({${
          luaConcat [
            (luaField args "x")
            (luaField args "y")
            (luaField args "relative")
            (luaField args "window")
          ]
        }})";
  };
}
