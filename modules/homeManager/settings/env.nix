{ lib, ... }:
{
  flake.homeModules.env =
    { config, ... }:
    let
      inherit (lib) mkOption mapAttrsToList;

      inherit (lib.types)
        str
        number

        nullOr
        attrsOf
        either
        ;

      cfg = config.hyprnix.settings.env;
      cfg' = mapAttrsToList mkLuaEnv cfg;

      mkLuaEnv = key: value: {
        _args = [
          key
          (toString value)
        ];
      };
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

      config = {
        wayland.windowManager.hyprland.settings = {
          env = cfg';
        };
      };
    };
}
