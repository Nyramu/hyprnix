{ self, lib, ... }:
{
  flake.homeModules.decoration =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        nullOr
        str
        path
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers filterValidAttrs;

      cfg = config.hyprnix.settings.decoration;

      # Replace Hyprnix screen_shader option with the HM one to apply the shader
      cfg' = lib.pipe cfg [
        (lib.filterAttrsRecursive (k: _: k != "screen_shader"))
        hyprScreenShader
        filterValidAttrs
      ];

      hyprScreenShader = (
        x: x // { screen_shader = lib.mkIf (cfg.screen_shader != null) "shader.frag"; }
      );
    in
    {
      options.hyprnix.settings.decoration = {
        rounding = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "rounded corners’ radius (in layout px)";
        };

        rounding_power = mkOption {
          type = nullOr (numbers.between 1 10);
          default = null;
          description = "adjusts the curve used for rounding corners, larger is smoother, 2.0 is a circle, 4.0 is a squircle, 1.0 is a triangular corner";
        };

        active_opacity = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "opacity of active windows";
        };

        inactive_opacity = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "opacity of inactive windows";
        };

        fullscreen_opacity = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "opacity of fullscreen windows";
        };

        dim_modal = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables dimming of parents of modal windows";
        };

        dim_inactive = mkOption {
          type = nullOr bool;
          default = null;
          description = "enables dimming of inactive windows";
        };

        dim_strength = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "how much inactive windows should be dimmed";
        };

        dim_special = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "how much to dim the rest of the screen by when a special workspace is open";
        };

        dim_around = mkOption {
          type = nullOr (numbers.between 0 1);
          default = null;
          description = "how much the dim_around window rule should dim by";
        };

        screen_shader = mkOption {
          type = nullOr path;
          default = null;
          description = "a path to a custom shader to be applied at the end of rendering.";
        };

        border_part_of_window = mkOption {
          type = nullOr bool;
          default = null;
          description = "whether the window border should be a part of the window";
        };

        blur = {
          enabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "enable kawase window background blur";
          };

          size = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "blur size (distance)";
          };

          passes = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "the amount of passes to perform";
          };

          ignore_opacity = mkOption {
            type = nullOr bool;
            default = null;
            description = "make the blur layer ignore the opacity of the window";
          };

          new_optimizations = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to enable further optimizations to the blur. Recommended to leave on, as it will massively improve performance.";
          };

          xray = mkOption {
            type = nullOr bool;
            default = null;
            description = "if enabled, floating windows will ignore tiled windows in their blur. Only available if new_optimizations is true. Will reduce overhead on floating blur significantly.";
          };

          noise = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "how much noise to apply";
          };

          contrast = mkOption {
            type = nullOr (numbers.between 0 2);
            default = null;
            description = "contrast modulation for blur";
          };

          brightness = mkOption {
            type = nullOr (numbers.between 0 2);
            default = null;
            description = "brightness modulation for blur";
          };

          vibrancy = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "Increase saturation of blurred colors";
          };

          vibrancy_darkness = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "How strong the effect of vibrancy is on dark areas";
          };

          special = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to blur behind the special workspace (note: expensive)";
          };

          popups = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to blur popups (e.g. right-click menus)";
          };

          popups_ignorealpha = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "works like ignore_alpha in layer rules. If pixel opacity is below set value, will not blur";
          };

          input_methods = mkOption {
            type = nullOr bool;
            default = null;
            description = "whether to blur input methods (e.g. fcitx5)";
          };

          input_methods_ignorealpha = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "works like ignore_alpha in layer rules. If pixel opacity is below set value, will not blur";
          };
        };

        shadow = {
          enabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "enable drop shadows on windows";
          };

          range = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "Shadow range (\"size\") in layout px";
          };

          render_power = mkOption {
            type = nullOr (ints.between 1 4);
            default = null;
            description = "in what power to render the falloff (more power, the faster the falloff)";
          };

          sharp = mkOption {
            type = nullOr bool;
            default = null;
            description = "if enabled, will make the shadows sharp, akin to an infinite render power";
          };

          ignore_window = mkOption {
            type = nullOr bool;
            default = null;
            description = "if true, the shadow will not be rendered behind the window itself, only around it.";
          };

          color = mkOption {
            type = nullOr str;
            default = null;
            description = "shadow’s color. Alpha dictates shadow’s opacity.";
          };

          color_inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "inactive shadow color. (if not set, will fall back to color)";
          };

          offset = mkOption {
            type = nullOr (numbers.tuple 2);
            default = null;
            description = "shadow’s rendering offset.";
          };

          scale = mkOption {
            type = nullOr (numbers.between 0 1);
            default = null;
            description = "shadow's scale";
          };
        };

        glow = {
          enabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "enable inner glow on windows";
          };

          range = mkOption {
            type = nullOr ints.positive;
            default = null;
            description = "Glow range (\"size\") in layout px";
          };

          render_power = mkOption {
            type = nullOr (ints.between 1 4);
            default = null;
            description = "in what power to render the falloff (more power, the faster the falloff)";
          };

          color = mkOption {
            type = nullOr str;
            default = null;
            description = "glow’s color. Alpha dictates glow’s opacity.";
          };

          color_inactive = mkOption {
            type = nullOr str;
            default = null;
            description = "inactive glow color. (if not set, will fall back to color)";
          };
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings = {
          decoration = lib.mkIf (cfg' != { }) cfg';
        };

        # Create a symlink for the shader
        xdg.configFile = lib.mkIf (cfg.screen_shader != null) {
          "hypr/shader.frag".source = cfg.screen_shader;
        };
      };
    };
}
