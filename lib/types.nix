{ lib }:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    str
    number
    addCheck
    listOf
    either
    submodule
    ;
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) mkNullable;

  complexGradientType = submodule {
    options = {
      colors = mkOption { type = listOf str; };
      angle = mkNullable { type = number; };
    };
  };
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

  hyprland = {
    gradient = either str complexGradientType;
  };

  tuple =
    type: n:
    (addCheck (listOf type) (x: builtins.length x == n))
    // {
      name = "tuple";
      description = "list... of type '${if type.name == "either" then type.description else type.name}'";
    };
}
