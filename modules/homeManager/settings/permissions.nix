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
      cfg' = map mkLuaPermission cfg;

      permissions = enum [
        "screencopy"
        "plugin"
        "keyboard"
        "cursorpos"
      ];

      modes = enum [
        "allow"
        "ask"
        "deny"
      ];

      permissionType = submodule {
        options = {
          binary = mkOption {
            type = either str path;
            description = "path to binary";
            example = "${"lib.getExe pkgs.grim"}";
          };

          type = mkOption {
            type = permissions;
            description = "permission assigned to the binary";
            example = "screencopy";
          };

          mode = mkOption {
            type = modes;
            description = "permission mode";
            example = "allow";
          };
        };
      };

      mkLuaPermission = p: {
        _args = [ p ];
      };
    in
    {
      options.hyprnix.settings = {
        permissions = mkOption {
          type = nullOr (listOf permissionType);
          default = [ ];
          description = "Hyprland permissions configuration";
          example = [
            {
              binary = "${"lib.getExe pkgs.grim"}";
              permission = "screencopy";
              mode = "allow";
            }
          ];
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          permission = cfg';
        };
      };
    };
}
