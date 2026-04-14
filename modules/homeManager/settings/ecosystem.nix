{ lib, ... }:
{
  flake.homeModules.ecosystem =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        ;

      cfg = config.hyprnix.settings.ecosystem;
      cfg' = lib.filterAttrs (_: v: v != null) cfg;
    in
    {
      options.hyprnix.settings.ecosystem = {
        no_update_news = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable the popup that shows up when you update hyprland to a new version.";
        };

        no_donation_nag = mkOption {
          type = nullOr bool;
          default = null;
          description = "disable the popup that shows up twice a year encouraging to donate.";
        };

        enforce_permissions = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to enable permission control.";
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          # Only write actually set values to avoid noise in the file
          ecosystem = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
