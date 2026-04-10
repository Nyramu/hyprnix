{ lib, ... }:
{
  flake.homeModules.input =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        number
        int
        either
        str
        path
        nullOr
        enum
        addCheck
        ;
      inherit (lib.types.ints)
        between
        positive
        unsigned
        ;

      cfg = config.hyprnix.settings.input;
    in
    {
      options.hyprnix.settings.input = {
        kb_model = mkOption {
          type = nullOr str;
          default = null;
          description = "Appropriate XKB keymap parameter";
        };

        kb_layout = mkOption {
          type = nullOr str;
          default = null;
          description = "Appropriate XKB keymap parameter";
        };

        kb_variant = mkOption {
          type = nullOr str;
          default = null;
          description = "Appropriate XKB keymap parameter";
        };

        kb_options = mkOption {
          type = nullOr str;
          default = null;
          description = "Appropriate XKB keymap parameter";
        };

        kb_rules = mkOption {
          type = nullOr str;
          default = null;
          description = "Appropriate XKB keymap parameter";
        };

        kb_file = mkOption {
          type = nullOr (either str path);
          default = null;
          description = "If you prefer, you can use a path to your custom .xkb file.";
        };

        numlock_by_default = mkOption {
          type = nullOr bool;
          default = null;
          description = "Engage numlock by default.";
        };

        resolve_binds_by_sym = mkOption {
          type = nullOr bool;
          default = null;
          description = "Determines how keybinds act when multiple layouts are used. If false, keybinds will always act as if the first specified layout is active. If true, keybinds specified by symbols are activated when you type the respective symbol with the current layout.";
        };

        repeat_rate = mkOption {
          type = nullOr positive;
          default = null;
          description = "The repeat rate for held-down keys, in repeats per second.";
        };

        repeat_delay = mkOption {
          type = nullOr (addCheck int (x: x >= 100));
          default = null;
          description = "Delay before a held-down key is repeated, in milliseconds.";
        };

        sensitivity = mkOption {
          type = nullOr (addCheck number (x: x >= (-1) && x <= 1));
          default = null;
          description = "Sets the mouse input sensitivity. Value is clamped to the range -1.0 to 1.0.";
        };

        accel_profile = mkOption {
          type = nullOr (enum [
            "adaptive"
            "flat"
            "custom"
          ]);
          default = null;
          description = "Sets the cursor acceleration profile. Can be one of adaptive, flat. Can also be custom, see below. Leave empty to use libinput’s default mode for your input device.";
        };

        force_no_accel = mkOption {
          type = nullOr bool;
          default = null;
          description = "Force no cursor acceleration. This bypasses most of your pointer settings to get as raw of a signal as possible. Enabling this is not recommended due to potential cursor desynchronization.";
        };

        rotation = mkOption {
          type = nullOr (between 0 359);
          default = null;
          description = "Sets the rotation of a device in degrees clockwise off the logical neutral position. Value is clamped to the range 0 to 359.";
        };

        left_handed = mkOption {
          type = nullOr bool;
          default = null;
          description = "Switches RMB and LMB";
        };

        scroll_points = mkOption {
          type = nullOr str;
          default = null;
          description = "Sets the scroll acceleration profile, when accel_profile is set to custom. Has to be in the form <step> <points>. Leave empty to have a flat scroll curve.";
        };

        scroll_method = mkOption {
          type = nullOr (enum [
            "2fg"
            "edge"
            "on_button_down"
            "no_scroll"
          ]);
          default = null;
          description = "Sets the scroll method. Can be one of 2fg (2 fingers), edge, on_button_down, no_scroll.";
        };

        scroll_button = mkOption {
          type = nullOr unsigned;
          default = null;
          description = "Sets the scroll button. Has to be an int, cannot be a string. Check wev if you have any doubts regarding the ID. 0 means default.";
        };

        scroll_button_lock = mkOption {
          type = nullOr bool;
          default = null;
          description = "If the scroll button lock is enabled, the button does not need to be held down. Pressing and releasing the button toggles the button lock, which logically holds the button down or releases it. While the button is logically held down, motion events are converted to scroll events.";
        };

        scroll_factor = mkOption {
          type = nullOr (addCheck number (x: x >= 0.1));
          default = null;
          description = "Multiplier added to scroll movement for external mice. Note that there is a separate setting for touchpad scroll_factor.";
        };

        natural_scroll = mkOption {
          type = nullOr bool;
          default = null;
          description = "Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.";
        };

        follow_mouse = mkOption {
          type = nullOr (between 0 3);
          default = null;
          description = "Specify if and how cursor movement should affect window focus. See the note below. [0/1/2/3]";
        };

        follow_mouse_threshold = mkOption {
          type = nullOr (addCheck number (x: x >= 0));
          default = null;
          description = "The smallest distance in logical pixels the mouse needs to travel for the window under it to get focused. Works only with follow_mouse = 1.";
        };

        focus_on_close = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = "Controls the window focus behavior when a window is closed. When set to 0, focus will shift to the next window candidate. When set to 1, focus will shift to the window under the cursor. When set to 2, focus will shift to the most recently used/active window. [0/1/2]";
        };

        mouse_refocus = mkOption {
          type = nullOr bool;
          default = null;
          description = "If disabled, mouse focus won’t switch to the hovered window unless the mouse crosses a window boundary when follow_mouse=1.";
        };

        float_switch_override_focus = mkOption {
          type = nullOr (between 1 2);
          default = null;
          description = "If enabled (1 or 2), focus will change to the window under the cursor when changing from tiled-to-floating and vice versa. If 2, focus will also follow mouse on float-to-float switches.";
        };

        special_fallthrough = mkOption {
          type = nullOr bool;
          default = null;
          description = "if enabled, having only floating windows in the special workspace will not block focusing windows in the regular workspace.";
        };

        off_window_axis_events = mkOption {
          type = nullOr (between 0 3);
          default = null;
          description = "Handles axis events around (gaps/border for tiled, dragarea/border for floated) a focused window. 0 ignores axis events 1 sends out-of-bound coordinates 2 fakes pointer coordinates to the closest point inside the window 3 warps the cursor to the closest point inside the window";
        };

        emulate_discrete_scroll = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = "Emulates discrete scrolling from high resolution scrolling events. 0 disables it, 1 enables handling of non-standard events only, and 2 force enables all scroll wheel events to be handled";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.input = lib.filterAttrsRecursive (_: v: v != null) cfg;
      };
    };
}
