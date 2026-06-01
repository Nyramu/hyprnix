{ lib }:
let
  inherit (lib.types) number addCheck listOf;
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
  };

  tuple =
    type: n:
    (addCheck (listOf type) (x: builtins.length x == n))
    // {
      name = "tuple";
      description = "list... of type '${if type.name == "either" then type.description else type.name}'";
    };
}
