{ lib, hyprlib, ... }:
{
  flake.homeModules.opengl =
    { config, ... }:
    let
      inherit (lib.types) bool;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.opengl;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.opengl = {
        nvidia_anti_flicker = mkNullable {
          type = bool;
          description = "reduces flickering on nvidia at the cost of possible frame drops on lower-end GPUs. On non-nvidia, this is ignored.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          opengl = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
