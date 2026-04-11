{ self, lib, ... }:
{
  flake.homeModules.group =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        str
        int
        nullOr
        enum
        either
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers;

      font_weight = either (ints.between 100 1000) (enum [
        "thin"
        "ultralight"
        "light"
        "semilight"
        "book"
        "normal"
        "medium"
        "semibold"
        "bold"
        "ultrabold"
        "heavy"
        "ultraheavy"
      ]);

      cfg = config.hyprnix.settings.group;
    in
    {
      options.hyprnix.settings.group = {
        auto_group = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            whether new windows will be automatically grouped into the focused unlocked group.
            Note: if you want to disable auto_group only for specific windows, use the "group barred" window rule instead.
          '';
        };

        insert_after_current = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether new windows in a group spawn after current or at group tail";
        };

        focus_removed_window = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether Hyprland should focus on the window that has just been moved out of the group";
        };

        drag_into_group = mkOption {
          type = nullOr (ints.between 0 2);
          default = null;
          description = ''
            whether dragging a window into a unlocked group will merge them.
            0 -> disabled.
            1 -> enabled.
            2 -> only when dragging into the groupbar.
          '';
        };

        merge_groups_on_drag = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether window groups can be dragged into other groups";
        };

        merge_groups_on_groupbar = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether one group will be merged with another when dragged into its groupbar";
        };

        merge_floated_into_tiled_on_groupbar = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether dragging a floating window into a tiled window groupbar will merge them";
        };

        group_on_movetoworkspace = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether using movetoworkspace[silent] will merge the window into the workspace’s solitary unlocked group";
        };

        col.border_active = mkOption {
          type = nullOr str;
          default = null;
          description = "active group border color";
        };

        col.border_inactive = mkOption {
          type = nullOr str;
          default = null;
          description = "inactive (out of focus) group border color";
        };

        col.border_locked_active = mkOption {
          type = nullOr str;
          default = null;
          description = "active locked group border color";
        };

        col.border_locked_inactive = mkOption {
          type = nullOr str;
          default = null;
          description = "inactive locked group border color";
        };

        groupbar = {
          enabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "enables groupbars";
          };

          font_family = mkOption {
            type = nullOr str;
            default = null;
            description = "font used to display groupbar titles, use misc:font_family if not specified";
          };

          font_size = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "font size of groupbar title";
          };

          font_weight_active = mkOption {
            type = nullOr font_weight;
            default = null;
            description = "font weight of active groupbar title";
          };

          font_weight_inactive = mkOption {
            type = nullOr font_weight;
            default = null;
            description = "font weight of inactive groupbar title";
          };

          gradients = mkOption {
            type = nullOr bool;
            default = null;
            description = "enables gradients";
          };

          height = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "height of the groupbar";
          };

          indicator_gap = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "height of gap between groupbar indicator and title";
          };

          indicator_height = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "height of the groupbar indicator";
          };

          stacked = mkOption {
            type = nullOr bool;
            default = null;
            description = "render the groupbar as a vertical stack";
          };

          priority = mkOption {
            type = nullOr int;
            default = null;
            description = "sets the decoration priority for groupbars";
          };

          render_titles = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to render titles in the group bar decoration";
          };

          text_offset = mkOption {
            type = nullOr int;
            default = null;
            description = "adjust vertical position for titles";
          };

          text_padding = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "set horizontal padding for titles";
          };

          scrolling = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether scrolling in the groupbar changes group active window";
          };

          rounding = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "how much to round the indicator";
          };

          rounding_power = mkOption {
            type = nullOr (numbers.between 1 10);
            default = null;
            description = "adjusts the curve used for rounding groupbar corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
          };

          gradient_rounding = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "how much to round the gradients";
          };

          gradient_rounding_power = mkOption {
            type = nullOr (numbers.between 1 10);
            default = null;
            description = "adjusts the curve used for rounding gradient corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
          };

          round_only_edges = mkOption {
            type = nullOr bool;
            default = null;
            description = "round only the indicator edges of the entire groupbar";
          };

          gradient_round_only_edges = mkOption {
            type = nullOr bool;
            default = null;
            description = "round only the gradient edges of the entire groupbar";
          };

          text_color = mkOption {
            type = nullOr str;
            default = null;
            description = "color for window titles in the groupbar";
          };

          text_color_inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "color for inactive windows’ titles in the groupbar (if unset, defaults to text_color)";
          };

          text_color_locked_active = mkOption {
            type = nullOr str;
            default = null;
            description = "color for the active window’s title in a locked group (if unset, defaults to text_color)";
          };

          text_color_locked_inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "color for inactive windows’ titles in locked groups (if unset, defaults to text_color_inactive)";
          };

          col.active = mkOption {
            type = nullOr str;
            default = null;
            description = "active group bar background color";
          };

          col.inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "inactive (out of focus) group bar background color";
          };

          col.locked_active = mkOption {
            type = nullOr str;
            default = null;
            description = "active locked group bar background color";
          };

          col.locked_inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "inactive locked group bar background color";
          };

          gaps_in = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "gap size between gradients";
          };

          gaps_out = mkOption {
            type = nullOr ints.unsigned;
            default = null;
            description = "gap size between gradients and window";
          };

          keep_upper_gap = mkOption {
            type = nullOr bool;
            default = null;
            description = "add or remove upper gap";
          };

          blur = mkOption {
            type = nullOr bool;
            default = null;
            description = "applies blur to the groupbar indicators and gradients";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.group = lib.filterAttrsRecursive (_: v: v != null) cfg;
      };
    };
}
