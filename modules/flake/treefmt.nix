{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt.config = {
        projectRootFile = "flake.nix";
        flakeCheck = true;
        programs.nixfmt.enable = true;
      };
    };
}
