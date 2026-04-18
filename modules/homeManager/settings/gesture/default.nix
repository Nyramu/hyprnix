{ self, lib, ... }:
{
  flake.homeModules.gesture =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) bool nullOr ints;

      inherit (self.lib.hyprnix.types) numbers filterValidAttrs;

      cfg = config.hyprnix.settings.gesture;
      cfg' = lib.pipe cfg [
        # gestures are taken care of in the gestures.nix file
        (lib.filterAttrsRecursive (k: _: k != "gestures"))
        filterValidAttrs
      ];
    in
    {
      options.hyprnix.settings.gesture = {
        workspace_swipe_distance = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "in px, the distance of the touchpad gesture";
        };

        workspace_swipe_touch = mkOption {
          type = nullOr bool;
          default = null;
          description = "enable workspace swiping from the edge of a touchscreen";
        };

        workspace_swipe_invert = mkOption {
          type = nullOr bool;
          default = null;
          description = "invert the direction (touchpad only)";
        };

        workspace_swipe_touch_invert = mkOption {
          type = nullOr bool;
          default = null;
          description = "invert the direction (touchscreen only)";
        };

        workspace_swipe_min_speed_to_force = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = ''
            minimum speed in px per timepoint to force the change ignoring cancel_ratio.
            Setting to 0 will disable this mechanic.
          '';
        };

        workspace_swipe_cancel_ratio = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = ''
            how much the swipe has to proceed in order to commence it.
            (0.7 -> if > 0.7 * distance, switch, if less, revert)
          '';
        };

        workspace_swipe_create_new = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether a swipe right on the last workspace should create a new one.";
        };

        workspace_swipe_direction_lock = mkOption {
          type = nullOr bool;
          default = null;
          description = "if enabled, switching direction will be locked when you swipe past the direction_lock_threshold (touchpad only).";
        };

        workspace_swipe_direction_lock_threshold = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "in px, the distance to swipe before direction lock activates (touchpad only).";
        };

        workspace_swipe_forever = mkOption {
          type = nullOr bool;
          default = null;
          description = "if enabled, swiping will not clamp at the neighboring workspaces but continue to the further ones.";
        };

        workspace_swipe_use_r = mkOption {
          type = nullOr bool;
          default = null;
          description = "if enabled, swiping will use the r prefix instead of the m prefix for finding workspaces.";
        };

        close_max_timeout = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "the timeout for a window to close when using a 1:1 gesture, in ms";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          gestures = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
