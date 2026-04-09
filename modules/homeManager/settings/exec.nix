{ lib, ... }:
{
  flake.homeModules.exec =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types) str listOf;

      cfg = config.hyprnix.settings;
    in
    {
      options.hyprnix.settings = {
        exec = mkOption {
          type = listOf str;
          default = [ ];
          description = "Shell scripts that will execute on each reload";
        };

        execr = mkOption {
          type = listOf str;
          default = [ ];
          description = "Raw shell scripts that will execute on each reload";
        };

        exec-once = mkOption {
          type = listOf str;
          default = [ ];
          description = "Shell scripts that will execute only on launch";
        };

        execr-once = mkOption {
          type = listOf str;
          default = [ ];
          description = "Raw shell scripts that will execute only on launch";
        };

        exec-shutdown = mkOption {
          type = listOf str;
          default = [ ];
          description = "Shell scripts that will execute only on shutdown";
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          exec = cfg.exec;
          execr = cfg.execr;
          exec-once = cfg.exec-once;
          execr-once = cfg.execr-once;
          exec-shutdown = cfg.exec-shutdown;
        };
      };
    };
}
