{ lib, hyprlib, ... }:
{
  flake.homeModules.input =
    { ... }:
    let
      inherit (lib.types) bool;
      inherit (lib.types.ints) between;
      inherit (hyprlib.utils) mkNullable;
    in
    {
      options.hyprnix.settings.input.virtualkeyboard = {
        share_states = mkNullable {
          type = between 0 2;
          description = ''
            Unify key down states and modifier states with other keyboards.
            0 -> no.
            1 -> yes.
            2 -> yes unless IME client.
          '';
        };

        release_pressed_on_close = mkNullable {
          type = bool;
          description = "Release all pressed keys by virtual keyboard on close.";
        };
      };
    };
}
