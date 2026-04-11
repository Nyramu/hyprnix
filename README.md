# Hyprnix
> **WORK IN PROGRESS** - Check the configuration steps below!

A wrapper for [Home Manager's Hyprland module](https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/hyprland.nix),
greatly inspired by [this](https://github.com/hyprland-community/hyprnix) Hyprnix project.

## Quickstart
See the full docs [here](https://nyramu.github.io/hyprnix)

### Installation
Add the flake as an input.
```nix
# flake.nix
{
  inputs = {
    hyprnix = {
      url = "github:Nyramu/hyprnix";
      inputs.nixpkgs.follows = "nixpkgs"; # Recommended
    };
  };
}
```

### Configuration
> **Disclaimer**:
> As we said earlier, this project is a work-in-progress, so not all options are available or working at this time.
> The options shown in the following example are currently available.
> You can temporarily set the rest of the config by using the `hyprnix.extraConfig` option.
> We will update this section as soon as possible.

We try our best to make `hyprnix` options match `wayland.windowManager.hyprland` ones.
If you have your flake's `inputs` passed
down to your Home Manager configuration, you can use the module in `imports`
somewhere. The following is just an example.
```nix
# home.nix
{ inputs, ... }:

{
  imports = [
    inputs.hyprnix.homeModules.default
  ];

  hyprnix = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      monitors = [
        {
          output = "HDMI-A-1";
          mode = "1920x1080@100";
          position = "auto";
        }
        {
          output = "DP-1";
          mode = "1920x1080@100";
          position = "auto";
        }
      ];

      workspaces = [
        {
          id = 1;
          rules = {
            default = true;
            persistent = true;
          };
        }
        {
          id = 2;
          rules.persistent = true;
        }
      ];

      keybinds = {
        bind = {
          "SUPER, RETURN" = "exec, kitty";
          "SUPER, E" = "exit";
        };
        bindl = {
          # more keybinds
        };
      };
      # etc...
    };
    extraConfig = ''
      # Extra configuration lines to append to the bottom of
      # `~/.config/hypr/hyprland.conf`
    '';
  };
}
```

## Why should I use this Hyprnix?
While it mostly works, the other Hyprnix is, unfortunately, rarely updated.
This makes it prone to rebuild errors and warnings, mainly because some options get deprecated, or some dependencies get replaced/renamed.
We want to preserve its advantages while also trying to enhance its structure, without breaking compatibility with Hyprland's Home Manager module.
Here are some reasons to use it:
- Easy to install and configure
- Enhanced syntax for keybind definitions and other options
- Entirely based on Home Manager's `wayland.windowManager.hyprland` options, to ensure compatibility
- Config errors make the rebuild crash, in line with NixOS logic
- Frequent updates (until it will cover every option)

## Contributing
You can help this project by making a pull request or reporting an issue.

## Credits
- [Hyprland](https://github.com/hyprwm/Hyprland)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Hyprnix (the original)](https://github.com/hyprland-community/hyprnix)
