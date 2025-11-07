{ config, pkgs, ... }:

{
  time.timeZone = "America/Chicago";

  users.users.golem = {
    isSystemUser = true;
    home = "/var/lib/golem";
  };

  systemd.services.golem-provider = {
    description = "Golem Provider Node";
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.yagna}/bin/yagna service run";
      Restart = "always";
      User = "golem";
      WorkingDirectory = "/var/lib/golem";
      Environment = "RUST_LOG=info";
    };
  };

  networking.firewall.allowedTCPPorts = [ 40102 ];
  networking.firewall.allowedUDPPorts = [ 40102 ];

  networking.wireless = {
	enable = true;

	networks = {
	  "Guest" = {
	      priority = 10;
	      auth = "none";
	  };
	};

	useDHCP = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [ 
  	curl 
	jq 
	git

  ];
}

