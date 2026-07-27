{ lib, hyprlib, ... }:
{
  flake.homeModules.window_rule =
    { config, ... }:
    let
      inherit (lib) mkOption mapAttrs mapAttrsToList;
      inherit (lib.types)
        bool
        enum
        number
        str
        ints
        either
        attrsOf
        submodule
        ;

      inherit (hyprlib.types) numbers tuple;
      inherit (hyprlib.types.hyprland) gradient;
      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.window_rule;
      cfg' = lib.pipe cfg [
        (mapAttrsToList (name: params: params // { inherit name; }))
        (map filterValidAttrs)
        (map recursiveMkPreferred)
      ];

      matches = {
        class = str;
        title = str;
        initial_class = str;
        initial_title = str;
        tag = str;
        xwayland = bool;
        float = bool;
        fullscreen = bool;
        pin = bool;
        stableid = str;
        focus = bool;
        group = bool;
        modal = bool;
        fullscreen_state_client = ints.between 0 3;
        fullscreen_state_internal = ints.between 0 3;
        workspace = str;
        content = enum [
          "none"
          "photo"
          "video"
          "game"
        ];
        xdg_tag = str;
      };

      staticEffects = {
        float = bool;
        tile = bool;
        fullscreen = bool;
        maximize = bool;
        fullscreen_state = str;
        move = tuple (either number str) 2;
        size = tuple (either number str) 2;
        center = bool;
        pseudo = bool;
        monitor = str;
        workspace = str;
        no_initial_focus = bool;
        pin = bool;
        suppress_event = enum [
          "fullscreen"
          "maximize"
          "activate"
          "activatefocus"
          "fullscreenoutput"
        ];
        content = enum [
          "none"
          "photo"
          "video"
          "game"
        ];
        no_close_for = ints.unsigned;
        scrolling_width = numbers.unsigned;
      };

      dynamicEffects = {
        persistent_size = bool;
        no_max_size = bool;
        stay_focused = bool;
        animation = str;
        border_color = gradient;
        idle_inhibit = enum [
          "none"
          "always"
          "focus"
          "fullscreen"
        ];
        opacity = str;
        tag = str;
        max_size = tuple number 2;
        min_size = tuple number 2;
        border_size = ints.unsigned;
        rounding = ints.unsigned;
        rounding_power = numbers.unsigned;
        allows_input = bool;
        dim_around = bool;
        decorate = bool;
        focus_on_activate = bool;
        keep_aspect_ratio = bool;
        nearest_neighbor = bool;
        no_anim = bool;
        no_blur = bool;
        no_dim = bool;
        no_focus = bool;
        no_follow_mouse = bool;
        no_shadow = bool;
        no_shortcuts_inhibit = bool;
        no_screen_share = bool;
        no_vrr = bool;
        no_auto_hdr = bool;
        opaque = bool;
        force_rgbx = bool;
        sync_fullscreen = bool;
        immediate = bool;
        xray = bool;
        render_unfocused = bool;
        scroll_mouse = numbers.unsigned;
        scroll_touchpad = numbers.unsigned;
        confine_pointer = bool;
      };

      window_ruleType = submodule {
        options = {
          match = mkOption {
            type = submodule { options = lib.mapAttrs (_: type: mkNullable { type = type; }) matches; };
            description = "Match conditions.";
          };
        }
        // mapAttrs (_: type: mkNullable { inherit type; }) staticEffects
        // mapAttrs (_: type: mkNullable { inherit type; }) dynamicEffects;
      };
    in
    {
      options.hyprnix.settings.window_rule = mkOption {
        type = attrsOf window_ruleType;
        default = { };
        description = "Hyprland window_rule configuration.";
        example = {
          "floating-mpv" = {
            match.class = "mpv";
            float = true;
            center = true;
            size = [
              1280
              720
            ];
          };

          "transparent-kitty" = {
            match.class = "kitty";
            opacity = [
              .9
              .75
            ];
          };
        };
      };
      config = {
        wayland.windowManager.hyprland.settings = {
          window_rule = cfg';
        };
      };
    };
}
