{ self, lib, ... }:
let
  modules = self.homeModules;
in
{
  flake.homeModules.default =
    { config, ... }:
    let
      cfg = config.hyprnix;
    in
    {
      imports = with modules; [ keybinds ];

      options.hyprnix = {
        enable = lib.mkEnableOption "hyprnix";

        systemd.enable = lib.mkEnableOption "systemd integration";

        xwayland.enable = lib.mkEnableOption "xwayland";

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
          extraConfig = cfg.extraConfig;
        };
      };
    };
}
