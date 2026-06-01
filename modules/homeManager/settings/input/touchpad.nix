{ lib, hyprlib, ... }:
{
  flake.homeModules.input =
    { ... }:
    let
      inherit (lib.types) bool number enum;
      inherit (lib.types.ints) between;
      inherit (hyprlib.utils) mkNullable;
    in
    {
      options.hyprnix.settings.input.touchpad = {
        disable_while_typing = mkNullable {
          type = bool;
          description = "Disable the touchpad while typing.";
        };

        natural_scroll = mkNullable {
          type = bool;
          description = "Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.";
        };

        scroll_factor = mkNullable {
          type = number;
          description = "Multiplier applied to the amount of scroll movement.";
        };

        middle_button_emulation = mkNullable {
          type = bool;
          description = ''
            Sending LMB and RMB simultaneously will be interpreted as a middle click.
            This disables any touchpad area that would normally send a middle click based on location.
          '';
        };

        tap_button_map = mkNullable {
          type = enum [
            "lrm"
            "lmr"
          ];
          description = "Sets the tap button mapping for touchpad button emulation. Can be one of lrm (default) or lmr (Left, Middle, Right Buttons)";
        };

        clickfinger_behavior = mkNullable {
          type = bool;
          description = ''
            Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB respectively.
            This disables interpretation of clicks based on location on the touchpad.
          '';
        };

        tap-to-click = mkNullable {
          type = bool;
          description = "Tapping on the touchpad with 1, 2, or 3 fingers will send LMB, RMB, and MMB respectively.";
        };

        drag_lock = mkNullable {
          type = between 0 2;
          description = ''
            When enabled, lifting the finger off while dragging will not drop the dragged item.
            0 -> disabled.
            1 -> enabled with timeout.
            2 -> enabled sticky.
          '';
        };

        tap-and-drag = mkNullable {
          type = bool;
          description = "Sets the tap and drag mode for the touchpad";
        };

        flip_x = mkNullable {
          type = bool;
          description = "inverts the horizontal movement of the touchpad";
        };

        flip_y = mkNullable {
          type = bool;
          description = "inverts the vertical movement of the touchpad";
        };

        drag_3fd = mkNullable {
          type = between 0 2;
          description = ''
            enables three finger drag.
            0 -> disabled.
            1 -> 3 fingers.
            2 -> 4 fingers.
          '';
        };
      };
    };
}
