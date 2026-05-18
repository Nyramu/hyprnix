{ self, lib, ... }:
{
  _module.args.hyprlib = {
    types = import "${self.outPath}/lib/types.nix" { inherit lib; };
    utils = import "${self.outPath}/lib/utils.nix" { inherit lib; };
    dispatchers = import "${self.outPath}/lib/dispatchers.nix" { inherit lib; };
  };
}
