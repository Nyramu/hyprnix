{ lib }:
let
  inherit (lib.types) submodule;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) callNestedBuilders;

  general = import ./general.nix { inherit lib; };
  workspace = import ./workspace.nix { inherit lib; };

  luaBuilders = general.builders // {
    workspace = callNestedBuilders workspace.builders;
  };
in
{
  type = submodule {
    options = general.options // {
      workspace = workspace.options;
    };
  };

  mkLuaDispatcher = name: params: luaBuilders.${name} params;
}
