{ pkgs, inputs, lib, config, ... }: {

  # Safety mechanism: refuse to build unless everything is tracked by git
  system.configurationRevision = if (inputs.self ? rev) then inputs.self.rev else throw "refusing to build: git tree is dirty";

  # inputs is not available within containers, so set the package outside
  environment.defaultPackages = with pkgs; [
    inputs.agenix.packages.x86_64-linux.default
  ];
}
