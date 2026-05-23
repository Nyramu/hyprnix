{ lib }:

let
  inherit (lib)
    mkOption
    concatStringsSep
    filter
    filterAttrs
    head
    attrNames
    optionalString
    boolToString
    ;
  inherit (lib.types) nullOr submodule;
in
{
  luaConcat = fields: concatStringsSep ", " (filter (s: s != "") fields);
  luaField =
    args: name:
    optionalString (args ? ${name}) (
      let
        v = args.${name};
        rendered =
          if builtins.typeOf v == "bool" then
            boolToString v
          else if builtins.typeOf v == "int" || builtins.typeOf v == "float" then
            toString v
          else
            ''"${v}"'';
      in
      "${name} = ${rendered}"
    );

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
