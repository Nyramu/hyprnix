{ lib, ... }:
{
  flake.homeModules.bind =
    { config, ... }:
    let
      cfg = config.hyprnix.keybinds;
      validFlags = lib.stringToCharacters "cdegiklmnoprstu";

      isValidBind =
        name:
        let
          suffix = lib.removePrefix "bind" name;
          chars = lib.stringToCharacters suffix;
        in
        lib.hasPrefix "bind" name && lib.all (c: lib.elem c validFlags) chars;

      formatBinds = lib.mapAttrsToList (k: v: "${k}, ${v}");
    in
    {
      options.hyprnix.keybinds = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        example = {
          bind."SUPER, Q" = "exit";
          bindel."XF86AudioRaiseVolume" = "exec, pamixer -i 5";
        };
      };

      config = {
        assertions = lib.mapAttrsToList (name: _: {
          assertion = isValidBind name;
          message = "'${name}' is not a valid bind: it must begin with 'bind' followed only by valid characters (${lib.concatStrings validFlags})";
        }) cfg;

        wayland.windowManager.hyprland.settings = lib.mapAttrs (_: formatBinds) cfg;
      };
    };
}
