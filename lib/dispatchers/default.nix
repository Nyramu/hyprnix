{ lib }:
let
  inherit (lib.types) submodule;

  helpers = import ./helpers.nix { inherit lib; };
  inherit (helpers) callNestedBuilders;
  inherit (helpers.options) nullableSubmodule;

  general = import ./general.nix { inherit lib; };
  workspace = import ./workspace.nix { inherit lib; };
  window = import ./window.nix { inherit lib; };
  group = import ./group.nix { inherit lib; };
  cursor = import ./cursor.nix { inherit lib; };

  luaBuilders = general.builders // {
    workspace = callNestedBuilders workspace.builders;
    window = callNestedBuilders window.builders;
    group = callNestedBuilders group.builders;
    cursor = callNestedBuilders cursor.builders;
  };
in
{
  type = submodule {
    options = general.options // {
      workspace = nullableSubmodule workspace.options;
      window = nullableSubmodule window.options;
      group = nullableSubmodule group.options;
      cursor = nullableSubmodule cursor.options;
    };
  };

  mkLuaDispatcher = name: params: luaBuilders.${name} params;
}
