{ config, pkgs, ... }:

{
  imports = [
  	../common.nix
	./hardware-configuration.nix
	];

  networking.hostName = "golem-01";

  # Optional: configure static IP or WiFi here
}

