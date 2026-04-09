{ lib, ... }:
{
  flake.homeModules.env =
    { config, ... }:
    let
      inherit (lib)
        mkIf
        mkOption
        mapAttrsToList
        ;
      inherit (lib.types)
        str
        number

        nullOr
        attrsOf
        either
        ;

      cfg = config.hyprnix.settings.env;
    in
    {
      options.hyprnix.settings.env = mkOption {
        type = nullOr (attrsOf (either str number));
        default = null;
        description = "Environment variables to set, as name-value pairs.";
        example = {
          HYPRLAND_TRACE = 1;
          XDG_CURRENT_DESKTOP = "Hyprland";
          QT_QPA_PLATFORM = "wayland;xcb";
        };
      };

      config =
        let
          envMapper = mapAttrsToList (name: value: "${name},${toString value}");
        in
        {
          wayland.windowManager.hyprland.settings.env = mkIf (cfg != null) (envMapper cfg);
        };
    };
}
