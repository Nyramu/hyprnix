{ lib }:
let
  inherit (lib.types)
    number
    addCheck
    listOf
    oneOf
    submodule
    enum
    ;
in
{
  numbers = {
    unsigned = addCheck number (n: n >= 0) // {
      name = "numberUnsigned";
      description = "unsigned number, meaning >=0";
    };

    positive = addCheck number (n: n > 0) // {
      name = "numberPositive";
      description = "positive number, meaning >0";
    };

    between =
      low: high:
      addCheck number (v: v >= low && v <= high)
      // {
        name = "numberBetween";
        description = "number between ${toString low} and ${toString high} (both inclusive)";
      };

    tuple =
      n:
      (addCheck (listOf number) (x: builtins.length x == n))
      // {
        name = "tuple";
        description = "list with ${toString n} number values";
      };
  };

  # custom implementation of oneOf that can handle
  # partially overlapping submodules variants
  oneOfTagged =
    variants:
    oneOf (
      lib.mapAttrsToList (
        tag: mod:
        let
          base = submodule {
            options = mod.options // {
              _type = lib.mkOption {
                type = lib.types.enum [ tag ];
                default = tag;
                readOnly = true;
                internal = true;
              };
            };
          };
        in
        base // { check = v: base.check v && (v._type or "") == tag; }
      ) variants
    );
}
