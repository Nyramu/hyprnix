{ lib, ... }:
let

  inherit (lib.types) number addCheck listOf;
in
{
  flake.lib.hyprnix.types = {
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

    filterValidAttrs = (
      a:
      lib.pipe a [
        (lib.filterAttrsRecursive (_: v: v != null))
        (lib.filterAttrsRecursive (_: v: v != { }))
      ]
    );
  };
}
