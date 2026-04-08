{ lib, ... }:
{
  flake.homeModules.monitors =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        number
        str

        nullOr
        enum
        listOf
        submodule
        addCheck
        ;

      cfg = config.hyprnix.settings;

      monitorType = submodule {
        options = {
          output = mkOption {
            type = str;
            description = "Monitor output name";
            example = "DP-1";
          };

          mode = mkOption {
            type = str;
            description = "Resolution and refresh rate";
            example = "1920x1080@60";
          };

          position = mkOption {
            type = str;
            description = "Monitor position";
            example = "0x0";
          };

          scale = mkOption {
            type = addCheck number (x: x > 0) // {
              description = "a positive number (> 0)";
            };
            default = 1;
            description = "Monitor scale factor";
          };

          disabled = mkOption {
            type = nullOr bool;
            default = null;
            description = "Whether to disable the monitor";
          };

          transform = mkOption {
            type = nullOr (enum [
              0
              1
              2
              3
              4
              5
              6
              7
            ]);
            default = null;
            description = "Rotation/flip (0=normal, 1=90°, 2=180°, 3=270°, 4=flipped, 5=flipped+90°, 6=flipped+180°, 7=flipped+270°)";
          };

          mirror = mkOption {
            type = nullOr str;
            default = null;
            description = "Mirror another monitor output";
            example = "DP-1";
          };

          bitdepth = mkOption {
            type = nullOr (enum [
              8
              10
            ]);
            default = null;
            description = "Color bit depth";
          };

          vrr = mkOption {
            type = nullOr (enum [
              0
              1
              2
              3
            ]);
            default = null;
            description = "Variable Refresh Rate (0=off, 1=on, 2=fullscreen only, 3=fullscreen with video or game content type)";
          };

          supports_wide_color = mkOption {
            type = nullOr (enum [
              (-1)
              0
              1
            ]);
            default = null;
            description = "Force wide color gamut support (0=auto, 1=force on, -1=force off)";
          };

          supports_hdr = mkOption {
            type = nullOr (enum [
              (-1)
              0
              1
            ]);
            default = null;
            description = "Force HDR support, requires wide color (0=auto, 1=force on, -1=force off)";
          };

          sdr_min_luminance = mkOption {
            type = nullOr number;
            default = null;
            description = "SDR minimum luminance for SDR→HDR mapping (0.005 for true black matching HDR black)";
          };

          sdr_max_luminance = mkOption {
            type = nullOr number;
            default = null;
            description = "SDR maximum luminance for SDR→HDR mapping (nits)";
          };

          min_luminance = mkOption {
            type = nullOr number;
            default = null;
            description = "Minimum luminance of the monitor (nits)";
          };

          max_luminance = mkOption {
            type = nullOr number;
            default = null;
            description = "Peak luminance of the monitor (nits)";
          };

          max_avg_luminance = mkOption {
            type = nullOr number;
            default = null;
            description = "Maximum average luminance of the monitor (nits)";
          };
        };
      };
    in
    {
      options.hyprnix.settings = {
        monitors = mkOption {
          type = nullOr (listOf monitorType);
          default = [ ];
          description = "Hyprland monitors configuration (monitorv2)";
          example = {
            output = "DP-1";
            mode = "1920x1080@100";
            position = "auto";
            scale = 1;
          };
        };
      };

      config =
        let
          filterNulls = m: lib.filterAttrs (_: v: v != null) m;
        in
        {
          wayland.windowManager.hyprland.settings = {
            monitorv2 = map filterNulls cfg.monitors;
          };
        };
    };
}
