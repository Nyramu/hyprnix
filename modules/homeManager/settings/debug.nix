{ lib, hyprlib, ... }:
{
  flake.homeModules.debug =
    { config, ... }:
    let
      inherit (lib.types) bool ints;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.debug;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.debug = {
        overlay = mkNullable {
          type = bool;
          description = "print the debug performance overlay. Disable VFR for accurate results.";
        };

        damage_blink = mkNullable {
          type = bool;
          description = "(epilepsy warning!) flash areas updated with damage tracking";
        };

        gl_debugging = mkNullable {
          type = bool;
          description = "enables OpenGL debugging with glGetError and EGL_KHR_debug, requires a restart after changing.";
        };

        vfr = mkNullable {
          type = bool;
          description = "controls the VFR status of Hyprland. Heavily recommended to leave enabled to conserve resources.";
        };

        disable_logs = mkNullable {
          type = bool;
          description = "disable logging to a file";
        };

        disable_time = mkNullable {
          type = bool;
          description = "disables time logging";
        };

        damage_tracking = mkNullable {
          type = ints.between 0 2;
          description = ''
            redraw only the needed bits of the display. Do not change.
            0 - none, 1 - monitor, 2 - full (default on Hyprland)
          '';
        };

        enable_stdout_logs = mkNullable {
          type = bool;
          description = "enables logging to stdout";
        };

        manual_crash = mkNullable {
          type = ints.between 0 1;
          description = "set to 1 and then back to 0 to crash Hyprland.";
        };

        suppress_errors = mkNullable {
          type = bool;
          description = "if true, do not display config file parsing errors.";
        };

        watchdog_timeout = mkNullable {
          type = ints.unsigned;
          description = "sets the timeout in seconds for watchdog to abort processing of a signal of the main thread. Set to 0 to disable.";
        };

        disable_scale_checks = mkNullable {
          type = bool;
          description = "disables verification of the scale factors. Will result in pixel alignment and rounding errors.";
        };

        error_limit = mkNullable {
          type = ints.positive;
          description = "limits the number of displayed config file parsing errors.";
        };

        error_position = mkNullable {
          type = ints.between 0 1;
          description = "sets the position of the error bar. top - 0, bottom - 1";
        };

        colored_stdout_logs = mkNullable {
          type = bool;
          description = "enables colors in the stdout logs.";
        };

        pass = mkNullable {
          type = bool;
          description = "enables render pass debugging.";
        };

        full_cm_proto = mkNullable {
          type = bool;
          description = "claims support for all cm proto features (requires restart)";
        };

        invalidate_fp16 = mkNullable {
          type = ints.between 0 2;
          description = ''
            Allow fp16 buffer invalidation (invalidation increases performance but produces glitches on some systems).
            0 - not allowed, 1 - allowed, 2 - not allowed on nvidia
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          debug = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
