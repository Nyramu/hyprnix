{ lib }:

let
  inherit (lib)
    mkOption
    concatStringsSep
    filter
    filterAttrs
    head
    attrNames
    ;
  inherit (lib.types) nullOr submodule;
in
{
  luaConcat = fields: concatStringsSep ", " (filter (s: s != "") fields);
  callNestedBuilders =
    builders: params:
    let
      active = filterAttrs (_: v: v != null) params;
      name = head (attrNames active);
    in
    builders.${name} active.${name};

  options = {
    simple = type: mkOption { inherit type; };
    nullable =
      type:
      mkOption {
        type = nullOr type;
        default = null;
      };
    empty =
      _:
      mkOption {
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
