{ lib, hyprlib, ... }:
{
  flake.homeModules.decoration =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        number
        path
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;
      inherit (hyprlib.types) numbers tuple;
      inherit (hyprlib.types.hyprland) gradient;

      cfg = config.hyprnix.settings.decoration;

      # Replace Hyprnix screen_shader option with the HM one to apply the shader
      cfg' = lib.pipe cfg [
        (lib.filterAttrsRecursive (k: _: k != "screen_shader"))
        hyprScreenShader
        filterValidAttrs
        recursiveMkPreferred
      ];

      hyprScreenShader = (
        x: x // { screen_shader = if (cfg.screen_shader != null) then "shader.frag" else null; }
      );
    in
    {
      options.hyprnix.settings.decoration = {
        rounding = mkNullable {
          type = ints.unsigned;
          description = "rounded corners' radius (in layout px)";
        };

        rounding_power = mkNullable {
          type = numbers.between 1 10;
          description = "adjusts the curve used for rounding corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
        };

        active_opacity = mkNullable {
          type = numbers.between 0 1;
          description = "opacity of active windows";
        };

        inactive_opacity = mkNullable {
          type = numbers.between 0 1;
          description = "opacity of inactive windows";
        };

        fullscreen_opacity = mkNullable {
          type = numbers.between 0 1;
          description = "opacity of fullscreen windows";
        };

        dim_modal = mkNullable {
          type = bool;
          description = "enables dimming of parents of modal windows";
        };

        dim_inactive = mkNullable {
          type = bool;
          description = "enables dimming of inactive windows";
        };

        dim_strength = mkNullable {
          type = numbers.between 0 1;
          description = "how much inactive windows should be dimmed";
        };

        dim_special = mkNullable {
          type = numbers.between 0 1;
          description = "how much to dim the rest of the screen by when a special workspace is open";
        };

        dim_around = mkNullable {
          type = numbers.between 0 1;
          description = "how much the dim_around window rule should dim by";
        };

        screen_shader = mkNullable {
          type = path;
          description = "a path to a custom shader to be applied at the end of rendering.";
        };

        border_part_of_window = mkNullable {
          type = bool;
          description = "whether the window border should be a part of the window";
        };

        blur = {
          enabled = mkNullable {
            type = bool;
            description = "enable kawase window background blur";
          };

          size = mkNullable {
            type = ints.positive;
            description = "blur size (distance)";
          };

          passes = mkNullable {
            type = ints.positive;
            description = "the amount of passes to perform";
          };

          ignore_opacity = mkNullable {
            type = bool;
            description = "make the blur layer ignore the opacity of the window";
          };

          new_optimizations = mkNullable {
            type = bool;
            description = "whether to enable further optimizations to the blur. Recommended to leave on, as it will massively improve performance.";
          };

          xray = mkNullable {
            type = bool;
            description = "if enabled, floating windows will ignore tiled windows in their blur. Only available if new_optimizations is true. Will reduce overhead on floating blur significantly.";
          };

          noise = mkNullable {
            type = numbers.between 0 1;
            description = "how much noise to apply";
          };

          contrast = mkNullable {
            type = numbers.between 0 2;
            description = "contrast modulation for blur";
          };

          brightness = mkNullable {
            type = numbers.between 0 2;
            description = "brightness modulation for blur";
          };

          vibrancy = mkNullable {
            type = numbers.between 0 1;
            description = "Increase saturation of blurred colors";
          };

          vibrancy_darkness = mkNullable {
            type = numbers.between 0 1;
            description = "How strong the effect of vibrancy is on dark areas";
          };

          special = mkNullable {
            type = bool;
            description = "whether to blur behind the special workspace (note: expensive)";
          };

          popups = mkNullable {
            type = bool;
            description = "whether to blur popups (e.g. right-click menus)";
          };

          popups_ignorealpha = mkNullable {
            type = numbers.between 0 1;
            description = "works like ignore_alpha in layer rules. If pixel opacity is below set value, will not blur";
          };

          input_methods = mkNullable {
            type = bool;
            description = "whether to blur input methods (e.g. fcitx5)";
          };

          input_methods_ignorealpha = mkNullable {
            type = numbers.between 0 1;
            description = "works like ignore_alpha in layer rules. If pixel opacity is below set value, will not blur";
          };
        };

        shadow = {
          enabled = mkNullable {
            type = bool;
            description = "enable drop shadows on windows";
          };

          range = mkNullable {
            type = ints.positive;
            description = ''Shadow range ("size") in layout px'';
          };

          render_power = mkNullable {
            type = ints.between 1 4;
            description = "in what power to render the falloff (more power, the faster the falloff)";
          };

          sharp = mkNullable {
            type = bool;
            description = "if enabled, will make the shadows sharp, akin to an infinite render power";
          };

          color = mkNullable {
            type = gradient;
            description = "shadow's color. Alpha dictates shadow's opacity.";
          };

          color_inactive = mkNullable {
            type = gradient;
            description = "inactive shadow color. (if not set, will fall back to color)";
          };

          offset = mkNullable {
            type = tuple number 2;
            description = "shadow's rendering offset.";
          };

          scale = mkNullable {
            type = numbers.between 0 1;
            description = "shadow's scale";
          };
        };

        glow = {
          enabled = mkNullable {
            type = bool;
            description = "enable inner glow on windows";
          };

          range = mkNullable {
            type = ints.positive;
            description = ''Glow range ("size") in layout px'';
          };

          render_power = mkNullable {
            type = ints.between 1 4;
            description = "in what power to render the falloff (more power, the faster the falloff)";
          };

          color = mkNullable {
            type = gradient;
            description = "glow's color. Alpha dictates glow's opacity.";
          };

          color_inactive = mkNullable {
            type = gradient;
            description = "inactive glow color. (if not set, will fall back to color)";
          };
        };

        motion_blur = {
          enabled = mkNullable {
            type = bool;
            description = "enable motion blur on moving / resizing windows";
          };

          samples = mkNullable {
            type = ints.positive;
            description = "The amount of samples to render. More will mean clearer blur, at the cost of more compute.";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          decoration = lib.mkIf (cfg' != { }) cfg';
        };

        # Create a symlink for the shader
        xdg.configFile = lib.mkIf (cfg.screen_shader != null) {
          "hypr/shader.frag".source = cfg.screen_shader;
        };
      };
    };
}
