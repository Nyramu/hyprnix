{ lib, ... }:
{
  flake.homeModules.settings =
    { config, ... }:
    let
      cfg = config.hyprnix.settings;

      valueType =
        with lib.types;
        oneOf [
          bool
          number
          singleLineStr
          (lazyAttrsOf valueType)
          (listOf valueType)
        ];
    in
    {
      options.hyprnix.settings = lib.mkOption {
        type = lib.types.lazyAttrsOf valueType;
        default = { };
        example = {
          col.border = "rgba(ff0000ff)";
          general.gaps_in = 5;
          decoration.blur.enabled = true;
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = cfg;
      };
    };
}
