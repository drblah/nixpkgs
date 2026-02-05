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

  hssDefaultConfig = import ./open5gs/default-hss.nix;
  hssConfig = settingsYaml.generate "hss.yaml" cfg.hss.settings;

  mmeDefaultConfig = import ./open5gs/default-mme.nix;
  mmeConfig = settingsYaml.generate "mme.yaml" cfg.mme.settings;
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
        Open5GS Mobility Management Entity
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Mobility Management Entity";

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

    hss = lib.mkOption {
      description = ''
        Open5GS Home Subscriber Server
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Home Subscriber Server";

          settings = lib.mkOption {
            type = settingsYaml.type;
            default = hssDefaultConfig;
            example = lib.literalExpression ''
              logger = {
                file = {
                  path = "/var/log/open5gs/hss.log";
                };
              };
            '';
            description = ''
              Open5GS hss config file...
            '';
          };
        };
      };
    };

    mme = lib.mkOption {
      description = ''
        Open5GS Mobility Management Entity
      '';
      default = { };
      type = submodule {
        options = {
          enable = lib.mkEnableOption "Mobility Management Entity";

          settings = lib.mkOption {
            type = settingsYaml.type;
            default = mmeDefaultConfig;
            example = lib.literalExpression ''
              logger = {
                file = {
                  path = "/var/log/open5gs/mme.log";
                };
              };
            '';
            description = ''
              Open5GS mme config file...
            '';
          };
        };
      };
    };

  };

  config = lib.mkIf (cfg.amf.enable || cfg.ausf.enable || cfg.bsf.enable || cfg.hss.enable || cfg.mme.enable) (
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

      (lib.mkIf cfg.hss.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/hss.yaml".source = hssConfig;

      })

      (lib.mkIf cfg.mme.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/mme.yaml".source = mmeConfig;

      })
    ]
  );

}
