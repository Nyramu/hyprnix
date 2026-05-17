{ lib, hyprlib, ... }:
{
  flake.homeModules.xwayland =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred;

      cfg = config.hyprnix.settings.xwayland;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.xwayland = {
        enabled = lib.mkEnableOption "allow running applications using X11";

        use_nearest_neighbor = mkOption {
          type = nullOr bool;
          default = null;
          description = "uses the nearest neighbor filtering for xwayland apps, making them pixelated rather than blurry";
        };

        force_zero_scaling = mkOption {
          type = nullOr bool;
          default = null;
          description = "forces a scale of 1 on xwayland windows on scaled displays.";
        };

        create_abstract_socket = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            Create the abstract Unix domain socket for XWayland connections.
            XWayland restart is required for changes to take effect.
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          xwayland = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
