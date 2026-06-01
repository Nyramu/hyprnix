{ lib, hyprlib, ... }:
{
  flake.homeModules.master =
    { config, ... }:
    let
      inherit (lib.types) bool enum ints;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers;

      cfg = config.hyprnix.settings.master;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.master = {
        allow_small_split = mkNullable {
          type = bool;
          description = "enable adding additional master windows in a horizontal split style";
        };

        special_scale_factor = mkNullable {
          type = numbers.between 0 1;
          description = "the scale of the special workspace windows.";
        };

        mfact = mkNullable {
          type = numbers.between 0 1;
          description = "the size as a percentage of the master window, for example mfact = 0.70 would mean 70% of the screen will be the master window, and 30% the slave";
        };

        new_status = mkNullable {
          type = enum [
            "master"
            "slave"
            "inherit"
          ];
          description = ''
            master: new window becomes master;
            slave: new windows are added to slave stack;
            inherit: inherit from focused window
          '';
        };

        new_on_top = mkNullable {
          type = bool;
          description = "whether a newly open window should be on the top of the stack";
        };

        new_on_active = mkNullable {
          type = enum [
            "before"
            "after"
            "none"
          ];
          description = ''
            before, after: place new window relative to the focused window;
            none: place new window according to the value of new_on_top.
          '';
        };

        orientation = mkNullable {
          type = enum [
            "left"
            "right"
            "top"
            "bottom"
            "center"
          ];
          description = "default placement of the master area";
        };

        slave_count_for_center_master = mkNullable {
          type = ints.unsigned;
          description = ''
            when using orientation=center, make the master window centered only when at least this many slave windows are open.
            Set 0 to always center master.
          '';
        };

        center_master_fallback = mkNullable {
          type = enum [
            "left"
            "right"
            "top"
            "bottom"
          ];
          description = "Set fallback for center master when slaves are less than slave_count_for_center_master";
        };

        smart_resizing = mkNullable {
          type = bool;
          description = ''
            if enabled, resizing direction will be determined by the mouse's position on the window (nearest to which corner).
            Else, it is based on the window's tiling position.
          '';
        };

        drop_at_cursor = mkNullable {
          type = bool;
          description = ''
            when enabled, dragging and dropping windows will put them at the cursor position.
            Otherwise, when dropped at the stack side, they will go to the top/bottom of the stack depending on new_on_top.
          '';
        };

        always_keep_position = mkNullable {
          type = bool;
          description = "whether to keep the master window in its configured position when there are no slave windows";
        };

        focus_master_on_close = mkNullable {
          type = bool;
          description = "when enabled, closing a window focuses the master window";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          master = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
