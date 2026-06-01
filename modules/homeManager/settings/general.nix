{ lib, hyprlib, ... }:
{
  flake.homeModules.general =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        int
        str
        enum
        addCheck
        ;
      inherit (lib.types.ints) between positive unsigned;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.general;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        parseColOptions
        recursiveMkPreferred
      ];

      parseColOptions = (
        attrs:
        (removeAttrs attrs [ "col" ])
        // lib.mapAttrs' (n: v: lib.nameValuePair "col.${n}" v) (attrs.col or { })
      );
    in
    {
      options.hyprnix.settings.general = {
        border_size = mkNullable {
          type = positive;
          description = "size of the border around windows";
        };

        gaps_in = mkNullable {
          type = unsigned;
          description = "gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)";
        };

        gaps_out = mkNullable {
          type = unsigned;
          description = "gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)";
        };

        float_gaps = mkNullable {
          type = addCheck int (x: x >= (-1));
          description = "gaps between windows and monitor edges for floating windows, also supports css style gaps (top, right, bottom, left -> 5 10 15 20). -1 means default";
        };

        gaps_workspaces = mkNullable {
          type = unsigned;
          description = "gaps between workspaces. Stacks with gaps_out.";
        };

        col.inactive_border = mkNullable {
          type = str;
          description = "border color for inactive windows";
        };

        col.active_border = mkNullable {
          type = str;
          description = "border color for the active window";
        };

        col.nogroup_border = mkNullable {
          type = str;
          description = "inactive border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)";
        };

        col.nogroup_border_active = mkNullable {
          type = str;
          description = "active border color for window that cannot be added to a group";
        };

        layout = mkNullable {
          type = (
            enum [
              "dwindle"
              "master"
              "scrolling"
              "monocle"
            ]
          );
          description = "which layout to use";
        };

        no_focus_fallback = mkNullable {
          type = bool;
          description = "if true, will not fall back to the next available window when moving focus in a direction where no window was found";
        };

        resize_on_border = mkNullable {
          type = bool;
          description = "enables resizing windows by clicking and dragging on borders and gaps";
        };

        extend_border_grab_area = mkNullable {
          type = positive;
          description = "extends the area around the border where you can click and drag on, only used when general:resize_on_border is on.";
        };

        hover_icon_on_border = mkNullable {
          type = bool;
          description = "show a cursor icon when hovering over borders, only used when general:resize_on_border is on.";
        };

        allow_tearing = mkNullable {
          type = bool;
          description = "master switch for allowing tearing to occur. See the Tearing page.";
        };

        resize_corner = mkNullable {
          type = between 0 4;
          description = "force floating windows to use a specific corner when being resized (1-4 going clockwise from top left, 0 to disable)";
        };

        modal_parent_blocking = mkNullable {
          type = bool;
          description = "whether parent windows of modals will be interactive";
        };

        locale = mkNullable {
          type = str;
          description = "overrides the system locale (e.g. en_US, es)";
        };

        snap = {
          enabled = mkNullable {
            type = bool;
            description = "enable snapping for floating windows";
          };

          window_gap = mkNullable {
            type = unsigned;
            description = "minimum gap in pixels between windows before snapping";
          };

          monitor_gap = mkNullable {
            type = unsigned;
            description = "minimum gap in pixels between window and monitor edges before snapping";
          };

          border_overlap = mkNullable {
            type = bool;
            description = "if true, windows snap such that only one border's worth of space is between them";
          };

          respect_gaps = mkNullable {
            type = bool;
            description = "if true, snapping will respect gaps between windows(set in general:gaps_in)";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          general = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
