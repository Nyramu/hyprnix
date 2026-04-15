{ self, lib, ... }:
{
  flake.homeModules.opengl =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        ;
      inherit (self.lib.hyprnix.types) filterValidAttrs;

      cfg = config.hyprnix.settings.opengl;
      cfg' = filterValidAttrs cfg;
    in
    {
      options.hyprnix.settings.opengl = {
        nvidia_anti_flicker = mkOption {
          type = nullOr bool;
          default = null;
          description = "reduces flickering on nvidia at the cost of possible frame drops on lower-end GPUs. On non-nvidia, this is ignored.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          opengl = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
