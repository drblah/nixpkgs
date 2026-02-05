{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.open5gs;

  settingsYaml = pkgs.formats.yaml {};

  amfDefaultConfig = import ./open5gs/default-amf.nix;
  amfConfig = settingsYaml.generate "amf.yaml" cfg.amf.settings;

  ausfDefaultConfig = import ./open5gs/default-ausf.nix;
  ausfConfig = settingsYaml.generate "ausf.yaml" cfg.ausf.settings;

  bsfDefaultConfig = import ./open5gs/default-bsf.nix;
  bsfConfig = settingsYaml.generate "bsf.yaml" cfg.bsf.settings;
in
{
  options.services.open5gs = with lib.types; {
    package = lib.mkPackageOption pkgs "open5gs" { };

    amf = lib.mkOption {
      description = ''
        Open5GS Access and Mobility Management Function
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Access and Mobility Management Function";

          settings = lib.mkOption {
            type = settingsYaml.type;
            default = amfDefaultConfig;
            example = lib.literalExpression ''
              logger = {
                file = {
                  path = "/var/log/open5gs/amf.log";
                };
              };
            '';
            description = ''
              Open5GS AMF config file...
            '';
          };
        };
      };
    };

    ausf = lib.mkOption {
      description = ''
        Open5GS Authentication Server Function
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Authentication Server Function";

          settings = lib.mkOption {
            type = settingsYaml.type;
            default = ausfDefaultConfig;
            example = lib.literalExpression ''
              logger = {
                file = {
                  path = "/var/log/open5gs/ausf.log";
                };
              };
            '';
            description = ''
              Open5GS AUSF config file...
            '';
          };
        };
      };
    };


    bsf = lib.mkOption {
      description = ''
        Open5GS Binding Support Function
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Binding Support Function";

          settings = lib.mkOption {
            type = settingsYaml.type;
            default = bsfDefaultConfig;
            example = lib.literalExpression ''
              logger = {
                file = {
                  path = "/var/log/open5gs/bsf.log";
                };
              };
            '';
            description = ''
              Open5GS BSF config file...
            '';
          };
        };
      };
    };

  };

  config = lib.mkIf (cfg.amf.enable || cfg.ausf.enable || cfg.bsf.enable) (
    lib.mkMerge [
      (lib.mkIf cfg.amf.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/amf.yaml".source = amfConfig;

      })

      (lib.mkIf cfg.ausf.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/ausf.yaml".source = ausfConfig;

      })

      (lib.mkIf cfg.bsf.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/bsf.yaml".source = bsfConfig;

      })
    ]
  );

}
