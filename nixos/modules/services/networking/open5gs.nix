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
  };

  config = lib.mkIf (cfg.amf.enable) (
    lib.mkMerge [
      (lib.mkIf cfg.amf.enable {
        environment.systemPackages = [ cfg.package ];

        environment.etc."open5gs/amf.yaml".source = amfConfig;

      })
    ]
  );

}
