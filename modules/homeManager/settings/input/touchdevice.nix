{ lib, ... }:
{
  flake.homeModules.input =
    { ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        nullOr
        ;
      inherit (lib.types.ints)
        between
        ;
    in
    {
      options.hyprnix.settings.input.touchdevice = {
        transform = mkOption {
          type = nullOr (between (-1) 7);
          default = null;
          description = "Transform the input from touchdevices. The possible transformations are the same as those of the monitors. -1 means it’s unset.";
        };

        output = mkOption {
          type = nullOr str;
          default = null;
          description = "The monitor to bind touch devices. The default is auto-detection. To stop auto-detection, use an empty string or the “[[Empty]]” value.";
        };

        enabled = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether input is enabled for touch devices.";
        };
      };
    };
}
