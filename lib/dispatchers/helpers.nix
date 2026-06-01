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
  inherit (lib.types)
    nullOr
    submodule
    either
    listOf
    str
    number
    enum
    addCheck
    ;
in
rec {
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
          else if builtins.typeOf v == "string" then
            ''"${v}"''
          else if builtins.typeOf v == "list" then
            "{${concatStringsSep ", " (map toString v)}}"
          else if builtins.typeOf v == "set" && (v._type or null) == "gradient" then
            let
              colorsStr = "{${concatStringsSep ", " (map (c: ''"${c}"'') v.colors)}}";
            in
            "{${
              luaConcat [
                "colors = ${colorsStr}"
                (optionalString (v.angle != null) "angle = ${toString v.angle}")
              ]
            }}"
          else
            throw "luaField: unsupported type '${builtins.typeOf v}' for field '${name}'";
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

  hyprlandTypes =
    let
      inherit (options) simple nullable;
    in
    {
      gradient = either str (submodule {
        options = {
          _type = mkOption {
            type = enum [ "gradient" ];
            default = "gradient";
            readOnly = true;
            internal = true;
          };
          colors = simple (listOf str);
          angle = nullable number;
        };
      });

      vec2 = (addCheck (listOf number) (x: builtins.length x == 2)) // {
        name = "vec2";
        description = "list with 2 number values";
      };
    };
}
