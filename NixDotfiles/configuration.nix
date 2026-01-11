# This configuration file contains all the nix-specific code
{ pkgs, inputs, lib, config, ... }: {

  # Safety mechanism: refuse to build unless everything is tracked by git
  system.configurationRevision = if (inputs.self ? rev) then inputs.self.rev else throw "refusing to build: git tree is dirty";


#  nix.settings.download-buffer-size = 134217728;  # Double the default

  # 25.05 features
  system.rebuild.enableNg = true;

  environment.defaultPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
  ];
}
