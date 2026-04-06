{ lib, ... }:
{
  flake.homeModules.bind =
    { config, ... }:
    let
      cfg = config.hyprnix.settings;

      # Generates the various "bidnxyz" options
      mkAttrsOptions =
        names:
        lib.genAttrs names (
          _:
          lib.mkOption {
            type = lib.types.attrs;
            default = { };
            example = {
              "SUPER, Q" = "exit";
            };
          }
        );

      formatBinds = dispatcher: lib.mapAttrsToList (k: v: "${k}, ${v}") dispatcher;

      mkBindSettings = names: lib.genAttrs names (name: formatBinds cfg.${name});

      bindTypes = [
        "bind"
        "binds"
        "binde"
        "bindm"
      ];
    in
    {
      options.hyprnix.settings = mkAttrsOptions bindTypes;

      config = {
        wayland.windowManager.hyprland.settings = mkBindSettings bindTypes;
      };
    };
}
