# Hyprnix

> This project is intended to work with the **latest Hyprland version**, thus
> using **nixpkgs unstable** is the recommended approach.

A wrapper for
[Home Manager's Hyprland module](https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/hyprland.nix),
greatly inspired by [this](https://github.com/hyprland-community/hyprnix)
Hyprnix project.

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

We try our best to make `hyprnix` options match `wayland.windowManager.hyprland`
ones. If you have your flake's `inputs` passed down to your Home Manager
configuration, you can use the module in `imports` somewhere. Here is a minimal
example of what you could do:

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
    settings = {
      xwayland.enabled = true;

      bind = {
        "SUPER + RETURN".dispatcher.exec_cmd = "kitty";
        "SUPER + E".dispatcher.exit = {};
      };
    
      monitors = [
        {
          output = "DP-1";
          mode = "1920x1080@100";
          position = "auto";
        }
      ];
      
      # etc...
    };
  };
}
```

<details>
  <summary><b>Here are more options you can add to your config</b></summary>

```nix
# home.nix
{ inputs, ... }:

{
  imports = [
    inputs.hyprnix.homeModules.default
  ];

  hyprnix = {
    settings = {
      bind = {
        "SUPER + 1".dispatcher.focus.workspace = "1";
        "SUPER + SHIFT + 1".dispatcher.window.move = {
          workspace = "1";
          follow = true;
        };
              
        "SUPER + F".dispatcher.window.fullscreen.mode = "fullscreen";
        "SUPER + M".dispatcher.window.fullscreen.mode = "maximized";

        "SUPER + mouse:272" = {
          dispatcher.window.drag = { };
          flags.mouse = true;
        };
        "SUPER + mouse:273" = {
          dispatcher.window.resize = { };
          flags.mouse = true;
        };

        XF86AudioRaiseVolume = {
          dispatcher.exec_cmd = "${lib.getExe pkgs.pamixer} -i 5";
          flags.repeating = true;
        };

        "SUPER + left".dispatcher.focus.direction = "left";
        "SUPER + right".dispatcher.focus.direction = "right";
        "SUPER + up".dispatcher.focus.direction = "up";
        "SUPER + down".dispatcher.focus.direction = "down";
      };
    
      gesture = {
        gestures = [
          {
            fingers = 3;
            direction = "pinch";
            action =  "fullscreen";
            mode = "maximize";
          }
          {
            fingers = 2;
            direction = "up";
            mods = "SUPER";
            action = "close";
          }
        ];
      };
      
      window_rule = {
        "floating-mpv" = {
          match.class = "mpv";
          float = true;
          center = true;
          size = [
            1280
            720
          ];
        } 
      };

      decoration = {
        rounding = 8;
        blur.enable = true;
        screen_shader = /home/host/myShader.frag;
      };      

      cursor = {
        hyprcursor = {
          enable = true;
          package = pkgs.rose-pine-hyprcursor;
          name = "rose-pine-hyprcursor";
          size = 36;
        };
        persistent_warps = true;
        hide_on_key_press = true;
      };

      workspace_rule = {
        "1" = {
          default = true;
          persistent = true;
        };
        "2".persistent = true;
      };

      curve = {
        bezier = {
          holo = [ 0.23 1 0.32 1 ];
          data = [ 0.16 1 0.3 1 ];
        };
      };

      animation = {
        windowsIn = {
          speed = 5;
          bezier = "holo";
          style = "slide";
        };
        windowsOut = {
          speed = 4;
          bezier = "holo";
          style = "popin 100%";
        };
        windowsMove = {
          speed = 5;
          bezier = "holo";
          style = "slide";
        };
        fade = {
          speed = 5;
          bezier = "data";
        };
      };

      general = {
        border_size = 2;
        layout = "scrolling";
        col = {
          active_border = "rgb(ffffff)";
          inactive_border = "rgba(26, 26, 26, 0.90)";
        };
      };

      misc = {
        force_default_wallpaper = 0;
        session_lock_xray = true;
        vfr = true;
      };
            
      # etc...
    };

    # it's recommended to add the "#lua" comment to activate the lua highlight on most editors
    extraConfig =
    # lua
    ''
      -- Extra configuration lines to append to the bottom of`~/.config/hypr/hyprland.lua`
      -- Mostly needed to specify special configs that need the lua syntax

      hl.bind(keys, hl.dsp.exec_cmd("amongus"), { release = true, locked = true })

      hl.bind("SUPER + SHIFT + X", function()
        -- some logic...
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
      end)

      hl.on("workspace.move_to_monitor", function(ws, m)
        hl.notification.create({
          text = "Workspace: " .. ws.name .. " moved to a monitor at x: " .. m.position.x,
          timeout = 4000,
          icon = "ok"
        })
      end)
    '';
  };
}
```

</details>

## Why should I use this Hyprnix?

While it mostly works, the other Hyprnix is, unfortunately, rarely updated. This
makes it prone to rebuild errors and warnings, mainly because some options get
deprecated, or some dependencies get replaced/renamed. We want to **preserve**
its advantages while also trying to enhance its structure, **without breaking
compatibility** with Hyprland's Home Manager module. Here are some reasons to
use it:

- Easy to install and configure
- Entirely based on Home Manager's `wayland.windowManager.hyprland` options, to
  ensure compatibility
- Enhanced syntax for keybinds, windowrules, gestures and other Hyprland options
- Hyprnix-exclusive options like `hyprnix.settings.cursor.hyprcursor.*` that
  make the experience more comfortable. More examples in the configurations above
- Config errors (mostly) make the rebuild crash, in line with NixOS logic
- Gets updated whenever Hyprland changes/adds/removes an option

## Contributing

You can help this project by making a pull request or reporting an issue. If you
want to try generating local documentation, you can do it by using the
`cachix use hyprnix` command.

## Credits

- [Hyprland](https://github.com/hyprwm/Hyprland)
- [Home Manager](https://github.com/nix-community/home-manager)
- [Hyprnix (the original)](https://github.com/hyprland-community/hyprnix)
- [Cachix](https://github.com/cachix/cachix)
- [ndg](https://github.com/feel-co/ndg)
