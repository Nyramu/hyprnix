{ lib }:
let
  inherit (lib) mkOption optionalAttrs;
  inherit (lib.types) nullOr;
in
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

  mkNullable =
    {
      type,
      description ? null,
      example ? null,
    }:
    mkOption (
      {
        type = nullOr type;
        default = null;
      }
      // optionalAttrs (description != null) { inherit description; }
      // optionalAttrs (example != null) { inherit example; }
    );
}
