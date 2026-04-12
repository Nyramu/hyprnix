{ self, inputs, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    let
      repoUrl = "https://github.com/Nyramu/hyprnix/blob/main";
      baseDir = toString self;

      optionsDoc = pkgs.nixosOptionsDoc {
        options =
          (lib.evalModules {
            modules = [
              self.homeModules.default
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

      ndg = inputs.ndg.packages.${system}.ndg;
    in
    {
      packages = {
        options-json = optionsDoc.optionsJSON;

        docs = pkgs.runCommandLocal "hyprnix-docs" { nativeBuildInputs = [ ndg ]; } ''
          ndg --config-file ${./ndg.toml} \
            html \
            --module-options ${optionsDoc.optionsJSON}/share/doc/nixos/options.json \
            --input-dir ${baseDir + "/docs"} \
            --output-dir $out
        '';
      };
    };
}
