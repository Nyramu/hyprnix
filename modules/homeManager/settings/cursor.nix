{ lib, hyprlib, ... }:
{
  flake.homeModules.cursor =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        str
        package
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.cursor;

      cfg' = lib.pipe cfg [
        extractEnableHyprcursor
        (lib.filterAttrsRecursive (k: _: k != "hyprcursor"))
        filterValidAttrs
        recursiveMkPreferred
      ];

      extractEnableHyprcursor = (
        cfg:
        cfg
        // lib.optionalAttrs (cfg.hyprcursor.enable != null) {
          enable_hyprcursor = cfg.hyprcursor.enable;
        }
      );
    in
    {
      options.hyprnix.settings.cursor = {
        invisible = mkNullable {
          type = bool;
          description = "don't render cursors";
        };

        sync_gsettings_theme = mkNullable {
          type = bool;
          description = "sync xcursor theme with gsettings, it applies cursor-theme and cursor-size on theme load to gsettings making most CSD gtk based clients use same xcursor theme and size.";
        };

        no_hardware_cursors = mkNullable {
          type = ints.between 0 2;
          description = ''
            disables hardware cursors.
            0 - use hw cursors if possible,
            1 - don’t use hw cursors,
            2 - auto (disable when tearing)
          '';
        };

        no_break_fs_vrr = mkNullable {
          type = ints.between 0 2;
          description = ''
            disables scheduling new frames on cursor movement for fullscreen apps with VRR enabled to avoid framerate spikes
            (may require no_hardware_cursors = 1)
            0 - off, 1 - on, 2 - auto (on with content type ‘game’)
          '';
        };

        min_refresh_rate = mkNullable {
          type = ints.unsigned;
          description = ''
            minimum refresh rate for cursor movement when no_break_fs_vrr = 1
            Set to minimum supported refresh rate or higher
          '';
        };

        hotspot_padding = mkNullable {
          type = ints.unsigned;
          description = "the padding, in logical px, between screen edges and the cursor";
        };

        inactive_timeout = mkNullable {
          type = numbers.unsigned;
          description = "in seconds, after how many seconds of cursor’s inactivity to hide it. Set to 0 for never.";
        };

        no_warps = mkNullable {
          type = bool;
          description = "if true, will not warp the cursor in many cases (focusing, keybinds, etc)";
        };

        persistent_warps = mkNullable {
          type = bool;
          description = "When a window is refocused, the cursor returns to its last position relative to that window, rather than to the centre.";
        };

        warp_on_change_workspace = mkNullable {
          type = ints.between 0 2;
          description = ''
            Move the cursor to the last focused window after changing the workspace.
            Options:
            0 (Disabled), 1 (Enabled),
            2 (Force - ignores cursor.no_warps option)
          '';
        };

        warp_on_toggle_special = mkNullable {
          type = ints.between 0 2;
          description = ''
            Move the cursor to the last focused window when toggling a special workspace.
            Options:
            0 (Disabled), 1 (Enabled),
            2 (Force - ignores cursor.no_warps option)
          '';
        };

        default_monitor = mkNullable {
          type = str;
          description = "the name of a default monitor for the cursor to be set to on startup (see hyprctl monitors for names)";
        };

        zoom_factor = mkNullable {
          type = numbers.positive;
          description = "the factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)";
        };

        zoom_rigid = mkNullable {
          type = bool;
          description = "whether the zoom should follow the cursor rigidly (cursor is always centered if it can be) or loosely";
        };

        zoom_detached_camera = mkNullable {
          type = bool;
          description = "detach the camera from the mouse when zoomed in, only ever moving the camera to keep the mouse in view when it goes past the screen edges";
        };

        hide_on_key_press = mkNullable {
          type = bool;
          description = "Hides the cursor when you press any key until the mouse is moved.";
        };

        hide_on_touch = mkNullable {
          type = bool;
          description = "Hides the cursor when the last input was a touch input until a mouse input is done.";
        };

        hide_on_tablet = mkNullable {
          type = bool;
          description = "Hides the cursor when the last input was a tablet input until a mouse input is done.";
        };

        use_cpu_buffer = mkNullable {
          type = ints.between 0 2;
          description = ''
            (NVIDIA Only)
            Makes HW cursors use a CPU buffer. Required on NVIDIA to have HW cursors.
            0 - off, 1 - on, 2 - auto
          '';
        };

        warp_back_after_non_mouse_input = mkNullable {
          type = bool;
          description = "Warp the cursor back to where it was after using a non-mouse input to move it, and then returning back to mouse.";
        };

        zoom_disable_aa = mkNullable {
          type = bool;
          description = "disable antialiasing when zooming, which means things will be pixelated instead of blurry";
        };

        hyprcursor = {
          enable = mkNullable {
            type = bool;
            description = "whether to enable hyprcursor support";
          };

          package = mkNullable {
            type = package;
            description = "set cursor's package to install";
          };

          name = mkNullable {
            type = str;
            description = "set cursor's name. Requires Hyprland restart.";
          };

          size = mkNullable {
            type = ints.positive;
            description = "set cursor's size. Requires Hyprland restart.";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          cursor = lib.mkIf (cfg' != { }) cfg';
        };

        # Set the hyprcursor
        hyprnix.settings.env = lib.mkIf (cfg.hyprcursor.enable == true) (
          lib.filterAttrs (_: v: v != null) {
            HYPRCURSOR_THEME = cfg.hyprcursor.name;
            HYPRCURSOR_SIZE = cfg.hyprcursor.size;
          }
        );

        home.packages = lib.mkIf (cfg.hyprcursor.enable == true && cfg.hyprcursor.package != null) [
          cfg.hyprcursor.package
        ];
      };
    };
}
