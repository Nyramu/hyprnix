{ lib, hyprlib, ... }:
{
  flake.homeModules.misc =
    { config, ... }:
    let
      inherit (lib.types) bool str;
      inherit (lib.types.ints) positive between;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.misc;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        parseColOptions
        recursiveMkPreferred
      ];

      parseColOptions = (
        attrs:
        (removeAttrs attrs [ "col" ])
        // lib.mapAttrs' (n: v: lib.nameValuePair "col.${n}" v) (attrs.col or { })
      );
    in
    {
      options.hyprnix.settings.misc = {
        disable_hyprland_logo = mkNullable {
          type = bool;
          description = "disables the random Hyprland logo / anime girl background.";
        };

        disable_splash_rendering = mkNullable {
          type = bool;
          description = "disables the Hyprland splash rendering. (requires a monitor reload to take effect)";
        };

        disable_scale_notification = mkNullable {
          type = bool;
          description = "disables notification popup when a monitor fails to set a suitable scale";
        };

        col.splash = mkNullable {
          type = str;
          description = "Changes the color of the splash text (requires a monitor reload to take effect).";
        };

        font_family = mkNullable {
          type = str;
          description = "Set the global default font to render the text including debug fps/notification, config error messages and etc., selected from system fonts.";
        };

        splash_font_family = mkNullable {
          type = str;
          description = "Changes the font used to render the splash text, selected from system fonts (requires a monitor reload to take effect).";
        };

        force_default_wallpaper = mkNullable {
          type = (between (-1) 2);
          description = "Enforce any of the 3 default wallpapers. Setting this to 0 or 1 disables the anime background. -1 means “random”.";
        };

        vfr = mkNullable {
          type = bool;
          description = ''
            controls the VFR status of Hyprland.
            Heavily recommended to leave enabled to conserve resources.
          '';
        };

        vrr = mkNullable {
          type = (between 0 3);
          description = ''
            controls the VRR (Adaptive Sync) of your monitors.
            0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type.
          '';
        };

        mouse_move_enables_dpms = mkNullable {
          type = bool;
          description = "If DPMS is set to off, wake up the monitors if the mouse moves.";
        };

        key_press_enables_dpms = mkNullable {
          type = bool;
          description = "If DPMS is set to off, wake up the monitors if a key is pressed.";
        };

        name_vk_after_proc = mkNullable {
          type = bool;
          description = ''
            Name virtual keyboards after the processes that create them.
            E.g. /usr/bin/fcitx5 will have hl-virtual-keyboard-fcitx5.
          '';
        };

        always_follow_on_dnd = mkNullable {
          type = bool;
          description = ''
            Will make mouse focus follow the mouse when drag and dropping.
            Recommended to leave it enabled, especially for people using focus follows mouse at 0.
          '';
        };

        layers_hog_keyboard_focus = mkNullable {
          type = bool;
          description = "If true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)";
        };

        animate_manual_resizes = mkNullable {
          type = bool;
          description = "If true, will animate manual window resizes/moves";
        };

        animate_mouse_windowdragging = mkNullable {
          type = bool;
          description = "If true, will animate windows being dragged by mouse, note that this can cause weird behavior on some curves";
        };

        disable_autoreload = mkNullable {
          type = bool;
          description = ''
            If true, the config will not reload automatically on save,
            and instead needs to be reloaded with hyprctl reload.
            Might save on battery.
          '';
        };

        enable_swallow = mkNullable {
          type = bool;
          description = "Enable window swallowing";
        };

        swallow_regex = mkNullable {
          type = str;
          description = "The class regex to be used for windows that should be swallowed (usually, a terminal).";
        };

        swallow_exception_regex = mkNullable {
          type = str;
          description = ''
            The title regex to be used for windows that should not be swallowed by the windows specified in swallow_regex(e.g. wev).
            The regex is matched against the parent (e.g. Kitty) window's title on the assumption that it changes to whatever process it's running.
          '';
        };

        focus_on_activate = mkNullable {
          type = bool;
          description = "Whether Hyprland should focus an app that requests to be focused (an activate request)";
        };

        mouse_move_focuses_monitor = mkNullable {
          type = bool;
          description = "Whether mouse moving into a different monitor should focus it";
        };

        allow_session_lock_restore = mkNullable {
          type = bool;
          description = "if true, will allow you to restart a lockscreen app in case it crashes";
        };

        session_lock_xray = mkNullable {
          type = bool;
          description = "if true, keep rendering workspaces below your lockscreen";
        };

        background_color = mkNullable {
          type = str;
          description = "change the background color. (requires enabled disable_hyprland_logo)";
        };

        close_special_on_empty = mkNullable {
          type = bool;
          description = "close the special workspace if the last window is removed";
        };

        on_focus_under_fullscreen = mkNullable {
          type = between 0 2;
          description = ''
            if there is a fullscreen or maximized window, decide whether a tiled window requested to focus should replace it, stay behind or disable the fullscreen/maximized state.
            0 - ignore focus request (keep focus on fullscreen window), 1 - takes over, 2 - unfullscreen/unmaximize
          '';
        };

        exit_window_retains_fullscreen = mkNullable {
          type = bool;
          description = "if true, closing a fullscreen window makes the next focused window fullscreen";
        };

        initial_workspace_tracking = mkNullable {
          type = between 0 2;
          description = ''
            if enabled, windows will open on the workspace they were invoked on.
            0 - disabled, 1 - single-shot, 2 - persistent (all children too)
          '';
        };

        middle_click_paste = mkNullable {
          type = bool;
          description = "whether to enable middle-click-paste (aka primary selection)";
        };

        render_unfocused_fps = mkNullable {
          type = positive;
          description = "the maximum limit for render_unfocused windows' fps in the background (see also Window-Rules - render_unfocused)";
        };

        disable_xdg_env_checks = mkNullable {
          type = bool;
          description = "disable the warning if XDG environment is externally managed";
        };

        disable_hyprland_qtutils_check = mkNullable {
          type = bool;
          description = "disable the warning if hyprland-qtutils is not installed";
        };

        lockdead_screen_delay = mkNullable {
          type = between 100 5000;
          description = ''delay after which the "lockdead" screen will appear in case a lockscreen app fails to cover all the outputs (5 seconds max)'';
        };

        enable_anr_dialog = mkNullable {
          type = bool;
          description = "whether to enable the ANR (app not responding) dialog when your apps hang";
        };

        anr_missed_pings = mkNullable {
          type = positive;
          description = "number of missed pings before showing the ANR dialog";
        };

        size_limits_tiled = mkNullable {
          type = bool;
          description = "whether to apply min_size and max_size rules to tiled windows";
        };

        disable_watchdog_warning = mkNullable {
          type = bool;
          description = "whether to disable the warning about not using start-hyprland";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          misc = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
