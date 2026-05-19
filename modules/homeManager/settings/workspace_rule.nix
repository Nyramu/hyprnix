{ lib, hyprlib, ... }:
{
  flake.homeModules.workspaces =
    { config, ... }:
    let
      inherit (lib) mkOption mapAttrsToList;

      inherit (lib.types)
        bool
        str
        ints
        nullOr
        attrsOf
        submodule
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred;

      cfg = config.hyprnix.settings.workspace_rule;
      cfg' = lib.pipe cfg [
        (mapAttrsToList (id: rules: rules // { workspace = id; }))
        (map filterValidAttrs)
        (map recursiveMkPreferred)
        (map mkLuaWorkspace)
      ];

      mkLuaWorkspace = w: {
        _args = [ w ];
      };

      ruleType = submodule {
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

          gaps_in = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "Set the gaps between windows (equivalent to General->gaps_in)";
          };

          gaps_out = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "Set the gaps between windows and monitor edges (equivalent to General->gaps_out)";
          };

          border_size = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "Set the border size around windows (equivalent to General->border_size)";
          };

          no_border = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to disable borders";
          };

          no_shadow = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to disable shadows";
          };

          no_rounding = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to disable rounded windows";
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

          on_created_empty = mkOption {
            type = nullOr str;
            default = null;
            description = "A command to be executed once a workspace is created empty (i.e. not created by moving a window to it)";
          };

          default_name = mkOption {
            type = nullOr str;
            default = null;
            description = "A default name for the workspace.";
          };

          layout = mkOption {
            type = nullOr str;
            default = null;
            description = "The layout to use for this workspace.";
          };

          animation = mkOption {
            type = nullOr str;
            default = null;
            description = "The animation style to use for this workspace.";
          };
        };
      };

    in
    {
      options.hyprnix.settings.workspace_rule = mkOption {
        type = attrsOf ruleType;
        default = null;
        description = "Hyprland workspace rules configuration.";
        example = {
          "1" = {
            persistent = true;
            default = true;
          };
          "2".persistent = true;
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          workspace_rule = lib.mkIf (cfg != { }) cfg';
        };
      };
    };
}
