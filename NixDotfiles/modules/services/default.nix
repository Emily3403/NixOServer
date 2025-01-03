# The idea of this module service system is to have a generic way to host services on different NixOS Installations.
# Everything relevant to the host, such as subdomain or ram / storage requirements, should be configured from here.
# The options that don't change on a per-host basis should be configured in `NixDotfiles/services`.
# Also, secrets should be managed from here.
{ config, lib, pkgs, ... }: { imports = [ ./Monitoring.nix ]; }
