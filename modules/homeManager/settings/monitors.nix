{ lib, hyprlib, ... }:
{
  flake.homeModules.monitors =
    { config, ... }:
    let
      inherit (lib) mkOption;
      inherit (lib.types)
        bool
        number
        str
        int
        ints
        path

        enum
        either
        listOf
        submodule
        ;
      inherit (hyprlib.types) numbers;
      inherit (hyprlib.utils) filterValidAttrs mkPreferred mkNullable;

      cfg = config.hyprnix.settings.monitors;
      cfg' = lib.pipe cfg [
        (map filterValidAttrs)
        (map mkPreferred)
        (map mkLuaMonitor)
      ];

      mkLuaMonitor = m: { _args = [ m ]; };

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
            type = numbers.positive;
            default = 1;
            description = "Monitor scale factor";
          };

          disabled = mkNullable {
            type = bool;
            description = "Whether to disable the monitor";
          };

          transform = mkNullable {
            type = ints.between 0 7;
            description = "Rotation/flip (0=normal, 1=90°, 2=180°, 3=270°, 4=flipped, 5=flipped+90°, 6=flipped+180°, 7=flipped+270°)";
          };

          mirror = mkNullable {
            type = str;
            description = "Mirror another monitor output";
            example = "DP-1";
          };

          bitdepth = mkNullable {
            type = enum [
              8
              10
            ];
            description = "Color bit depth";
          };

          cm = mkNullable {
            type = str;
            description = "Color management preset";
            example = "srgb";
          };

          sdr_eotf = mkNullable {
            type = enum [
              "default"
              "gamma22"
              "srgb"
            ];
            description = "SDR transfer function";
          };

          sdrbrightness = mkNullable {
            type = number;
            description = "SDR brightness in HDR mode";
          };

          sdrsaturation = mkNullable {
            type = number;
            description = "SDR brightness in HDR mode";
          };

          vrr = mkNullable {
            type = ints.between 0 3;
            description = "Variable Refresh Rate (0=off, 1=on, 2=fullscreen only, 3=fullscreen with video or game content type)";
          };

          icc = mkNullable {
            type = either str path;
            description = "Absolute path to an ICC profile";
          };

          reserved_area = mkNullable {
            type = either int reservedAreaType;
            description = "integer for all sides or table with top/right/bottom/left";
          };

          supports_wide_color = mkNullable {
            type = ints.between (-1) 1;
            description = "Force wide color gamut support (0=auto, 1=force on, -1=force off)";
          };

          supports_hdr = mkNullable {
            type = ints.between (-1) 1;
            description = "Force HDR support, requires wide color (0=auto, 1=force on, -1=force off)";
          };

          sdr_min_luminance = mkNullable {
            type = number;
            description = "SDR minimum luminance for SDR→HDR mapping (0.005 for true black matching HDR black)";
          };

          sdr_max_luminance = mkNullable {
            type = number;
            description = "SDR maximum luminance for SDR→HDR mapping (nits)";
          };

          min_luminance = mkNullable {
            type = number;
            description = "Minimum luminance of the monitor (nits)";
          };

          max_luminance = mkNullable {
            type = number;
            description = "Peak luminance of the monitor (nits)";
          };

          max_avg_luminance = mkNullable {
            type = number;
            description = "Maximum average luminance of the monitor (nits)";
          };
        };
      };

      reservedAreaType = submodule {
        options = {
          top = mkNullable { type = number; };

          bottom = mkNullable { type = number; };

          left = mkNullable { type = number; };

          right = mkNullable { type = number; };
        };
      };
    in
    {
      options.hyprnix.settings = {
        monitors = mkOption {
          type = listOf monitorType;
          default = [ ];
          description = "Hyprland monitors configuration";
          example = [
            {
              output = "DP-1";
              mode = "1920x1080@100";
              position = "auto";
              scale = 1;
            }
          ];
        };
      };

      config = {
        wayland.windowManager.hyprland.settings = {
          monitor = cfg';
        };
      };
    };
}
