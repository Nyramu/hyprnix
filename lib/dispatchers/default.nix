{ lib }:
let
  inherit (lib.types) submodule;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) callNestedBuilders;
  inherit (helpers.options) nullableSubmodule;

  general = import ./general.nix { inherit lib; };
  workspace = import ./workspace.nix { inherit lib; };
  window = import ./window.nix { inherit lib; };

  luaBuilders = general.builders // {
    workspace = callNestedBuilders workspace.builders;
    window = callNestedBuilders window.builders;
  };
in
{
  type = submodule {
    options = general.options // {
      workspace = nullableSubmodule workspace.options;
      window = nullableSubmodule window.options;
    };
  };

  mkLuaDispatcher = name: params: luaBuilders.${name} params;
}
