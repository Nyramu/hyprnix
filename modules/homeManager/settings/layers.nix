{ lib, hyprlib, ... }:
{
  flake.homeModules.layers =
    { config, ... }:
    let
      inherit (lib.types) bool;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.layers;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.layers = {
        layers_hog_keyboard_focus = mkNullable {
          type = bool;
          description = "If true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)";
        };

        allow_new_top_layers_over_existing_fullscreen = mkNullable {
          type = bool;
          description = "If false, newly mapped layers are not allowed to render over an existing covering fullscreen window.";
        };
      };

      config = {
        wayland.windowManager.hyprland.settings.config = {
          # Only write actually set values to avoid noise in the file
          layers = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
