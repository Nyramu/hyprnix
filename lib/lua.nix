{ lib }:
let
  inherit (lib)
    concatMapStrings
    concatMapStringsSep
    isAttrs
    isList
    optionalString
    ;

  toLua = lib.generators.toLua { };

  # `_args` renders attrsets as Lua multi-argument calls instead of tables.
  renderLuaArgs =
    value:
    if isAttrs value && value ? _args then concatMapStringsSep ", " toLua value._args else toLua value;

  renderCall = name: value: "hl.${name}(${renderLuaArgs value})\n";

  renderCalls =
    name: value: concatMapStrings (renderCall name) (if isList value then value else [ value ]);
in
{
  inherit toLua renderLuaArgs;

  # Render a settings section (a list of `_args` attrsets, or a single value)
  # as a sequence of `hl.<name>(...)` calls, prefixed with a comment header.
  renderSection =
    name: value:
    let
      calls = renderCalls name value;
    in
    optionalString (calls != "") ("-- ${name}\n" + calls);
}
