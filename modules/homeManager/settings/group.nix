{ lib, hyprlib, ... }:
{
  flake.homeModules.group =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        str
        int
        enum
        either
        ints
        ;

      inherit (hyprlib.utils)
        filterValidAttrs
        mkPreferred
        recursiveMkPreferred
        mkNullable
        ;
      inherit (hyprlib.types) numbers;
      inherit (hyprlib.types.hyprland) gradient;

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
      cfg' = lib.pipe cfg [
        flattenCols
        filterValidAttrs
        recursiveMkPreferred
        fixColsPriority
      ];

      flattenCols =
        attrs:
        (removeAttrs attrs [ "col" ])
        // lib.mapAttrs' (n: v: lib.nameValuePair "col.${n}" v) (attrs.col or { })
        // {
          groupbar =
            (removeAttrs attrs.groupbar [ "col" ])
            // lib.mapAttrs' (n: v: lib.nameValuePair "col.${n}" v) (attrs.groupbar.col or { });
        };

      fixColsPriority =
        let
          wrapCols = lib.mapAttrs (n: v: if lib.hasPrefix "col." n && !(v ? _type) then mkPreferred v else v);
        in
        attrs: (wrapCols attrs) // { groupbar = wrapCols (attrs.groupbar or { }); };
    in
    {
      options.hyprnix.settings.group = {
        auto_group = mkNullable {
          type = bool;
          description = ''
            whether new windows will be automatically grouped into the focused unlocked group.
            Note: if you want to disable auto_group only for specific windows, use the "group barred" window rule instead.
          '';
        };

        insert_after_current = mkNullable {
          type = bool;
          description = "whether new windows in a group spawn after current or at group tail";
        };

        focus_removed_window = mkNullable {
          type = bool;
          description = "whether Hyprland should focus on the window that has just been moved out of the group";
        };

        drag_into_group = mkNullable {
          type = (ints.between 0 2);
          description = ''
            whether dragging a window into a unlocked group will merge them.
            0 -> disabled.
            1 -> enabled.
            2 -> only when dragging into the groupbar.
          '';
        };

        merge_groups_on_drag = mkNullable {
          type = bool;
          description = "whether window groups can be dragged into other groups";
        };

        merge_groups_on_groupbar = mkNullable {
          type = bool;
          description = "whether one group will be merged with another when dragged into its groupbar";
        };

        merge_floated_into_tiled_on_groupbar = mkNullable {
          type = bool;
          description = "whether dragging a floating window into a tiled window groupbar will merge them";
        };

        group_on_movetoworkspace = mkNullable {
          type = bool;
          description = "whether using movetoworkspace[silent] will merge the window into the workspace's solitary unlocked group";
        };

        col.border_active = mkNullable {
          type = gradient;
          description = "active group border color";
        };

        col.border_inactive = mkNullable {
          type = gradient;
          description = "inactive (out of focus) group border color";
        };

        col.border_locked_active = mkNullable {
          type = gradient;
          description = "active locked group border color";
        };

        col.border_locked_inactive = mkNullable {
          type = gradient;
          description = "inactive locked group border color";
        };

        groupbar = {
          enabled = mkNullable {
            type = bool;
            description = "enables groupbars";
          };

          disable_when_only = mkNullable {
            type = bool;
            description = "disable if contains single window. Considered only if enabled == true";
          };

          font_family = mkNullable {
            type = str;
            description = "font used to display groupbar titles, use misc:font_family if not specified";
          };

          font_size = mkNullable {
            type = ints.positive;
            description = "font size of groupbar title";
          };

          font_weight_active = mkNullable {
            type = font_weight;
            description = "font weight of active groupbar title";
          };

          font_weight_inactive = mkNullable {
            type = font_weight;
            description = "font weight of inactive groupbar title";
          };

          gradients = mkNullable {
            type = bool;
            description = "enables gradients";
          };

          height = mkNullable {
            type = ints.positive;
            description = "height of the groupbar";
          };

          indicator_gap = mkNullable {
            type = ints.unsigned;
            description = "height of gap between groupbar indicator and title";
          };

          indicator_height = mkNullable {
            type = ints.positive;
            description = "height of the groupbar indicator";
          };

          stacked = mkNullable {
            type = bool;
            description = "render the groupbar as a vertical stack";
          };

          priority = mkNullable {
            type = int;
            description = "sets the decoration priority for groupbars";
          };

          render_titles = mkNullable {
            type = bool;
            description = "whether to render titles in the group bar decoration";
          };

          text_offset = mkNullable {
            type = int;
            description = "adjust vertical position for titles";
          };

          text_padding = mkNullable {
            type = ints.unsigned;
            description = "set horizontal padding for titles";
          };

          scrolling = mkNullable {
            type = bool;
            description = "whether scrolling in the groupbar changes group active window";
          };

          rounding = mkNullable {
            type = ints.unsigned;
            description = "how much to round the indicator";
          };

          rounding_power = mkNullable {
            type = numbers.between 1 10;
            description = "adjusts the curve used for rounding groupbar corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
          };

          gradient_rounding = mkNullable {
            type = ints.unsigned;
            description = "how much to round the gradients";
          };

          gradient_rounding_power = mkNullable {
            type = numbers.between 1 10;
            description = "adjusts the curve used for rounding gradient corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
          };

          round_only_edges = mkNullable {
            type = bool;
            description = "round only the indicator edges of the entire groupbar";
          };

          gradient_round_only_edges = mkNullable {
            type = bool;
            description = "round only the gradient edges of the entire groupbar";
          };

          text_color = mkNullable {
            type = str;
            description = "color for window titles in the groupbar";
          };

          text_color_inactive = mkNullable {
            type = str;
            description = "color for inactive windows' titles in the groupbar (if unset, defaults to text_color)";
          };

          text_color_locked_active = mkNullable {
            type = str;
            description = "color for the active window's title in a locked group (if unset, defaults to text_color)";
          };

          text_color_locked_inactive = mkNullable {
            type = str;
            description = "color for inactive windows' titles in locked groups (if unset, defaults to text_color_inactive)";
          };

          col.active = mkNullable {
            type = gradient;
            description = "active group bar background color";
          };

          col.inactive = mkNullable {
            type = gradient;
            description = "inactive (out of focus) group bar background color";
          };

          col.locked_active = mkNullable {
            type = gradient;
            description = "active locked group bar background color";
          };

          col.locked_inactive = mkNullable {
            type = gradient;
            description = "inactive locked group bar background color";
          };

          gaps_in = mkNullable {
            type = ints.unsigned;
            description = "gap size between gradients";
          };

          gaps_out = mkNullable {
            type = ints.unsigned;
            description = "gap size between gradients and window";
          };

          keep_upper_gap = mkNullable {
            type = bool;
            description = "add or remove upper gap";
          };

          middle_click_close = mkNullable {
            type = bool;
            description = "whether middle clicking the groupbar closes the clicked window";
          };

          blur = mkNullable {
            type = bool;
            description = "applies blur to the groupbar indicators and gradients";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          group = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
