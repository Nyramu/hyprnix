{ lib, ... }:
{
  flake.homeModules.keybinds =
    { config, ... }@hmArgs:
    let
      inherit (lib)
        mkOption
        stringToCharacters
        removePrefix
        hasPrefix
        all
        elem
        mapAttrsToList
        concatStrings
        mapAttrs
        ;

      inherit (lib.types) attrs attrsOf;

      cfg = config.hyprnix.settings.keybinds;

      validFlags = stringToCharacters "cdegiklmnoprstu";

      isValidBind =
        name:
        let
          suffix = removePrefix "bind" name;
          chars = stringToCharacters suffix;
        in
        hasPrefix "bind" name && all (c: elem c validFlags) chars;

      formatBinds = mapAttrsToList (k: v: "${k}, ${v}");
    in
    {
      options.hyprnix.settings.keybinds = mkOption {
        type = attrsOf attrs;
        default = { };
        example = {
          bind."SUPER, Q" = "exit";
          bindel."XF86AudioRaiseVolume" = "exec, pamixer -i 5";
        };
      };

      config = {
        assertions = mapAttrsToList (name: _: {
          assertion = isValidBind name;
          message = "'${name}' is not a valid bind: it must begin with 'bind' followed only by valid characters (${concatStrings validFlags})";
        }) cfg;

        xdg.configFile."hypr/keybinds.conf".text = hmArgs.lib.hm.generators.toHyprconf {
          attrs = mapAttrs (_: formatBinds) cfg;
        };

        wayland.windowManager.hyprland.settings.source = [ "keybinds.conf" ];
      };
    };
}
