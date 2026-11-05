{ lib, hyprlib, ... }:
{
  flake.homeModules.binds =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.binds;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.binds = {
        pass_mouse_when_bound = mkNullable {
          type = bool;
          description = "if disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.";
        };

        scroll_event_delay = mkNullable {
          type = ints.between 0 2000;
          description = "in ms, how many ms to wait after a scroll event to allow passing another one for the binds.";
        };

        workspace_back_and_forth = mkNullable {
          type = ints.between 0 2;
          description = ''
            An attempt to switch to the currently focused workspace will instead switch to the previous workspace.
            0 - disabled, 1 - all_monitors, 2 - per_monitor
          '';
        };

        hide_special_on_workspace_change = mkNullable {
          type = bool;
          description = "If enabled, changing the active workspace will hide the special workspace on the monitor.";
        };

        allow_workspace_cycles = mkNullable {
          type = bool;
          description = "If enabled, workspaces don't forget their previous workspace.";
        };

        workspace_center_on = mkNullable {
          type = ints.between 0 1;
          description = "Whether switching workspaces should center the cursor on the workspace (0) or on the last active window (1).";
        };

        focus_preferred_method = mkNullable {
          type = ints.between 0 1;
          description = "sets the preferred focus finding method when using focuswindow/movewindow/etc with a direction.";
        };

        ignore_group_lock = mkNullable {
          type = bool;
          description = "If enabled, dispatchers like moveintogroup, moveoutofgroup and movewindoworgroup will ignore lock per group.";
        };

        movefocus_cycles_fullscreen = mkNullable {
          type = bool;
          description = "If enabled, when on a fullscreen window, movefocus will cycle fullscreen.";
        };

        movefocus_cycles_groupfirst = mkNullable {
          type = bool;
          description = "If enabled, when in a grouped window, movefocus will cycle windows in the groups first.";
        };

        disable_keybind_grabbing = mkNullable {
          type = bool;
          description = "If enabled, apps that request keybinds to be disabled will not be able to do so.";
        };

        window_direction_monitor_fallback = mkNullable {
          type = bool;
          description = "If enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor.";
        };

        allow_pin_fullscreen = mkNullable {
          type = bool;
          description = "Allows fullscreen to pinned windows, and restore their pinned status afterwards.";
        };

        client_requested_fs_uses_layout_handler = mkNullable {
          type = bool;
          description = "If false, client requested fullscreen will use the default fullscreen handler.";
        };

        drag_threshold = mkNullable {
          type = ints.unsigned;
          description = "Movement threshold in pixels for window dragging and c/g bind flags. 0 to disable.";
        };

        drag_center_window = mkNullable {
          type = bool;
          description = "If enabled, dragging a tiled or fullscreen window will center it on the cursor when it becomes floating.";
        };
      };

      config = {
        wayland.windowManager.hyprland.settings.config = {
          # Only write actually set values to avoid noise in the file
          binds = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
