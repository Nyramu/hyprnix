{ self, lib, ... }:
{
  flake.homeModules.cursor =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        nullOr
        package
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.cursor;

      cfg' = (
        cfg
        // lib.optionalAttrs (cfg.hyprcursor.enable != null) {
          enable_hyprcursor = cfg.hyprcursor.enable;
        }
      );
    in
    {
      options.hyprnix.settings.cursor = {
        invisible = mkOption {
          type = nullOr bool;
          default = null;
          description = "don't render cursors";
        };

        sync_gsettings_theme = mkOption {
          type = nullOr bool;
          default = null;
          description = "sync xcursor theme with gsettings, it applies cursor-theme and cursor-size on theme load to gsettings making most CSD gtk based clients use same xcursor theme and size.";
        };

        no_hardware_cursors = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            disables hardware cursors.
            0 - use hw cursors if possible,
            1 - don’t use hw cursors,
            2 - auto (disable when tearing)
          '';
        };

        no_break_fs_vrr = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            disables scheduling new frames on cursor movement for fullscreen apps with VRR enabled to avoid framerate spikes
            (may require no_hardware_cursors = 1)
            0 - off, 1 - on, 2 - auto (on with content type ‘game’)
          '';
        };

        min_refresh_rate = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = ''
            minimum refresh rate for cursor movement when no_break_fs_vrr = 1
            Set to minimum supported refresh rate or higher
          '';
        };

        hotspot_padding = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "the padding, in logical px, between screen edges and the cursor";
        };

        inactive_timeout = mkOption {
          type = nullOr numbers.unsigned;
          default = null;
          description = "in seconds, after how many seconds of cursor’s inactivity to hide it. Set to 0 for never.";
        };

        no_warps = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, will not warp the cursor in many cases (focusing, keybinds, etc)";
        };

        persistent_warps = mkOption {
          type = nullOr bool;
          default = null;
          description = "When a window is refocused, the cursor returns to its last position relative to that window, rather than to the centre.";
        };

        warp_on_change_workspace = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            Move the cursor to the last focused window after changing the workspace.
            Options:
            0 (Disabled), 1 (Enabled),
            2 (Force - ignores cursor.no_warps option)
          '';
        };

        warp_on_toggle_special = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            Move the cursor to the last focused window when toggling a special workspace.
            Options:
            0 (Disabled), 1 (Enabled),
            2 (Force - ignores cursor.no_warps option)
          '';
        };

        default_monitor = mkOption {
          type = nullOr str;
          default = null;
          description = "the name of a default monitor for the cursor to be set to on startup (see hyprctl monitors for names)";
        };

        zoom_factor = mkOption {
          type = nullOr numbers.positive;
          default = null;
          description = "the factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)";
        };

        zoom_rigid = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether the zoom should follow the cursor rigidly (cursor is always centered if it can be) or loosely";
        };

        zoom_detached_camera = mkOption {
          type = nullOr bool;
          default = null;
          description = "detach the camera from the mouse when zoomed in, only ever moving the camera to keep the mouse in view when it goes past the screen edges";
        };

        hide_on_key_press = mkOption {
          type = nullOr bool;
          default = null;
          description = "Hides the cursor when you press any key until the mouse is moved.";
        };

        hide_on_touch = mkOption {
          type = nullOr bool;
          default = null;
          description = "Hides the cursor when the last input was a touch input until a mouse input is done.";
        };

        hide_on_tablet = mkOption {
          type = nullOr bool;
          default = null;
          description = "Hides the cursor when the last input was a tablet input until a mouse input is done.";
        };

        use_cpu_buffer = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            (NVIDIA Only)
            Makes HW cursors use a CPU buffer. Required on NVIDIA to have HW cursors.
            0 - off, 1 - on, 2 - auto
          '';
        };

        warp_back_after_non_mouse_input = mkOption {
          type = nullOr bool;
          default = null;
          description = "Warp the cursor back to where it was after using a non-mouse input to move it, and then returning back to mouse.";
        };

        zoom_disable_aa = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable antialiasing when zooming, which means things will be pixelated instead of blurry";
        };

        hyprcursor = {
          enable = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to enable hyprcursor support";
          };

          package = mkOption {
            type = nullOr package;
            default = null;
            description = "set hyprcursor package to install";
          };

          name = mkOption {
            type = nullOr str;
            default = null;
            description = "set hyprcursor's name. Requires Hyprland restart.";
          };

          size = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "set hyprcursor's size. Requires Hyprland restart.";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          cursor = lib.filterAttrs (k: v: k != "hyprcursor" && v != null) cfg';
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
