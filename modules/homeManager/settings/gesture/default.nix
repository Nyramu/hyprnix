{ lib, hyprlib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib.types) bool ints;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.gesture;
      cfg' = lib.pipe cfg [
        # gestures are taken care of in the gestures.nix file
        (lib.filterAttrsRecursive (k: _: k != "gestures"))
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.gesture = {
        workspace_swipe_distance = mkNullable {
          type = ints.unsigned;
          description = "in px, the distance of the touchpad gesture";
        };

        workspace_swipe_touch = mkNullable {
          type = bool;
          description = "enable workspace swiping from the edge of a touchscreen";
        };

        workspace_swipe_invert = mkNullable {
          type = bool;
          description = "invert the direction (touchpad only)";
        };

        workspace_swipe_touch_invert = mkNullable {
          type = bool;
          description = "invert the direction (touchscreen only)";
        };

        workspace_swipe_min_speed_to_force = mkNullable {
          type = ints.unsigned;
          description = ''
            minimum speed in px per timepoint to force the change ignoring cancel_ratio.
            Setting to 0 will disable this mechanic.
          '';
        };

        workspace_swipe_cancel_ratio = mkNullable {
          type = numbers.between 0 1;
          description = ''
            how much the swipe has to proceed in order to commence it.
            (0.7 -> if > 0.7 * distance, switch, if less, revert)
          '';
        };

        workspace_swipe_create_new = mkNullable {
          type = bool;
          description = "whether a swipe right on the last workspace should create a new one.";
        };

        workspace_swipe_direction_lock = mkNullable {
          type = bool;
          description = "if enabled, switching direction will be locked when you swipe past the direction_lock_threshold (touchpad only).";
        };

        workspace_swipe_direction_lock_threshold = mkNullable {
          type = ints.unsigned;
          description = "in px, the distance to swipe before direction lock activates (touchpad only).";
        };

        workspace_swipe_forever = mkNullable {
          type = bool;
          description = "if enabled, swiping will not clamp at the neighboring workspaces but continue to the further ones.";
        };

        workspace_swipe_use_r = mkNullable {
          type = bool;
          description = "if enabled, swiping will use the r prefix instead of the m prefix for finding workspaces.";
        };

        close_max_timeout = mkNullable {
          type = ints.unsigned;
          description = "the timeout for a window to close when using a 1:1 gesture, in ms";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          gestures = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
