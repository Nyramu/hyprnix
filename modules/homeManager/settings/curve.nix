{ lib, hyprlib, ... }:
{
  flake.homeModules.curve =
    { config, ... }:
    let
      inherit (lib)
        mkOption
        mapAttrsToList
        take
        drop
        ;
      inherit (lib.types) number attrsOf submodule;

      inherit (hyprlib.utils) recursiveMkPreferred;
      inherit (hyprlib.types) tuple;

      cfg = config.hyprnix.settings.curve;
      cfg' = map recursiveMkPreferred (mapBeziers cfg.bezier ++ mapSprings cfg.spring);

      mapBeziers =
        beziers:
        mapAttrsToList (name: points: {
          _args = [
            name
            {
              type = "bezier";
              points = [
                (take 2 points)
                (drop 2 points)
              ];
            }
          ];
        }) beziers;

      mapSprings =
        springs:
        mapAttrsToList (name: args: {
          _args = [
            name
            ({ type = "spring"; } // args)
          ];
        }) springs;

      springType = submodule {
        options = {
          mass = mkOption { type = number; };
          stiffness = mkOption { type = number; };
          dampening = mkOption { type = number; };
        };
      };
    in
    {
      options.hyprnix.settings.curve = {
        bezier = mkOption {
          type = attrsOf (tuple number 4);
          default = { };
          example = {
            linear = [
              0
              0
              1
              1
            ];
          };
        };

        spring = mkOption {
          type = attrsOf springType;
          default = { };
          example = {
            rubber = {
              mass = 1;
              stiffness = 70;
              dampening = 10;
            };
          };
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          curve = cfg';
        };
      };
    };
}
