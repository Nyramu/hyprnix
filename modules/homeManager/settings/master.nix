{ self, lib, ... }:
{
  flake.homeModules.master =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        enum
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.master;
    in
    {
      options.hyprnix.settings.master = {
        allow_small_split = mkOption {
          type = nullOr bool;
          default = null;
          description = "enable adding additional master windows in a horizontal split style";
        };

        special_scale_factor = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "the scale of the special workspace windows.";
        };

        mfact = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "the size as a percentage of the master window, for example mfact = 0.70 would mean 70% of the screen will be the master window, and 30% the slave";
        };

        new_status = mkOption {
          type = nullOr (enum [
            "master"
            "slave"
            "inherit"
          ]);
          default = null;
          description = ''
            master: new window becomes master;
            slave: new windows are added to slave stack;
            inherit: inherit from focused window
          '';
        };

        new_on_top = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether a newly open window should be on the top of the stack";
        };

        new_on_active = mkOption {
          type = nullOr (enum [
            "before"
            "after"
            "none"
          ]);
          default = null;
          description = ''
            before, after: place new window relative to the focused window;
            none: place new window according to the value of new_on_top.
          '';
        };

        orientation = mkOption {
          type = nullOr (enum [
            "left"
            "right"
            "top"
            "bottom"
            "center"
          ]);
          default = null;
          description = "default placement of the master area";
        };

        slave_count_for_center_master = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = ''
            when using orientation=center, make the master window centered only when at least this many slave windows are open.
            Set 0 to always center master.
          '';
        };

        center_master_fallback = mkOption {
          type = nullOr (enum [
            "left"
            "right"
            "top"
            "bottom"
          ]);
          default = null;
          description = "Set fallback for center master when slaves are less than slave_count_for_center_master";
        };

        smart_resizing = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            if enabled, resizing direction will be determined by the mouse’s position on the window (nearest to which corner).
            Else, it is based on the window’s tiling position.
          '';
        };

        drop_at_cursor = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            when enabled, dragging and dropping windows will put them at the cursor position.
            Otherwise, when dropped at the stack side, they will go to the top/bottom of the stack depending on new_on_top.
          '';
        };

        always_keep_position = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether to keep the master window in its configured position when there are no slave windows";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.master = lib.filterAttrs (_: v: v != null) cfg;
      };
    };
}
