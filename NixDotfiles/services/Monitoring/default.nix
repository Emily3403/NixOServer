{ config, lib, pkgs, ... }: { imports = [ ./Grafana.nix ./Prometheus.nix ]; }
