{ self, lib, ... }:
{
  flake.homeModules.layout =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        int
        listOf
        nullOr
        addCheck
        ;

      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.layout;
    in
    {
      options.hyprnix.settings.layout = {
        single_window_aspect_ratio = mkOption {
          type = nullOr (
            addCheck (listOf int) (l: builtins.length l == 2)
            // {
              name = "tuple";
              description = "list with 2 int values";
            }
          );
          default = null;
          description = ''
            whenever only a single window is shown on a screen, add padding so that it conforms to the specified aspect ratio.
            A value like 4 3 on a 16:9 screen will make it a 4:3 window in the middle with padding to the sides.
          '';
        };

        single_window_aspect_ratio_tolerance = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = ''
            sets a tolerance for single_window_aspect_ratio, so that if the padding that would have been added is smaller than the specified fraction of the height or width of the screen, it will not attempt to adjust the window size
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.layout = lib.filterAttrs (_: v: v != null) cfg;
      };
    };
}
