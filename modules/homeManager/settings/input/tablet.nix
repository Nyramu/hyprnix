{ lib, hyprlib, ... }:
{
  flake.homeModules.input =
    { ... }:
    let
      inherit (lib.types)
        bool
        str
        number
        ints
        ;
      inherit (hyprlib.utils) mkNullable;
      inherit (hyprlib.types) tuple;
    in
    {
      options.hyprnix.settings.input.tablet = {
        transform = mkNullable {
          type = ints.between (-1) 7;
          description = "transform the input from tablets. The possible transformations are the same as those of the monitors. -1 means it's unset.";
        };

        output = mkNullable {
          type = str;
          description = "the monitor to bind tablets. Can be current or a monitor name. Leave empty to map across all monitors.";
        };

        region_position = mkNullable {
          type = tuple number 2;
          description = "position of the mapped region in monitor layout relative to the top left corner of the bound monitor or all monitors.";
        };

        absolute_region_position = mkNullable {
          type = bool;
          description = "whether to treat the region_position as an absolute position in monitor layout. Only applies when output is empty.";
        };

        region_size = mkNullable {
          type = tuple number 2;
          description = "size of the mapped region. When this variable is set, tablet input will be mapped to the region. [0, 0] or invalid size means unset.";
        };

        relative_input = mkNullable {
          type = bool;
          description = "whether the input should be relative";
        };

        left_handed = mkNullable {
          type = bool;
          description = "if enabled, the tablet will be rotated 180 degrees";
        };

        active_area_size = mkNullable {
          type = tuple number 2;
          description = "size of tablet's active area in mm";
        };

        active_area_position = mkNullable {
          type = tuple number 2;
          description = "position of the active area in mm";
        };
      };
    };
}
