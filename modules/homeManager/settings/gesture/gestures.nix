{ lib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib)
        mkOption
        mkIf
        mapAttrsToList
        ;
      inherit (lib.types)
        str
        ints
        enum
        submodule
        listOf
        oneOf
        ;

      cfg = config.hyprnix.settings.gesture.gestures;

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

      simpleActions = enum [
        "workspace"
        "move"
        "resize"
        "close"
        "fullscreen"
        "float"
        "cursorZoom"
      ];

      complexActionTypes = {
        dispatcher = submodule {
          options = {
            dispatcher = mkOption {
              type = str;
              description = "dispatcher action";
              example = "movefocus, r";
            };
          };
        };
      };

      complexActionParsers = {
        dispatcher = args: "dispatcher, ${args}";
      };

      gestureToString =
        g:
        let
          actionStr =
            if builtins.isString g.action then
              g.action
            else
              let
                # It is ensured by the option definition that there can be only 1
                actionName = builtins.head (builtins.attrNames g.action);
                actionArgs = g.action.${actionName};
                parser = complexActionParsers.${actionName};
              in
              parser actionArgs;
        in
        "${toString g.fingers}, ${g.direction}, ${actionStr}";

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
            type = oneOf ([ simpleActions ] ++ mapAttrsToList (_: v: v) complexActionTypes);
            description = "action to perform once the gesture ends";
            example = "close";
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
            direction = "pinchOut";
            action = "close";
          }
          {
            fingers = 3;
            direction = "right";
            action = {
              dispatcher = "movefocus, r";
            };
          }
        ];
      };

      config = mkIf (cfg != [ ]) {
        wayland.windowManager.hyprland.settings = {
          gesture = map gestureToString cfg;
        };
      };
    };
}
