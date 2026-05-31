{ lib, hyprlib, ... }:
{
  flake.homeModules.bind =
    { config, ... }:
    let
      inherit (lib)
        mkOption
        mapAttrsToList
        filterAttrs
        filterAttrsRecursive
        attrNames
        concatMap
        ;

      inherit (lib.types)
        attrsOf
        bool
        submodule
        ;

      inherit (lib.generators) mkLuaInline;
      inherit (hyprlib.dispatchers) mkLuaDispatcher;

      dispatcherType = hyprlib.dispatchers.type;

      cfg = config.hyprnix.settings.bind;
      cfg' = lib.pipe cfg [
        (filterAttrsRecursive (_: v: v != null))
        (mapAttrsToList (key: value: { inherit key value; }))
        (concatMap ({ key, value }: mkBindEntries key value))
      ];

      mkBindEntries =
        key: value:
        map (expr: {
          _args = [
            key
            (mkLuaInline expr)
            value.flags
          ];
        }) (mkLuaDispatchers value);

      mkLuaDispatchers =
        b:
        let
          active = filterAttrs (_: v: v != null) b.dispatcher;
        in
        map (name: mkLuaDispatcher name active.${name}) (attrNames active);

      bindType = submodule {
        options = {
          dispatcher = mkOption {
            type = dispatcherType;
          };
          flags = mkOption {
            type = attrsOf bool;
            default = { };
          };
        };
      };
    in
    {
      options.hyprnix.settings.bind = mkOption {
        type = attrsOf bindType;
        default = { };
        example = {
          "SUPER + RETURN".dispatcher.exec_cmd = "ghostty";
          "SUPER + X".dispatcher = {
            exec_cmd = ''notify-send "shutting down"'';
            exit = { };
          };
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          bind = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
