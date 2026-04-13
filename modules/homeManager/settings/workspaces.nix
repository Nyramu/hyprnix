{ lib, ... }:
{
  flake.homeModules.workspaces =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        ints
        nullOr
        listOf
        submodule
        ;

      cfg = config.hyprnix.settings;

      valueToString = v: if builtins.isBool v then lib.boolToString v else toString v;

      rulesType = submodule {
        options = {
          monitor = mkOption {
            type = nullOr str;
            default = null;
            description = "Binds a workspace to a monitor.";
          };

          default = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether this workspace should be the default workspace for the given monitor";
          };

          gapsin = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "Set the gaps between windows (equivalent to General->gaps_in)";
          };

          gapsout = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "Set the gaps between windows and monitor edges (equivalent to General->gaps_out)";
          };

          bordersize = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "Set the border size around windows (equivalent to General->border_size)";
          };

          border = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to draw borders or not";
          };

          shadow = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to draw shadows or not";
          };

          rounding = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to draw rounded windows or not";
          };

          decorate = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to draw window decorations or not";
          };

          persistent = mkOption {
            type = nullOr bool;
            default = null;
            description = "Keep this workspace alive even if empty and inactive";
          };

          defaultName = mkOption {
            type = nullOr str;
            default = null;
            description = "A default name for the workspace.";
          };

          layout = mkOption {
            type = nullOr str;
            default = null;
            description = "The layout to use for this workspace.";
          };

          animations = mkOption {
            type = nullOr str;
            default = null;
            description = "The animation style to use for this workspace.";
          };
        };
      };

      workspaceType = submodule {
        options = {
          id = mkOption {
            type = ints.between 1 9;
            description = "The workspace's id.";
          };
          rules = mkOption {
            type = rulesType;
            description = "Rules for this workspace. At least one must be set.";
          };
        };
      };

      workspaceToString =
        ws:
        let
          activeRules = lib.filterAttrs (_: v: v != null) ws.rules;
          rulesParts = lib.mapAttrsToList (k: v: "${k}:${valueToString v}") activeRules;
        in
        lib.concatStringsSep ", " ([ (toString ws.id) ] ++ rulesParts);

    in
    {
      options.hyprnix.settings.workspaces = mkOption {
        type = listOf workspaceType;
        default = [ ];
        description = "Hyprland workspace rules configuration.";
        example = [
          {
            id = 1;
            rules = {
              persistent = true;
              default = true;
            };
          }
        ];
      };

      config = {
        assertions = lib.concatMap (ws: [
          {
            assertion = lib.any (v: v != null) (lib.attrValues ws.rules);
            message = "hyprnix.settings.workspaces[${toString ws.id}]: at least one rule must be set";
          }
        ]) cfg.workspaces;

        wayland.windowManager.hyprland.settings.workspace = map workspaceToString cfg.workspaces;
      };
    };
}
