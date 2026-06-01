{ lib, hyprlib, ... }:
{
  flake.homeModules.input =
    { ... }:
    let
      inherit (lib.types) bool str;
      inherit (lib.types.ints) between;
      inherit (hyprlib.utils) mkNullable;
    in
    {
      options.hyprnix.settings.input.touchdevice = {
        transform = mkNullable {
          type = between (-1) 7;
          description = "Transform the input from touchdevices. The possible transformations are the same as those of the monitors. -1 means it's unset.";
        };

        output = mkNullable {
          type = str;
          description = ''The monitor to bind touch devices. The default is auto-detection. To stop auto-detection, use an empty string or the "[[Empty]]" value.'';
        };

        enabled = mkNullable {
          type = bool;
          description = "Whether input is enabled for touch devices.";
        };
      };
    };
}
