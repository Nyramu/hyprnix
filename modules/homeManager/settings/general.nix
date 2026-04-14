{ lib, ... }:
{
  flake.homeModules.general =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        int
        str
        nullOr
        enum
        addCheck
        ;
      inherit (lib.types.ints)
        between
        positive
        unsigned
        ;

      cfg = config.hyprnix.settings.general;
      cfg' = lib.pipe cfg [
        (lib.filterAttrsRecursive (_: v: v != null))
        (lib.filterAttrsRecursive (_: v: v != { }))
      ];
    in
    {
      options.hyprnix.settings.general = {
        border_size = mkOption {
          type = nullOr positive;
          default = null;
          description = "size of the border around windows";
        };

        gaps_in = mkOption {
          type = nullOr unsigned;
          default = null;
          description = "gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)";
        };

        gaps_out = mkOption {
          type = nullOr unsigned;
          default = null;
          description = "gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)";
        };

        float_gaps = mkOption {
          type = nullOr (addCheck int (x: x >= (-1)));
          default = null;
          description = "gaps between windows and monitor edges for floating windows, also supports css style gaps (top, right, bottom, left -> 5 10 15 20). -1 means default";
        };

        gaps_workspaces = mkOption {
          type = nullOr unsigned;
          default = null;
          description = "gaps between workspaces. Stacks with gaps_out.";
        };

        col.inactive_border = mkOption {
          type = nullOr str;
          default = null;
          description = "border color for inactive windows";
        };

        col.active_border = mkOption {
          type = nullOr str;
          default = null;
          description = "border color for the active window";
        };

        col.nogroup_border = mkOption {
          type = nullOr str;
          default = null;
          description = "inactive border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)";
        };

        col.nogroup_border_active = mkOption {
          type = nullOr str;
          default = null;
          description = "active border color for window that cannot be added to a group";
        };

        layout = mkOption {
          type = nullOr (enum [
            "dwindle"
            "master"
            "scrolling"
            "monocle"
          ]);
          default = null;
          description = "which layout to use";
        };

        no_focus_fallback = mkOption {
          type = nullOr bool;
          default = null;
          description = "if true, will not fall back to the next available window when moving focus in a direction where no window was found";
        };

        resize_on_border = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables resizing windows by clicking and dragging on borders and gaps";
        };

        extend_border_grab_area = mkOption {
          type = nullOr positive;
          default = null;
          description = "extends the area around the border where you can click and drag on, only used when general:resize_on_border is on.";
        };

        hover_icon_on_border = mkOption {
          type = nullOr bool;
          default = null;
          description = "show a cursor icon when hovering over borders, only used when general:resize_on_border is on.";
        };

        allow_tearing = mkOption {
          type = nullOr bool;
          default = null;
          description = "master switch for allowing tearing to occur. See the Tearing page.";
        };

        resize_corner = mkOption {
          type = nullOr (between 0 4);
          default = null;
          description = "force floating windows to use a specific corner when being resized (1-4 going clockwise from top left, 0 to disable)";
        };

        modal_parent_blocking = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether parent windows of modals will be interactive";
        };

        locale = mkOption {
          type = nullOr str;
          default = null;
          description = "overrides the system locale (e.g. en_US, es)";
        };

        snap = {
          enabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "enable snapping for floating windows";
          };

          window_gap = mkOption {
            type = nullOr unsigned;
            default = null;
            description = "minimum gap in pixels between windows before snapping";
          };

          monitor_gap = mkOption {
            type = nullOr unsigned;
            default = null;
            description = "minimum gap in pixels between window and monitor edges before snapping";
          };

          border_overlap = mkOption {
            type = nullOr bool;
            default = null;
            description = "if true, windows snap such that only one border’s worth of space is between them";
          };

          respect_gaps = mkOption {
            type = nullOr bool;
            default = null;
            description = "if true, snapping will respect gaps between windows(set in general:gaps_in)";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          general = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
