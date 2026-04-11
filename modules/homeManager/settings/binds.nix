{ lib, ... }:
{
  flake.homeModules.binds =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        enum
        ints
        ;

      cfg = config.hyprnix.settings.binds;
    in
    {
      options.hyprnix.settings.binds = {
        pass_mouse_when_bound = mkOption {
          type = nullOr bool;
          default = null;
          description = "if disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.";
        };

        scroll_event_delay = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "in ms, how many ms to wait after a scroll event to allow passing another one for the binds.";
        };

        workspace_back_and_forth = mkOption {
          type = nullOr bool;
          default = null;
          description = ''
            If enabled, an attempt to switch to the currently focused workspace will instead switch to the previous workspace.
            Akin to i3’s auto_back_and_forth.
          '';
        };

        hide_special_on_workspace_change = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, changing the active workspace (including to itself) will hide the special workspace on the monitor where the newly active workspace resides.";
        };

        allow_workspace_cycles = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, workspaces don’t forget their previous workspace, so cycles can be created by switching to the first workspace in a sequence, then endlessly going to the previous workspace.";
        };

        workspace_center_on = mkOption {
          type = nullOr (enum [
            0
            1
          ]);
          default = null;
          description = "Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)";
        };

        focus_preferred_method = mkOption {
          type = nullOr (enum [
            0
            1
          ]);
          default = null;
          description = ''
            sets the preferred focus finding method when using focuswindow/movewindow/etc with a direction.
            0 - history (recent have priority)
            1 - length (longer shared edges have priority)
          '';
        };

        ignore_group_lock = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, dispatchers like moveintogroup, moveoutofgroup and movewindoworgroup will ignore lock per group.";
        };

        movefocus_cycles_fullscreen = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, when on a fullscreen window, movefocus will cycle fullscreen, if not, it will move the focus in a direction.";
        };

        movefocus_cycles_groupfirst = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, when in a grouped window, movefocus will cycle windows in the groups first, then at each ends of tabs, it’ll move on to other windows/groups";
        };

        window_direction_monitor_fallback = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor in that direction.";
        };

        disable_keybind_grabbing = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.";
        };

        allow_pin_fullscreen = mkOption {
          type = nullOr bool;
          default = null;
          description = "If enabled, Allow fullscreen to pinned windows, and restore their pinned status afterwards";
        };

        drag_threshold = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "Movement threshold in pixels for window dragging and c/g bind flags. 0 to disable and grab on mousedown.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.binds = lib.filterAttrs (_: v: v != null) cfg;
      };
    };
}
