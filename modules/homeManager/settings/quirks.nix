{ lib, hyprlib, ... }:
{
  flake.homeModules.quirks =
    { config, ... }:
    let
      inherit (lib.types) ints;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.quirks;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.quirks = {
        prefer_hdr = mkNullable {
          type = ints.between 0 2;
          description = ''
            Report HDR mode as preferred.
            0 - off, 1 - always, 2 - gamescope only
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          quirks = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
