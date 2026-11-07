{ lib, hyprlib, ... }:
{
  flake.homeModules.animation =
    { config, ... }:
    let
      inherit (lib) mapAttrsToList mkOption;
      inherit (lib.types)
        str
        bool
        attrsOf
        submodule
        ;
      inherit (lib.types.ints) positive;

      inherit (hyprlib.utils) filterValidAttrs mkNullable;
      inherit (hyprlib.lua) renderSection;

      cfg = config.hyprnix.settings.animation;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        (mapAttrsToList mkLuaAnimation)
      ];

      mkLuaAnimation = leaf: args: { _args = [ ({ inherit leaf; } // args) ]; };

      animationType = submodule {
        options = {
          enabled = mkOption {
            type = bool;
            default = true;
            description = "whether the animation is enabled";
          };

          speed = mkNullable {
            type = positive;
            description = "amount of ds (1ds = 100ms) the animation will take";
            example = 10;
          };

          bezier = mkNullable {
            type = str;
            description = "bezier curve name";
            example = "linear";
          };

          spring = mkNullable {
            type = str;
            description = "spring curve name";
            example = "rubber";
          };

          style = mkNullable {
            type = str;
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
        wayland.windowManager.hyprland.extraLuaFiles = lib.mkIf (cfg' != [ ]) {
          "animations" = {
            content = lib.mkAfter (renderSection "animation" cfg');
          };
        };
      };
    };
}
