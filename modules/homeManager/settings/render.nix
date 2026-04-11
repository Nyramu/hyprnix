{ self, lib, ... }:
{
  flake.homeModules.render =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        number
        str
        nullOr
        enum
        ints
        ;

      inherit (self.lib.hyprnix.types) numbers;

      cfg = config.hyprnix.settings.render;
    in
    {
      options.hyprnix.settings.render = {
        direct_scanout = mkOption {
          type = nullOr (enum [
            0
            1
            2
          ]);
          default = null;
          description = ''
            Enables direct scanout. Direct scanout attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game).
            It is also recommended to set this to false if the fullscreen application shows graphical glitches.
            0 - off, 1 - on, 2 - auto (on with content type ‘game’)
          '';
        };

        expand_undersized_textures = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether to expand undersized textures along the edge, or rather stretch the entire texture.";
        };

        xp_mode = mkOption {
          type = nullOr bool;
          default = null;
          description = "Disables back buffer and bottom layer rendering.";
        };

        ctm_animation = mkOption {
          type = nullOr ints.unsigned;
          default = null;
          description = "Whether to enable a fade animation for CTM changes (hyprsunset). 2 means “auto” which disables them on Nvidia.";
        };

        cm_fs_passthrough = mkOption {
          type = nullOr (enum [
            0
            1
            2
          ]);
          default = null;
          description = ''
            Passthrough color settings for fullscreen apps when possible.
            0 - off, 1 - always, 2 - hdr only
          '';
        };

        cm_enabled = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether the color management pipeline should be enabled or not (requires a restart of Hyprland to fully take effect)";
        };

        send_content_type = mkOption {
          type = nullOr bool;
          default = null;
          description = "Report content type to allow monitor profile autoswitch (may result in a black screen during the switch)";
        };

        cm_auto_hdr = mkOption {
          type = nullOr (enum [
            0
            1
            2
          ]);
          default = null;
          description = ''
            Auto-switch to HDR in fullscreen when needed.
            0 - off, 1 - switch to "cm, hdr," 2 - switch to "cm, hdredid"
          '';
        };

        new_render_scheduling = mkOption {
          type = nullOr bool;
          default = null;
          description = "Automatically uses triple buffering when needed, improves FPS on underpowered devices.";
        };

        non_shader_cm = mkOption {
          type = nullOr (enum [
            0
            1
            2
            3
          ]);
          default = null;
          description = ''
            Enable CM without shader.
            0 - disable, 1 - whenever possible,
            2 - DS and passthrough only, 3 - disable and ignore CM issues
          '';
        };

        cm_sdr_eotf = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            Default transfer function for displaying SDR apps.
            default - Use default value (Gamma 2.2),
            gamma22 - Treat unspecified as Gamma 2.2,
            gamma22force - Treat unspecified and sRGB as Gamma 2.2,
            srgb - Treat unspecified as sRGB
          '';
        };

        commit_timing_enabled = mkOption {
          type = nullOr bool;
          default = null;
          description = "Enable commit timing proto. Requires restart";
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.render = lib.filterAttrs (_: v: v != null) cfg;
      };
    };
}
