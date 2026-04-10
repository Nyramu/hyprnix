{ lib, ... }:
let

  inherit (lib.types) number addCheck;
in
{
  flake.lib.hyprnix.types.numbers = {
    unsigned =
      n:
      addCheck number (n: n >= 0)
      // {
        name = "numberUnsigned";
        description = "unsigned number, meaning >=0";
      };

    positive =
      n:
      addCheck number (n: n > 0)
      // {
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
  };
}
