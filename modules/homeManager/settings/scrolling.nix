{ self, lib, ... }:
{
  flake.homeModules.scrolling =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        listOf
        number
        enum
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.scrolling;

      cfg' = cfg // {
        explicit_column_widths = lib.mapNullable (
          l: lib.concatStringsSep ", " (map toString l)
        ) cfg.explicit_column_widths;
      };
    in
    {
      options.hyprnix.settings.scrolling = {
        fullscreen_on_one_column = mkOption {
          type = nullOr bool;
          default = null;
          description = "when enabled, a single column on a workspace will always span the entire screen.";
        };

        column_width = mkOption {
          type = nullOr (numbers.between 0.1 1);
          default = null;
          description = "the default width of a column";
        };

        focus_fit_method = mkOption {
          type = nullOr (ints.between 0 1);
          default = null;
          description = ''
            When a column is focused, what method should be used to bring it into view.
            0 = center, 1 = fit
          '';
        };

        follow_focus = mkOption {
          type = nullOr bool;
          default = null;
          description = "when a window is focused, should the layout move to bring it into view automatically";
        };

        follow_min_visible = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = ''
            when a window is focused, require that at least a given fraction of it is visible for focus to follow.
            Hard input (e.g. binds, clicks) will always follow.
          '';
        };

        explicit_column_widths = mkOption {
          type = nullOr (listOf number);
          default = null;
          description = "A list of preconfigured widths for colresize +conf/-conf";
        };

        wrap_focus = mkOption {
          type = nullOr bool;
          default = null;
          description = "When enabled, causes layoutmsg focus l/r to wrap around at the beginning and end.";
        };

        wrap_swapcol = mkOption {
          type = nullOr bool;
          default = null;
          description = "When enabled, causes layoutmsg swapcol l/r to wrap around at the beginning and end.";
        };

        direction = mkOption {
          type = nullOr (enum [
            "left"
            "right"
            "down"
            "up"
          ]);
          default = null;
          description = "Direction in which new windows appear and the layout scrolls.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.scrolling = lib.filterAttrs (_: v: v != null) cfg';
      };
    };
}
