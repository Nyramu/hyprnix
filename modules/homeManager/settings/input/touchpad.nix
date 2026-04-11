{ lib, ... }:
{
  flake.homeModules.input =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        number
        nullOr
        enum
        ;
      inherit (lib.types.ints)
        between
        ;

      cfg = config.hyprnix.settings.input.touchpad;
    in
    {
      options.hyprnix.settings.input.touchpad = {
        disable_while_typing = mkOption {
          type = nullOr bool;
          default = null;
          description = "Disable the touchpad while typing.";
        };

        natural_scroll = mkOption {
          type = nullOr bool;
          default = null;
          description = "Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.";
        };

        scroll_factor = mkOption {
          type = nullOr number;
          default = null;
          description = "Multiplier applied to the amount of scroll movement.";
        };

        middle_button_emulation = mkOption {
          type = nullOr bool;
          default = null;
          description = "Sending LMB and RMB simultaneously will be interpreted as a middle click. This disables any touchpad area that would normally send a middle click based on location.";
        };

        tap_button_map = mkOption {
          type = nullOr (enum [
            "lrm"
            "lmr"
          ]);
          default = null;
          description = "Sets the tap button mapping for touchpad button emulation. Can be one of lrm (default) or lmr (Left, Middle, Right Buttons). [lrm/lmr]";
        };

        clickfinger_behavior = mkOption {
          type = nullOr bool;
          default = null;
          description = "Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB respectively. This disables interpretation of clicks based on location on the touchpad.";
        };

        tap-to-click = mkOption {
          type = nullOr bool;
          default = null;
          description = "Tapping on the touchpad with 1, 2, or 3 fingers will send LMB, RMB, and MMB respectively.";
        };

        drag_lock = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = "When enabled, lifting the finger off while dragging will not drop the dragged item. 0 -> disabled, 1 -> enabled with timeout, 2 -> enabled sticky.";
        };

        tap-and-drag = mkOption {
          type = nullOr bool;
          default = null;
          description = "Sets the tap and drag mode for the touchpad";
        };

        flip_x = mkOption {
          type = nullOr bool;
          default = null;
          description = "inverts the horizontal movement of the touchpad";
        };

        flip_y = mkOption {
          type = nullOr bool;
          default = null;
          description = "inverts the vertical movement of the touchpad";
        };

        drag_3fd = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = "enables three finger drag, 0 -> disabled, 1 -> 3 fingers, 2 -> 4 fingers";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.input = {
          touchpad = lib.filterAttrsRecursive (_: v: v != null) cfg;
        };
      };
    };
}
