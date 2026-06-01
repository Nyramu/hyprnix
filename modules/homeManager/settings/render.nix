{ lib, hyprlib, ... }:
{
  flake.homeModules.render =
    { config, ... }:
    let
      inherit (lib.types)
        bool
        str
        enum
        ints
        ;

      inherit (hyprlib.utils) filterValidAttrs recursiveMkPreferred mkNullable;

      cfg = config.hyprnix.settings.render;
      cfg' = lib.pipe cfg [
        filterValidAttrs
        recursiveMkPreferred
      ];
    in
    {
      options.hyprnix.settings.render = {
        direct_scanout = mkNullable {
          type = enum [
            0
            1
            2
          ];
          description = ''
            Enables direct scanout. Direct scanout attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game).
            It is also recommended to set this to 0 if the fullscreen application shows graphical glitches.
            0 - off, 1 - on, 2 - auto (on with content type ‘game’)
          '';
        };

        expand_undersized_textures = mkNullable {
          type = bool;
          description = "Whether to expand undersized textures along the edge, or rather stretch the entire texture.";
        };

        xp_mode = mkNullable {
          type = bool;
          description = "Disables back buffer and bottom layer rendering.";
        };

        ctm_animation = mkNullable {
          type = ints.unsigned;
          description = "Whether to enable a fade animation for CTM changes (hyprsunset). 2 means “auto” which disables them on Nvidia.";
        };

        cm_enabled = mkNullable {
          type = bool;
          description = "Whether the color management pipeline should be enabled or not (requires a restart of Hyprland to fully take effect)";
        };

        send_content_type = mkNullable {
          type = bool;
          description = "Report content type to allow monitor profile autoswitch (may result in a black screen during the switch)";
        };

        cm_auto_hdr = mkNullable {
          type = ints.between 0 2;
          description = ''
            Auto-switch to HDR in fullscreen when needed.
            0 - off, 1 - switch to "cm, hdr," 2 - switch to "cm, hdredid"
          '';
        };

        new_render_scheduling = mkNullable {
          type = bool;
          description = "Automatically uses triple buffering when needed, improves FPS on underpowered devices.";
        };

        non_shader_cm = mkNullable {
          type = ints.between 0 3;
          description = ''
            Enable CM without shader.
            0 - disable, 1 - whenever possible,
            2 - DS and passthrough only, 3 - disable and ignore CM issues
          '';
        };

        non_shader_cm_interop = mkNullable {
          type = ints.between 0 2;
          description = ''
            0 - external ctm (hypersunset, etc.) is disabled in fullscreen
            1 - external ctm is enabled in fullscreen
            2 - external ctm is disabled for fullscreen photo/video/game content types
          '';
        };

        cm_sdr_eotf = mkNullable {
          type = str;
          description = ''
            Default transfer function for displaying SDR apps.
            default - Use default value (Gamma 2.2),
            gamma22 - Treat unspecified as Gamma 2.2,
            gamma22force - Treat unspecified and sRGB as Gamma 2.2,
            srgb - Treat unspecified as sRGB
          '';
        };

        commit_timing_enabled = mkNullable {
          type = bool;
          description = "Enable commit timing proto. Requires restart";
        };

        use_fp16 = mkNullable {
          type = ints.between 0 2;
          description = ''
            Use FP16 buffers internally
            0 - disabled
            1 - enabled
            2 - enabled in hdr mode
          '';
        };

        keep_unmodified_copy = mkNullable {
          type = ints.between 0 2;
          description = ''
            Keep umodified SDR frame copy for sreensharing
            0 - disabled
            1 - on
            2 - auto (enabled in HDR with SDR modifiers)
            Set to 1 if screenshots are transparent
          '';
        };

        use_shader_blur_blend = mkNullable {
          type = bool;
          description = ''
            Use experimental blurred bg blending (glitched on rotated screens)
            Set to true if blur is missing with fp16 or keep_unmodified_copy
          '';
        };
      };

      config = {
        # Only write actually set values to avoid noise in the file
        wayland.windowManager.hyprland.settings.config = {
          render = lib.mkIf (cfg' != { }) cfg';
        };
      };
    };
}
