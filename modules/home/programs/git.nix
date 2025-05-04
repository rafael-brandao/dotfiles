{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.git;

  rewriteProtocolType = with types; nullOr (enum ["https" "ssh"]);

  gitProviderModuleFor = domain: let
    type = types.submodule {
      options = {
        domain = mkOption {
          type = types.str;
          default = domain;
          internal = true;
          readOnly = true;
        };
        rewriteProtocol = mkOption {
          type = rewriteProtocolType;
          default = cfg.providers.rewriteProtocol;
          description = ''
            Force a protocol rewrite when accessing ${domain}.
            Possible values: https, ssh or null.
          '';
        };
      };
    };
  in
    mkOption {
      inherit type;
      default = {};
      description = "Options related to git cloud provider '${domain}'";
    };
in {
  options.programs.git = {
    provider = {
      bitbucket = gitProviderModuleFor "bitbucket.com";
      github = gitProviderModuleFor "github.com";
      gitlab = gitProviderModuleFor "gitlab.com";
    };
    providers = {
      rewriteProtocol = mkOption {
        type = rewriteProtocolType;
        default = null;
        description = ''
          Force protocol rewrite for the main git providers: github, gitlab and bitbucket.
          Possible values: https, ssh or null.
        '';
      };
    };
  };

  config.programs.git = mkIf cfg.enable (mkMerge (forEach (attrNames cfg.provider) (
    providerName: let
      provider = cfg.provider.${providerName};
    in {
      extraConfig.url = {
        "https://${provider.domain}/".insteadOf = mkIf (provider.rewriteProtocol == "https") "git@${provider.domain}:";
        "git@${provider.domain}:".insteadOf = mkIf (provider.rewriteProtocol == "ssh") "https://${provider.domain}/";
      };
    }
  )));
}
