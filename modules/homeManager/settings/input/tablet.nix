{ self, lib, ... }:
{
  flake.homeModules.input =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        nullOr
        ints
        ;
      inherit (self.lib.hyprnix.types) tuple;

      cfg = config.hyprnix.settings.input.tablet;
    in
    {
      options.hyprnix.settings.input.tablet = {
        transform = mkOption {
          type = nullOr (ints.between (-1) 7);
          default = null;
          description = "transform the input from tablets. The possible transformations are the same as those of the monitors. -1 means it’s unset.";
        };

        output = mkOption {
          type = nullOr str;
          default = null;
          description = "the monitor to bind tablets. Can be current or a monitor name. Leave empty to map across all monitors.";
        };

        region_position = mkOption {
          type = nullOr (tuple 2);
          default = null;
          description = "position of the mapped region in monitor layout relative to the top left corner of the bound monitor or all monitors.";
        };

        absolute_region_position = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to treat the region_position as an absolute position in monitor layout. Only applies when output is empty.";
        };

        region_size = mkOption {
          type = nullOr (tuple 2);
          default = null;
          description = "size of the mapped region. When this variable is set, tablet input will be mapped to the region. [0, 0] or invalid size means unset.";
        };

        relative_input = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether the input should be relative";
        };

        left_handed = mkOption {
          type = nullOr bool;
          default = null;
          description = "if enabled, the tablet will be rotated 180 degrees";
        };

        active_area_size = mkOption {
          type = nullOr (tuple 2);
          default = null;
          description = "size of tablet’s active area in mm";
        };

        active_area_position = mkOption {
          type = nullOr (tuple 2);
          default = null;
          description = "position of the active area in mm";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.input = {
          tablet = lib.filterAttrsRecursive (_: v: v != null) cfg;
        };
      };
    };
}
