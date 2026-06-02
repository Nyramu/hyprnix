{ lib, hyprlib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        str
        bool
        ints
        enum
        submodule
        listOf
        ;

      inherit (hyprlib.types) numbers;
      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.gesture.gestures;

      cfg' = lib.pipe cfg [
        (map filterValidAttrs)
        (map recursiveMkPreferred)
        (map mkLuaGesture)
      ];

      mkLuaGesture = g: { _args = [ g ]; };

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

      actions = [
        "workspace"
        "move"
        "resize"
        "special"
        "close"
        "fullscreen"
        "float"
        "cursor_zoom"
        "scroll_move"
      ];

      gestureType = submodule {
        options = {
          fingers = mkOption {
            type = ints.positive;
            description = "number of fingers";
            example = 3;
          };

          direction = mkOption {
            type = directions;
            description = "gesture direction";
            example = "pinch";
          };

          action = mkOption {
            type = enum actions;
            description = "action to perform";
            example = "close";
          };

          mods = mkNullable {
            type = str;
            description = "optional modifier mask";
            example = "SUPER";
          };

          scale = mkNullable {
            type = numbers.unsigned;
            description = "optional gesture delta multiplier";
            example = 1.5;
          };

          disable_inhibit = mkNullable {
            type = bool;
            description = "if true, allows the gesture to bypass shortcut inhibitors";
          };

          workspace_name = mkNullable {
            type = str;
            description = "special workspace name";
          };

          mode = mkNullable {
            type = str;
            description = ''
              value depends on the action.
              action is "fullscreen" -> "maximize" to do maximize instead of fullscreen
              action is "float" -> "float" or "tile" to force a direction of floating
              action is "cursor_zoom" -> "mult" to use a multiplier or "live" to update continuously during the pinch
            '';
          };

          zoom_level = mkNullable {
            type = numbers.positive;
            description = ''zoom factor if action is "cursor_zoom"'';
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
            fingers = 2;
            direction = "pinchin";
            action = "special";
            workspace_name = "mySpecialWorkspace";
          }
        ];
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          gesture = cfg';
        };
      };
    };
}
