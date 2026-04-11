{ lib, ... }:
{
  flake.homeModules.input =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        ;
      inherit (lib.types.ints)
        between
        ;

      cfg = config.hyprnix.settings.input.virtualkeyboard;
    in
    {
      options.hyprnix.settings.input.virtualkeyboard = {
        share_states = mkOption {
          type = nullOr (between 0 2);
          default = null;
          description = ''
            Unify key down states and modifier states with other keyboards.
            0 -> no.
            1 -> yes.
            2 -> yes unless IME client.
          '';
        };

        release_pressed_on_close = mkOption {
          type = nullOr bool;
          default = null;
          description = "Release all pressed keys by virtual keyboard on close.";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.input = {
          virtualkeyboard = lib.filterAttrsRecursive (_: v: v != null) cfg;
        };
      };
    };
}
