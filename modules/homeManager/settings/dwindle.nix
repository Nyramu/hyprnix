{ lib, hyprlib, ... }:
{
  flake.homeModules.dwindle =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        number
        enum
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.dwindle;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.dwindle = {
        force_split = mkNullable {
          type = ints.between 0 2;
          description = ''
            0 -> split follows mouse
            1 -> always split to the left (new = left or top)
            2 -> always split to the right (new = right or bottom)
          '';
        };

        preserve_split = mkNullable {
          type = bool;
          description = "If enabled, the split (side/top) will not change regardless of what happens to the container.";
        };

        smart_split = mkNullable {
          type = bool;
          description = ''
            If enabled, allows a more precise control over the window split direction based on the cursor’s position.
            The window is conceptually divided into four triangles, and cursor’s triangle determines the split direction.
            This feature also turns on preserve_split.
          '';
        };

        smart_resizing = mkNullable {
          type = bool;
          description = ''
            If enabled, resizing direction will be determined by the mouse’s position on the window (nearest to which corner).
            Else, it is based on the window’s tiling position.
          '';
        };

        permanent_direction_override = mkNullable {
          type = bool;
          description = ''
            If enabled, makes the preselect direction persist until either this mode is turned off,
            another direction is specified, or a non-direction is specified (anything other than l,r,u/t,d/b)
          '';
        };

        special_scale_factor = mkNullable {
          type = numbers.between 0 1;
          description = "Specifies the scale factor of windows on the special workspace";
        };

        split_width_multiplier = mkNullable {
          type = number;
          description = ''
            Specifies the auto-split width multiplier.
            Multiplying window size is useful on widescreen monitors where window W > H even after several splits.
          '';
        };

        use_active_for_splits = mkNullable {
          type = bool;
          description = "Prefer the active window or the mouse position for splits";
        };

        default_split_ratio = mkNullable {
          type = numbers.between 0.1 1.9;
          description = "The default split ratio on window open. 1 means even 50/50 split.";
        };

        split_bias = mkNullable {
          type = enum [
            0
            1
          ];
          description = ''
            Specifies which window will receive the split ratio.
             0 -> directional (the top or left window)
             1 -> the current window
          '';
        };

        precise_mouse_move = mkNullable {
          type = bool;
          description = "If enabled bindm movewindow will drop the window more precisely depending on where your mouse is.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          dwindle = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
