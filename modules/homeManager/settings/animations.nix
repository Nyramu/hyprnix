{ self, lib, ... }:
{
  flake.homeModules.animations =
    { config, ... }:
    let
      inherit (lib)
        mkIf
        mkOption
        optionalString
        ;
      inherit (lib.types)
        str
        bool

        listOf
        attrsOf
        nullOr
        submodule
        ;

      inherit (lib.types.ints) positive;
      inherit (self.lib.hyprnix.types) tuple;

      cfg = config.hyprnix.settings.animations;

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

        bezier = mkOption {
          type = attrsOf (tuple 4);
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

        animations = mkOption {
          type = listOf animationType;
          default = [ ];
        };
      };

      config =
        let
          notEmpty = l: builtins.length l > 0;

          bezierMapper =
            name: points:
            let
              p = builtins.concatStringsSep ", " (map toString points);
            in
            "${name}, ${p}";

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
                || cfg.bezier != { }
                || notEmpty cfg.animations
              )
              {
                animations = {
                  enabled = mkIf (cfg.enabled != null) cfg.enabled;
                  workspace_wraparound = mkIf (cfg.workspace_wraparound != null) cfg.workspace_wraparound;

                  bezier = lib.mapAttrsToList bezierMapper cfg.bezier;
                  animation = map animationMapper cfg.animations;
                };
              };
        };
    };
}
