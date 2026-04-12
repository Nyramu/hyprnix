{ self, lib, ... }:
let
  modules = self.homeModules;
in
{
  flake.homeModules.default =
    { config, pkgs, ... }:
    let
      cfg = config.hyprnix;
    in
    {
      imports = with modules; [
        keybinds
        misc
        dwindle
        monitors
        group
        workspaces
        animations
        env
        exec
        general
        decoration
        input
        gesture
        layout
        binds
        render
        permissions
        master
        opengl
        quirks
        debug
        ecosystem
        cursor
      ];

      options.hyprnix = {
        enable = lib.mkEnableOption "hyprnix";
        systemd.enable = lib.mkEnableOption "systemd integration";
        xwayland.enable = lib.mkEnableOption "xwayland";

        package = lib.mkPackageOption pkgs "hyprland" {
          default = null;
          nullable = true;
          extraDescription = "Set this to null if you use the NixOS module to install Hyprland.";
        };

        portalPackage = lib.mkPackageOption pkgs "xdg-desktop-portal-hyprland" {
          default = null;
          nullable = true;
          extraDescription = "Set this to null if you use the NixOS module to install Hyprland.";
        };

        plugins = lib.mkOption {
          type = with lib.types; listOf (either package path);
          default = [ ];
          description = "List of Hyprland plugins to use.";
        };

        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = ''
            Extra configuration lines to append to the bottom of
            `~/.config/hypr/hyprland.conf`.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = cfg.systemd.enable;
          xwayland.enable = cfg.xwayland.enable;
          package = cfg.package;
          portalPackage = cfg.portalPackage;
          plugins = cfg.plugins;
          extraConfig = cfg.extraConfig;
        };
      };
    };
}
