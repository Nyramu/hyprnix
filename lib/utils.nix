{ lib }:
rec {
  filterValidAttrs = (
    a:
    lib.pipe a [
      (lib.filterAttrsRecursive (_: v: v != null))
      (lib.filterAttrsRecursive (_: v: v != { }))
    ]
  );

  mkPreferred = lib.mkOverride 75;

  recursiveMkPreferred = (lib.mapAttrsRecursive (_: mkPreferred));
}
