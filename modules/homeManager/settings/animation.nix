{ lib, hyprlib, ... }:
{
  flake.homeModules.animation =
    { config, ... }:
    let
      inherit (lib) mkOption mapAttrsToList;
      inherit (lib.types)
        str
        bool
        attrsOf
        nullOr
        submodule
        ;

      inherit (lib.types.ints) positive;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred;

      cfg = config.hyprnix.settings.animation;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        (mapAttrsToList mkLuaAnimation)
        (map recursiveMkPreferred)
      ];

      mkLuaAnimation = leaf: args: {
        _args = [ ({ inherit leaf; } // args) ];
      };

      animationType = submodule {
        options = {
          enabled = mkOption {
            type = bool;
            default = true;
            description = "whether the animation is enabled";
          };

          speed = mkOption {
            type = positive;
            description = "amount of ds (1ds = 100ms) the animation will take";
            example = 10;
          };

          bezier = mkOption {
            type = nullOr str;
            default = null;
            description = "bezier curve name";
            example = "linear";
          };

          spring = mkOption {
            type = nullOr str;
            default = null;
            description = "spring curve name";
            example = "rubber";
          };

          style = mkOption {
            type = nullOr str;
            default = null;
            description = "(optional) the animation style";
          };
        };
      };

    in
    {
      options.hyprnix.settings.animation = mkOption {
        type = attrsOf animationType;
        default = { };
        example = {
          fadeIn = {
            bezier = "easeOutCirc";
            speed = 2;
          };
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          animation = cfg';
        };
      };
    };
}
