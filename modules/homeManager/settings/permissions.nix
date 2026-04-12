{ lib, ... }:
{
  flake.homeModules.permissions =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        either
        path
        str

        nullOr
        enum
        listOf
        submodule
        ;

      cfg = config.hyprnix.settings.permissions;

      permissions = enum [
        "screencopy"
        "plugin"
        "keyboard"
      ];

      modes = enum [
        "allow"
        "ask"
        "deny"
      ];

      permissionType = submodule {
        options = {
          executable = mkOption {
            type = either str path;
            description = "path to executable";
            example = "${"lib.getExe pkgs.grim"}";
          };

          permission = mkOption {
            type = permissions;
            description = "permission assigned to the executable";
            example = "screencopy";
          };

          mode = mkOption {
            type = modes;
            description = "permission mode";
            example = "allow";
          };
        };
      };

      permissionToString = map (p: "${toString p.executable}, ${p.permission}, ${p.mode}");
    in
    {
      options.hyprnix.settings = {
        permissions = mkOption {
          type = nullOr (listOf permissionType);
          default = [ ];
          description = "Hyprland permissions configuration";
          example = {
            executable = "${"lib.getExe pkgs.grim"}";
            permission = "screencopy";
            mode = "allow";
          };
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          permission = permissionToString cfg;
        };
      };
    };
}
