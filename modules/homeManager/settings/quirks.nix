{ lib, ... }:
{
  flake.homeModules.quirks =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        nullOr
        ints
        ;

      cfg = config.hyprnix.settings.quirks;
    in
    {
      options.hyprnix.settings.quirks = {
        prefer_hdr = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            Report HDR mode as preferred.
            0 - off, 1 - always, 2 - gamescope only
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.quirks = lib.filterAttrs (_: v: v != null) cfg;
      };
    };
}
