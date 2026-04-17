{ lib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib) mkOption mkIf concatStringsSep;
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

      gestureToString =
        {
          fingers,
          direction,
          action,
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

      isOnlyOneKey =
        { action, ... }:
        builtins.isString action # if str then it's an already valid simple action
        || builtins.length (builtins.attrNames action) == 1;

      isValidKey =
        { action, ... }:
        builtins.isString action # if str then it's an already valid simple action
        || builtins.elem (builtins.head (builtins.attrNames action)) complexActions;

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
        assertions =
          map (g: {
            assertion = isOnlyOneKey g;
            message = "Gesture action must be either one of [ ${concatStringsSep ", " simpleActions} ] or an attrset with exactly one key.";
          }) cfg
          ++ map (g: {
            assertion = isValidKey g;
            message = "Invalid action key. Must be one of: [ ${concatStringsSep ", " complexActions} ]";
          }) cfg;

        wayland.windowManager.hyprland.settings = {
          gesture = map gestureToString cfg;
        };
      };
    };
}
