{ lib, ... }:
{
  flake.homeModules.debug =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        ints
        ;

      cfg = config.hyprnix.settings.debug;
      cfg' = lib.filterAttrs (_: v: v != null) cfg;
    in
    {
      options.hyprnix.settings.debug = {
        overlay = mkOption {
          type = nullOr bool;
          default = null;
          description = "print the debug performance overlay. Disable VFR for accurate results.";
        };

        damage_blink = mkOption {
          type = nullOr bool;
          default = null;
          description = "(epilepsy warning!) flash areas updated with damage tracking";
        };

        gl_debugging = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables OpenGL debugging with glGetError and EGL_KHR_debug, requires a restart after changing.";
        };

        disable_logs = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable logging to a file";
        };

        disable_time = mkOption {
          type = nullOr bool;
          default = null;
          description = "disables time logging";
        };

        damage_tracking = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            redraw only the needed bits of the display. Do not change.
            0 - none, 1 - monitor, 2 - full (default on Hyprland)
          '';
        };

        enable_stdout_logs = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables logging to stdout";
        };

        manual_crash = mkOption {
          type = nullOr (ints.between 0 1);
          default = null;
          description = "set to 1 and then back to 0 to crash Hyprland.";
        };

        suppress_errors = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, do not display config file parsing errors.";
        };

        watchdog_timeout = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "sets the timeout in seconds for watchdog to abort processing of a signal of the main thread. Set to 0 to disable.";
        };

        disable_scale_checks = mkOption {
          type = nullOr bool;
          default = null;
          description = "disables verification of the scale factors. Will result in pixel alignment and rounding errors.";
        };

        error_limit = mkOption {
          type = nullOr ints.positive;
          default = null;
          description = "limits the number of displayed config file parsing errors.";
        };

        error_position = mkOption {
          type = nullOr (ints.between 0 1);
          default = null;
          description = "sets the position of the error bar. top - 0, bottom - 1";
        };

        colored_stdout_logs = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables colors in the stdout logs.";
        };

        pass = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables render pass debugging.";
        };

        full_cm_proto = mkOption {
          type = nullOr bool;
          default = null;
          description = "claims support for all cm proto features (requires restart)";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          debug = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
