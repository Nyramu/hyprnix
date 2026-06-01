{ lib, hyprlib, ... }:
{
  flake.homeModules.scrolling =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        listOf
        number
        enum
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.scrolling;

      cfg' = lib.pipe cfg [
        extract_column_widths
        filterValidAttrs
        recursiveMkPreferred
      ];

      extract_column_widths = (
        c:
        c
        // {
          explicit_column_widths = lib.mapNullable (
            l: lib.concatStringsSep ", " (map toString l)
          ) c.explicit_column_widths;
        }
      );
    in
    {
      options.hyprnix.settings.scrolling = {
        fullscreen_on_one_column = mkNullable {
          type = bool;
          description = "when enabled, a single column on a workspace will always span the entire screen.";
        };

        column_width = mkNullable {
          type = numbers.between 0.1 1;
          description = "the default width of a column";
        };

        focus_fit_method = mkNullable {
          type = ints.between 0 1;
          description = ''
            When a column is focused, what method should be used to bring it into view.
            0 = center, 1 = fit
          '';
        };

        follow_focus = mkNullable {
          type = bool;
          description = "when a window is focused, should the layout move to bring it into view automatically";
        };

        follow_min_visible = mkNullable {
          type = numbers.between 0 1;
          description = ''
            when a window is focused, require that at least a given fraction of it is visible for focus to follow.
            Hard input (e.g. binds, clicks) will always follow.
          '';
        };

        explicit_column_widths = mkNullable {
          type = listOf number;
          description = "A list of preconfigured widths for colresize +conf/-conf";
        };

        wrap_focus = mkNullable {
          type = bool;
          description = "When enabled, causes layoutmsg focus l/r to wrap around at the beginning and end.";
        };

        wrap_swapcol = mkNullable {
          type = bool;
          description = "When enabled, causes layoutmsg swapcol l/r to wrap around at the beginning and end.";
        };

        direction = mkNullable {
          type = enum [
            "left"
            "right"
            "down"
            "up"
          ];
          description = "Direction in which new windows appear and the layout scrolls.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          scrolling = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
