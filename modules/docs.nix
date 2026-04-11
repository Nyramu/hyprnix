{ inputs, ... }:
{
  perSystem = { pkgs, lib, ... }:
  let
    optionsDoc = pkgs.nixosOptionsDoc {
      options = (lib.evalModules {
        modules = [
          inputs.self.homeModules.default
          { _module.check = false; }
        ];
      }).options;
      transformOptions = opt: opt // { declarations = [ ]; };
      warningsAreErrors = false;
    };
  in {
    packages.options-json = optionsDoc.optionsJSON;
  };
}
