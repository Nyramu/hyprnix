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

      flattenAttrs =
        prefix: attrs:
        lib.foldlAttrs (
          acc: k: v:
          let
            key = if prefix == "" then k else "${prefix}.${k}";
          in
          if lib.isAttrs v then acc // flattenAttrs key v else acc // { ${key} = v; }
        ) { } attrs;
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
        wayland.windowManager.hyprland.settings = flattenAttrs "" cfg;
      };
    };
}
