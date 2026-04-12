{ lib, ... }:
{
  flake.homeModules.windowrules =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        float
        str
        ints
        either
        nullOr
        listOf
        submodule
        ;

      cfg = config.hyprnix.settings.windowrules;

      matches = {
        class = str;
        title = str;
        initial_class = str;
        initial_title = str;
        tag = str;
        xdg_tag = str;
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
      };

      effects = {
        float = bool;
        tile = bool;
        fullscreen = bool;
        maximize = bool;
        center = either bool ints.unsigned;
        pin = bool;
        pseudo = bool;
        stayfocused = bool;
        immediate = bool;
        keepaspectratio = bool;
        nofocus = bool;
        noshadow = bool;
        nodim = bool;
        noanim = bool;
        forcergbx = bool;
        size = either str (listOf ints.unsigned);
        minsize = either str (listOf ints.unsigned);
        maxsize = either str (listOf ints.unsigned);
        move = str;
        opacity = either float (listOf float);
        rounding = ints.unsigned;
        border_size = ints.unsigned;
        bordercolor = str;
        workspace = either ints.unsigned str;
        monitor = either ints.unsigned str;
        animation = str;
        tag = str;
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
