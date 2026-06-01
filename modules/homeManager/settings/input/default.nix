{ lib, hyprlib, ... }:
{
  flake.homeModules.input =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        number
        ints
        either
        str
        path
        enum
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.input;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.input = {
        kb_model = mkNullable {
          type = str;
          description = "Appropriate XKB keymap parameter";
        };

        kb_layout = mkNullable {
          type = str;
          description = "Appropriate XKB keymap parameter";
        };

        kb_variant = mkNullable {
          type = str;
          description = "Appropriate XKB keymap parameter";
        };

        kb_options = mkNullable {
          type = str;
          description = "Appropriate XKB keymap parameter";
        };

        kb_rules = mkNullable {
          type = str;
          description = "Appropriate XKB keymap parameter";
        };

        kb_file = mkNullable {
          type = either str path;
          description = "If you prefer, you can use a path to your custom .xkb file.";
        };

        numlock_by_default = mkNullable {
          type = bool;
          description = "Engage numlock by default.";
        };

        resolve_binds_by_sym = mkNullable {
          type = bool;
          description = ''
            Determines how keybinds act when multiple layouts are used.
            If false, keybinds will always act as if the first specified layout is active.
            If true, keybinds specified by symbols are activated when you type the respective symbol with the current layout.
          '';
        };

        repeat_rate = mkNullable {
          type = ints.positive;
          description = "The repeat rate for held-down keys, in repeats per second.";
        };

        repeat_delay = mkNullable {
          type = ints.unsigned;
          description = "Delay before a held-down key is repeated, in milliseconds.";
        };

        sensitivity = mkNullable {
          type = numbers.between (-1) 1;
          description = "Sets the mouse input sensitivity.";
        };

        accel_profile = mkNullable {
          type = enum [
            "adaptive"
            "flat"
            "custom"
          ];
          description = "Sets the cursor acceleration profile. Leave empty to use libinput's default mode for your input device.";
        };

        force_no_accel = mkNullable {
          type = bool;
          description = ''
            Force no cursor acceleration.
            This bypasses most of your pointer settings to get as raw of a signal as possible.
            Enabling this is not recommended due to potential cursor desynchronization.
          '';
        };

        rotation = mkNullable {
          type = ints.between 0 359;
          description = "Sets the rotation of a device in degrees clockwise off the logical neutral position.";
        };

        left_handed = mkNullable {
          type = bool;
          description = "Switches RMB and LMB";
        };

        scroll_points = mkNullable {
          type = str;
          description = ''
            Sets the scroll acceleration profile, when accel_profile is set to custom.
            Has to be in the form <step> <points>. Leave empty to have a flat scroll curve.
          '';
        };

        scroll_method = mkNullable {
          type = enum [
            "2fg"
            "edge"
            "on_button_down"
            "no_scroll"
          ];
          description = "Sets the scroll method.";
        };

        scroll_button = mkNullable {
          type = ints.unsigned;
          description = "Sets the scroll button. Check wev if you have any doubts regarding the ID. 0 means default.";
        };

        scroll_button_lock = mkNullable {
          type = bool;
          description = ''
            If the scroll button lock is enabled, the button does not need to be held down.
            Pressing and releasing the button toggles the button lock, which logically holds the button down or releases it.
            While the button is logically held down, motion events are converted to scroll events.
          '';
        };

        scroll_factor = mkNullable {
          type = number;
          description = "Multiplier added to scroll movement for external mice. Note that there is a separate setting for touchpad scroll_factor.";
        };

        natural_scroll = mkNullable {
          type = bool;
          description = "Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.";
        };

        follow_mouse = mkNullable {
          type = ints.between 0 3;
          description = ''
            Specify if and how cursor movement should affect window focus.
            0 - Cursor movement will not change focus.
            1 - Cursor movement will always change focus to the window under the cursor.
            2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
            3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
          '';
        };

        follow_mouse_threshold = mkNullable {
          type = numbers.unsigned;
          description = "The smallest distance in logical pixels the mouse needs to travel for the window under it to get focused. Works only with follow_mouse = 1.";
        };

        focus_on_close = mkNullable {
          type = ints.between 0 2;
          description = ''
            Controls the window focus behavior when a window is closed.
            When set to 0, focus will shift to the next window candidate.
            When set to 1, focus will shift to the window under the cursor.
            When set to 2, focus will shift to the most recently used/active window.
          '';
        };

        mouse_refocus = mkNullable {
          type = bool;
          description = "If disabled, mouse focus won't switch to the hovered window unless the mouse crosses a window boundary when follow_mouse=1.";
        };

        float_switch_override_focus = mkNullable {
          type = ints.between 1 2;
          description = ''
            If enabled, focus will change to the window under the cursor when changing from tiled-to-floating and vice versa.
            If 2, focus will also follow mouse on float-to-float switches.
          '';
        };

        special_fallthrough = mkNullable {
          type = bool;
          description = "if enabled, having only floating windows in the special workspace will not block focusing windows in the regular workspace.";
        };

        off_window_axis_events = mkNullable {
          type = ints.between 0 3;
          description = ''
            Handles axis events around (gaps/border for tiled, dragarea/border for floated) a focused window.
            0 ignores axis events.
            1 sends out-of-bound coordinates.
            2 fakes pointer coordinates to the closest point inside the window.
            3 warps the cursor to the closest point inside the window.
          '';
        };

        emulate_discrete_scroll = mkNullable {
          type = ints.between 0 2;
          description = ''
            Emulates discrete scrolling from high resolution scrolling events.
            0 disables it.
            1 enables handling of non-standard events only.
            2 force enables all scroll wheel events to be handled.
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          input = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
