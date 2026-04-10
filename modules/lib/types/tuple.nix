{ lib, ... }:
let

  inherit (lib.types) number addCheck listOf;
in
{
  flake.lib.hyprnix.types = {
    tuple = n: (addCheck (listOf number) (x: builtins.length x == n)) // {
      name = "tuple";
      description = "list with ${toString n} number values";
    };
  };
}
