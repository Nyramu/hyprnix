{ lib, hyprlib, ... }:
{
  flake.homeModules.layer_rule =
    { config, ... }:
    let
      inherit (lib) mkOption mapAttrs mapAttrsToList;
      inherit (lib.types)
        bool
        int
        str
        attrsOf
        submodule
        ;

      inherit (hyprlib.types) numbers;
      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.layer_rule;
      cfg' = lib.pipe cfg [
        (mapAttrsToList (name: params: params // { inherit name; }))
        (map filterValidAttrs)
        (map recursiveMkPreferred)
      ];

      effects = {
        no_anim = bool;
        blur = bool;
        blur_popups = bool;
        ignore_alpha = numbers.between 0 1;
        dim_around = bool;
        xray = bool;
        animation = str;
        order = int;
        above_lock = int; # TODO: understand if it can be a range (docs are not clear)
        no_screen_share = bool;
      };

      layer_ruleType = submodule {
        options = {
          match = mkOption {
            type = submodule {
              options = {
                namespace = mkOption {
                  type = str;
                  description = "Namespace of the layer. Check `hyprctl layers`";
                };
              };
            };
          };
        }
        // mapAttrs (_: type: mkNullable { inherit type; }) effects;
      };
    in
    {
      options.hyprnix.settings.layer_rule = mkOption {
        type = attrsOf layer_ruleType;
        default = { };
        description = "Hyprland layer_rule configuration.";
        example = {
          "cooler-rofi" = {
            match.namespace = "rofi";
            blur = true;
            ignore_alpha = 0.5;
          };
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          layer_rule = cfg';
        };
      };
    };
}
