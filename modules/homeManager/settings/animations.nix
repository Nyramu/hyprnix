{ lib, ... }:
{
  flake.homeModules.animations =
    { config, ... }:
    let
      inherit (lib) mkIf mkOption optionalString;
      inherit (lib.types)
        number
        str
        bool

        listOf
        nullOr
        submodule
        addCheck
        ;

      inherit (lib.types.ints) positive;

      cfg = config.hyprnix.settings.animations;

      bezierType = submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Name of your choice for the curve";
            example = "linear";
          };
          points = mkOption {
            type = addCheck (listOf number) (l: builtins.length l == 4);
            description = "Control points [x0 y0 x1 y1]";
            example = [
              0.0
              0.0
              1.0
              1.0
            ];
          };
        };
      };

      animationType = submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Name of the animation";
            example = "workspacesIn";
          };

          speed = mkOption {
            type = positive;
            description = "Amount of ds (1ds = 100ms) the animation will take";
            example = 10;
          };

          curve = mkOption {
            type = str;
            description = "Bezier curve name";
            example = "linear";
          };

          style = mkOption {
            type = nullOr str;
            default = null;
            description = "Animation style (optional, depends on animation name)";
          };
        };
      };

    in
    {
      options.hyprnix.settings.animations = {
        enabled = mkOption {
          type = nullOr bool;
          default = null;
          description = "enable animations";
        };

        workspace_wraparound = mkOption {
          type = nullOr bool;
          default = null;
          description = "enable workspace wraparound, causing directional workspace animations to animate as if the first and last workspaces were adjacent";
        };

        beziers = mkOption {
          type = listOf bezierType;
          default = [ ];
        };

        animations = mkOption {
          type = listOf animationType;
          default = [ ];
        };
      };

      config =
        let
          notEmpty = l: builtins.length l > 0;

          bezierMapper =
            b:
            let
              p = builtins.concatStringsSep ", " (map toString b.points);
            in
            "${b.name}, ${p}";

          animationMapper =
            a:
            "${a.name}, 1, ${toString a.speed}, ${a.curve}" + optionalString (a.style != null) ", ${a.style}";
        in
        {
          wayland.windowManager.hyprland.settings =
            lib.mkIf
              # if nothing is set don't write anything
              (
                cfg.enabled != null
                || cfg.workspace_wraparound != null
                || notEmpty cfg.beziers
                || notEmpty cfg.animations
              )
              {
                animations = {
                  enabled = mkIf (cfg.enabled != null) cfg.enabled;
                  workspace_wraparound = mkIf (cfg.workspace_wraparound != null) cfg.workspace_wraparound;

                  bezier = map bezierMapper cfg.beziers;
                  animation = map animationMapper cfg.animations;
                };
              };
        };
    };
}
