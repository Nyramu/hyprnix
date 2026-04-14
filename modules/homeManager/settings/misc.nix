{ lib, ... }:
{
  flake.homeModules.misc =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        nullOr
        ;
      inherit (lib.types.ints)
        positive
        between
        ;

      cfg = config.hyprnix.settings.misc;
      cfg' = lib.pipe cfg [
        (lib.filterAttrsRecursive (_: v: v != null))
        (lib.filterAttrsRecursive (_: v: v != { }))
      ];
    in
    {
      options.hyprnix.settings.misc = {
        disable_hyprland_logo = mkOption {
          type = nullOr bool;
          default = null;
          description = "disables the random Hyprland logo / anime girl background.";
        };

        disable_splash_rendering = mkOption {
          type = nullOr bool;
          default = null;
          description = "disables the Hyprland splash rendering. (requires a monitor reload to take effect)";
        };

        disable_scale_notification = mkOption {
          type = nullOr bool;
          default = null;
          description = "disables notification popup when a monitor fails to set a suitable scale";
        };

        col.splash = mkOption {
          type = nullOr str;
          default = null;
          description = "Changes the color of the splash text (requires a monitor reload to take effect).";
        };

        font_family = mkOption {
          type = nullOr str;
          default = null;
          description = "Set the global default font to render the text including debug fps/notification, config error messages and etc., selected from system fonts.";
        };

        splash_font_family = mkOption {
          type = nullOr str;
          default = null;
          description = "Changes the font used to render the splash text, selected from system fonts (requires a monitor reload to take effect).";
        };

        force_default_wallpaper = mkOption {
          type = nullOr (between (-1) 2);
          default = null;
          description = "Enforce any of the 3 default wallpapers. Setting this to 0 or 1 disables the anime background. -1 means “random”.";
        };

        vfr = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            controls the VFR status of Hyprland.
            Heavily recommended to leave enabled to conserve resources.
          '';
        };

        vrr = mkOption {
          type = nullOr (between 0 3);
          default = null;
          description = ''
            controls the VRR (Adaptive Sync) of your monitors.
            0 - off, 1 - on, 2 - fullscreen only, 3 - fullscreen with video or game content type.
          '';
        };

        mouse_move_enables_dpms = mkOption {
          type = nullOr bool;
          default = null;
          description = "If DPMS is set to off, wake up the monitors if the mouse moves.";
        };

        key_press_enables_dpms = mkOption {
          type = nullOr bool;
          default = null;
          description = "If DPMS is set to off, wake up the monitors if a key is pressed.";
        };

        name_vk_after_proc = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            Name virtual keyboards after the processes that create them.
            E.g. /usr/bin/fcitx5 will have hl-virtual-keyboard-fcitx5.
          '';
        };

        always_follow_on_dnd = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            Will make mouse focus follow the mouse when drag and dropping.
            Recommended to leave it enabled, especially for people using focus follows mouse at 0.
          '';
        };

        layers_hog_keyboard_focus = mkOption {
          type = nullOr bool;
          default = null;
          description = "If true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)";
        };

        animate_manual_resizes = mkOption {
          type = nullOr bool;
          default = null;
          description = "If true, will animate manual window resizes/moves";
        };

        animate_mouse_windowdragging = mkOption {
          type = nullOr bool;
          default = null;
          description = "If true, will animate windows being dragged by mouse, note that this can cause weird behavior on some curves";
        };

        disable_autoreload = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            If true, the config will not reload automatically on save,
            and instead needs to be reloaded with hyprctl reload.
            Might save on battery.
          '';
        };

        enable_swallow = mkOption {
          type = nullOr bool;
          default = null;
          description = "Enable window swallowing";
        };

        swallow_regex = mkOption {
          type = nullOr str;
          default = null;
          description = "The class regex to be used for windows that should be swallowed (usually, a terminal).";
        };

        swallow_exception_regex = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            The title regex to be used for windows that should not be swallowed by the windows specified in swallow_regex(e.g. wev).
            The regex is matched against the parent (e.g. Kitty) window’s title on the assumption that it changes to whatever process it’s running.
          '';
        };

        focus_on_activate = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether Hyprland should focus an app that requests to be focused (an activate request)";
        };

        mouse_move_focuses_monitor = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether mouse moving into a different monitor should focus it";
        };

        allow_session_lock_restore = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, will allow you to restart a lockscreen app in case it crashes";
        };

        session_lock_xray = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, keep rendering workspaces below your lockscreen";
        };

        background_color = mkOption {
          type = nullOr str;
          default = null;
          description = "change the background color. (requires enabled disable_hyprland_logo)";
        };

        close_special_on_empty = mkOption {
          type = nullOr bool;
          default = null;
          description = "close the special workspace if the last window is removed";
        };

        on_focus_under_fullscreen = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = ''
            if there is a fullscreen or maximized window, decide whether a tiled window requested to focus should replace it, stay behind or disable the fullscreen/maximized state.
            0 - ignore focus request (keep focus on fullscreen window), 1 - takes over, 2 - unfullscreen/unmaximize
          '';
        };

        exit_window_retains_fullscreen = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, closing a fullscreen window makes the next focused window fullscreen";
        };

        initial_workspace_tracking = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = ''
            if enabled, windows will open on the workspace they were invoked on.
            0 - disabled, 1 - single-shot, 2 - persistent (all children too)
          '';
        };

        middle_click_paste = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to enable middle-click-paste (aka primary selection)";
        };

        render_unfocused_fps = mkOption {
          type = nullOr positive;
          default = null;
          description = "the maximum limit for render_unfocused windows’ fps in the background (see also Window-Rules - render_unfocused)";
        };

        disable_xdg_env_checks = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable the warning if XDG environment is externally managed";
        };

        disable_hyprland_qtutils_check = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable the warning if hyprland-qtutils is not installed";
        };

        lockdead_screen_delay = mkOption {
          type = nullOr (between 100 5000);
          default = null;
          description = "delay after which the \"lockdead\" screen will appear in case a lockscreen app fails to cover all the outputs (5 seconds max)";
        };

        enable_anr_dialog = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to enable the ANR (app not responding) dialog when your apps hang";
        };

        anr_missed_pings = mkOption {
          type = nullOr positive;
          default = null;
          description = "number of missed pings before showing the ANR dialog";
        };

        size_limits_tiled = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to apply min_size and max_size rules to tiled windows";
        };

        disable_watchdog_warning = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to disable the warning about not using start-hyprland";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          misc = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
