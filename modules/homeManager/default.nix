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
      imports = with modules; [ bind ];

      options.hyprnix = {
        enable = lib.mkEnableOption "hyprnix";
        systemd.enable = lib.mkEnableOption "systemd integration";
        xwayland.enable = lib.mkEnableOption "xwayland";
        
        package = lib.mkPackageOption pkgs "hyprland" {
          nullable = true;
          extraDescription = "Set this to null if you use the NixOS module to install Hyprland.";
        };
        
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = ''
            Extra configuration lines to append to the bottom of
            `~/.config/hypr/hyprland.conf`.
          '';
        };
        
        plugins = lib.mkOption {
          type = with lib.types; listOf (either package path);
          default = [ ];
          description = ''
            List of Hyprland plugins to use. Can either be packages or
            absolute plugin paths.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = cfg.systemd.enable;
          xwayland.enable = cfg.xwayland.enable;
          package = cfg.package;
          extraConfig = cfg.extraConfig;
          plugins = cfg.plugins;
        };
      };
    };
}
