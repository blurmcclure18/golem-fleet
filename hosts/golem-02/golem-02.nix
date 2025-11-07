{ config, pkgs, ... }:

{
 imports = [
	../common.nix
	./hardware-configuration.nix
 ];
 
  networking.hostName = "golem-02";

  # Optional: configure static IP or WiFi here
}

