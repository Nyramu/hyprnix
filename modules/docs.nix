{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      repoUrl = "https://github.com/Nyramu/hyprnix/blob/main";
      baseDir = toString inputs.self;

      optionsDoc = pkgs.nixosOptionsDoc {
        options =
          (lib.evalModules {
            modules = [
              inputs.self.homeModules.default
              { _module.check = false; }
            ];
          }).options;

        warningsAreErrors = false;

        transformOptions =
          opt:
          opt
          // {
            declarations = map (
              decl:
              let
                declStr = toString decl;
                # removes some text that would break the link
                path = builtins.head (lib.splitString "," declStr);
                rel = lib.removePrefix (baseDir + "/") path;
              in
              {
                name = rel;
                url = "${repoUrl}/${rel}";
              }
            ) opt.declarations;
          };
      };
    in
    {
      packages.options-json = optionsDoc.optionsJSON;
    };
}
