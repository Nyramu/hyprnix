{ lib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib)
        mkOption
        mkIf
        concatStringsSep
        ;
      inherit (lib.types)
        str
        ints
        enum
        submodule
        listOf
        attrsOf
        either
        ;

      cfg = config.hyprnix.settings.gesture.gestures;

      cfg' = lib.pipe cfg [
        groupGesturesByFlag
        (lib.mapAttrs' (
          suffix: gesture: {
            name = "gesture${suffix}";
            value = map gestureToString gesture;
          }
        ))
      ];

      directions = enum [
        "swipe"
        "horizontal"
        "vertical"
        "left"
        "right"
        "up"
        "down"
        "pinch"
        "pinchin"
        "pinchout"
      ];

      simpleActions = [
        "workspace"
        "move"
        "resize"
        "close"
        "fullscreen"
        "float"
        "cursorZoom"
      ];

      complexActions = [
        "dispatcher"
        "special"
        "float"
        "fullscreen"
        "cursorZoom"
      ];

      supportedFlags = [ "p" ];

      getFlagSuffix =
        flags:
        lib.pipe flags [
          (lib.filter (f: builtins.elem f supportedFlags))
          lib.unique
          (builtins.concatStringsSep "")
        ];

      groupGesturesByFlag = lib.foldl' (
        acc: g:
        let
          suffix = getFlagSuffix g.flags;
        in
        acc // { ${suffix} = (acc.${suffix} or [ ]) ++ [ g ]; }
      ) { };

      gestureToString =
        {
          fingers,
          direction,
          action,
          ...
        }:
        let
          actionStr =
            if builtins.isString action then
              action
            else
              let
                name = builtins.head (builtins.attrNames action);
              in
              "${name}, ${action.${name}}";
        in
        "${toString fingers}, ${direction}, ${actionStr}";

      isValidAction =
        action:
        builtins.isString action # if str then it's an already valid simple action
        || (
          builtins.length (builtins.attrNames action) == 1
          && builtins.elem (builtins.head (builtins.attrNames action)) complexActions
        );

      gestureType = submodule {
        options = {
          fingers = mkOption {
            type = ints.positive;
            description = "number of fingers required for the gesture";
            example = 3;
          };

          direction = mkOption {
            type = directions;
            description = "the direction that triggers the gesture";
            example = "pinch";
          };

          action = mkOption {
            type = either (enum simpleActions) (attrsOf str);
            description = "action to perform once the gesture ends";
            example = "close";
          };

          flags = mkOption {
            type = listOf (enum supportedFlags);
            default = [ ];
            description = ''
              special flags for the gesture.
              p -> Allows the gesture to bypass shortcut inhibitors.
            '';
          };
        };
      };
    in
    {
      options.hyprnix.settings.gesture.gestures = mkOption {
        type = listOf gestureType;
        default = [ ];
        description = "list of gestures";
        example = [
          {
            fingers = 2;
            direction = "pinchout";
            action = "close";
          }
          {
            fingers = 3;
            direction = "right";
            action = {
              dispatcher = "movefocus, r";
            };
          }
          {
            fingers = 2;
            direction = "pinchin";
            action = {
              special = "mySpecialWorkspace";
            };
          }
        ];
      };

      config = mkIf (cfg != [ ]) {
        assertions = lib.concatMap (g: [
          {
            assertion = isValidAction g.action;
            message =
              let
                actionStr =
                  if builtins.isString g.action then
                    "\"${g.action}\""
                  else
                    "{ ${concatStringsSep "; " (map (k: "${k} = ...") (builtins.attrNames g.action))} }";
              in
              ''
                Invalid gesture action: "${actionStr}".
                Must be either:
                  - a simple action string: [ ${concatStringsSep ", " simpleActions} ]
                  - an attrset with exactly one key from: [ ${concatStringsSep ", " complexActions} ]
              '';
          }
        ]) cfg;

        wayland.windowManager.hyprland.settings = cfg';
      };
    };
}
