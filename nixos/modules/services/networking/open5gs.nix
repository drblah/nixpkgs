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

  componentNames = [
    "amf" "bsf" "mme" "nssf" "pcrf" "sepp1" "sgwc" "smf" "udr" "ausf" "hss" "nrf" "pcf" "scp" "sepp2" "sgwu" "udm" "upf"
  ];

  mkComponentOption = name: lib.mkOption {
    description = "Open5GS ${name} configuration";
    default = {};
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "Open5GS ${name} service";
        settings = lib.mkOption {
          type = settingsYaml.type;
          default = import ./open5gs/default-${name}.nix;
          description = "Settings for ${name}";
        };
      };
    };
  };

  enabledComponents = lib.filterAttrs
    (name: value: lib.elem name componentNames && value.enable)
    cfg;

in
{
  options.services.open5gs = (lib.genAttrs componentNames mkComponentOption) // {
    package = lib.mkPackageOption pkgs "open5gs" { };
  };

  config = lib.mkIf (enabledComponents != { }) {
    # Only install the package if at least one submodule is enabled
    environment.systemPackages = [ cfg.package ];

    # Dynamically generate /etc/open5gs/<name>.yaml only for enabled submodules
    environment.etc = lib.mapAttrs' (name: value:
      lib.nameValuePair "open5gs/${name}.yaml" {
        source = settingsYaml.generate "${name}.yaml" value.settings;
      }
    ) enabledComponents;
  };
}
