{ lib, hyprlib, ... }:
{
  flake.homeModules.workspaces =
    { config, ... }:
    let
      inherit (lib) mapAttrsToList mkOption;

      inherit (lib.types)
        bool
        str
        ints
        attrsOf
        submodule
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

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
          monitor = mkNullable {
            type = str;
            description = "Binds a workspace to a monitor.";
          };

          default = mkNullable {
            type = bool;
            description = "Whether this workspace should be the default workspace for the given monitor";
          };

          gaps_in = mkNullable {
            type = ints.unsigned;
            description = "Set the gaps between windows (equivalent to General->gaps_in)";
          };

          gaps_out = mkNullable {
            type = ints.unsigned;
            description = "Set the gaps between windows and monitor edges (equivalent to General->gaps_out)";
          };

          border_size = mkNullable {
            type = ints.unsigned;
            description = "Set the border size around windows (equivalent to General->border_size)";
          };

          no_border = mkNullable {
            type = bool;
            description = "Whether to disable borders";
          };

          no_shadow = mkNullable {
            type = bool;
            description = "Whether to disable shadows";
          };

          no_rounding = mkNullable {
            type = bool;
            description = "Whether to disable rounded windows";
          };

          decorate = mkNullable {
            type = bool;
            description = "Whether to draw window decorations or not";
          };

          persistent = mkNullable {
            type = bool;
            description = "Keep this workspace alive even if empty and inactive";
          };

          on_created_empty = mkNullable {
            type = str;
            description = "A command to be executed once a workspace is created empty (i.e. not created by moving a window to it)";
          };

          default_name = mkNullable {
            type = str;
            description = "A default name for the workspace.";
          };

          layout = mkNullable {
            type = str;
            description = "The layout to use for this workspace.";
          };

          animation = mkNullable {
            type = str;
            description = "The animation style to use for this workspace.";
          };
        };
      };

    in
    {
      options.hyprnix.settings.workspace_rule = mkOption {
        type = attrsOf ruleType;
        default = { };
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
