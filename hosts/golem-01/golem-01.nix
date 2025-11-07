{ config, pkgs, ... }:

{
  imports = [
  	../common.nix
	./hardware-configuration.nix
	];
  networking.hostName = "golem-01";

  time.timeZone = "America/Chicago";

  # Optional: configure static IP or WiFi here
}

