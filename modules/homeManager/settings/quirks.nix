{ self, lib, ... }:
{
  flake.homeModules.quirks =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        nullOr
        ints
        ;

      inherit (self.lib.hyprnix) filterValidAttrs recursiveMkPreferred;

      cfg = config.hyprnix.settings.quirks;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
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
        wayland.windowManager.hyprland.settings = {
          quirks = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
