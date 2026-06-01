{ lib, hyprlib, ... }:
{
  flake.homeModules.ecosystem =
    { config, ... }:
    let
      inherit (lib.types) bool;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.ecosystem;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.ecosystem = {
        no_update_news = mkNullable {
          type = bool;
          description = "disable the popup that shows up when you update hyprland to a new version.";
        };

        no_donation_nag = mkNullable {
          type = bool;
          description = "disable the popup that shows up twice a year encouraging to donate.";
        };

        enforce_permissions = mkNullable {
          type = bool;
          description = "whether to enable permission control.";
        };
      };

      config = {
        wayland.windowManager.hyprland.settings.config = {
          # Only write actually set values to avoid noise in the file
          ecosystem = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
