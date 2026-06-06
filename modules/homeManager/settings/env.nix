{ lib, ... }:
{
  flake.homeModules.env =
    { config, ... }:
    let
      inherit (lib) mapAttrsToList;
      inherit (lib.types)
        str
        number
        attrsOf
        either
        ;

      inherit (lib) mkOption;

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
        type = attrsOf (either str number);
        default = { };
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
