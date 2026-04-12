{ self, lib, ... }:
{
  flake.homeModules.windowrules =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        enum
        number
        str
        ints
        either
        nullOr
        listOf
        addCheck
        submodule
        ;
      tuple = n: (addCheck (listOf ints.unsigned) (l: builtins.length l == n));
      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.windowrules;

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
        focus = bool;
        group = bool;
        modal = bool;
        fullscreen_state_client = ints.between 0 3;
        fullscreen_state_internal = ints.between 0 3;
        workspace = either ints.unsigned str;
        content = ints.between 0 3;
        xdg_tag = str;
      };

      effects = {
        # Static effects
        float = bool;
        tile = bool;
        fullscreen = bool;
        maximize = bool;
        fullscreen_state = ints.between 0 3;
        move = either str (tuple 2);
        size = either str (tuple 2);
        center = bool;
        pseudo = bool;
        monitor = either ints.unsigned str;
        workspace = either ints.unsigned str;
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
        # Dynamic effects - should make Hyprland give parsing errors if
        # used on anonymous windowrules instead of named windowrules
        persistent_size = bool;
        no_max_size = bool;
        stay_focused = bool;
        animation = str;
        border_color = str;
        idle_inhibit = enum [
          "none"
          "always"
          "focus"
          "fullscreen"
        ];
        opacity = (addCheck (listOf number) (l: builtins.length l > 0 && builtins.length l <= 3));
        tag = str;
        max_size = tuple 2;
        min_size = tuple 2;
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
        opaque = bool;
        force_rgbx = bool;
        sync_fullscreen = bool;
        immediate = bool;
        xray = bool;
        render_unfocused = bool;
        scroll_mouse = numbers.unsigned;
        scroll_touchpad = numbers.unsigned;
      };

      windowruleType = submodule {
        options = {
          name = mkOption {
            type = nullOr str;
            default = null;
            description = "Name of the windowrule";
          };

          match = mkOption {
            type = submodule {
              options = lib.mapAttrs (
                _: type:
                mkOption {
                  type = nullOr type;
                  default = null;
                }
              ) matches;
            };
            default = { };
            description = "Match conditions.";
          };
        }
        // lib.mapAttrs (
          _: type:
          mkOption {
            type = nullOr type;
            default = null;
          }
        ) effects;
      };

      effectParser =
        v:
        if v == null || v == false then
          null
        else if v == true then
          "on"
        else if builtins.isList v then
          lib.concatMapStringsSep " " toString v
        else
          toString v;

      matchParser = v: if builtins.isBool v then lib.boolToString v else toString v;

      getEffectPairs =
        rule:
        lib.concatMapAttrs (
          n: v:
          let
            val = effectParser v;
          in
          if val != null then { "${n}" = val; } else { }
        ) (builtins.intersectAttrs effects rule);

      getMatchPairs =
        rule:
        lib.mapAttrs' (p: v: lib.nameValuePair "match:${p}" (matchParser v)) (
          lib.filterAttrs (_: v: v != null) rule.match
        );

      serialize =
        rule:
        if builtins.isString rule then
          rule
        else
          let
            allPairs = lib.mapAttrsToList lib.nameValuePair (getEffectPairs rule // getMatchPairs rule);
          in
          if rule.name == null then
            lib.concatStringsSep ", " (map (nv: "${nv.name} ${nv.value}") allPairs)
          else
            { name = rule.name; } // lib.listToAttrs allPairs;

    in
    {
      options.hyprnix.settings.windowrules = mkOption {
        type = listOf windowruleType;
        default = [ ];
        description = "Hyprland windowrules configuration.";
        example = [
          # Named rule
          {
            name = "floating-mpv";
            match.class = "mpv";
            float = true;
            center = true;
            size = [
              1280
              720
            ];
          }
          # Anonymous rule
          {
            match.class = "kitty";
            opacity = [
              0.9
              0.75
            ];
          }
        ];
      };

      config.wayland.windowManager.hyprland.settings.windowrule = map serialize cfg;
    };
}
