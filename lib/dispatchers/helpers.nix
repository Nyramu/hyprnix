{ lib }:

let
  inherit (lib)
    mkOption
    optionalString
    concatStringsSep
    filter
    filterAttrs
    head
    attrNames
    ;
  inherit (lib.types)
    nullOr
    str
    number
    submodule
    ;
in
{
  ifPresent = x: optionalString (x != null);
  luaConcat = fields: concatStringsSep ", " (filter (s: s != "") fields);
  callNestedBuilders =
    builders: params:
    let
      active = filterAttrs (_: v: v != null) params;
      name = head (attrNames active);
    in
    builders.${name} active.${name};

  options = {
    simpleStr = mkOption { type = str; };
    nullableStr = mkOption {
      type = nullOr str;
      default = null;
    };
    nullableNumber = mkOption {
      type = nullOr number;
      default = null;
    };
    empty = mkOption {
      type = nullOr (submodule { });
      default = null;
    };
    nullableSubmodule =
      opts:
      mkOption {
        type = nullOr (submodule {
          options = opts;
        });
        default = null;
      };
  };

}
