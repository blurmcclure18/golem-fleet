⚙️ Step 1 — Create the wallet locally

On your main (trusted) computer:

yagna service run &
yagna payment init --sender
yagna app-key create provider-key

This gives you:

Wallet address (ETH/GLM)

App key token like yagna-xxxx-xxxx-xxxx

You can view your wallet details with:

yagna payment status

Then stop the daemon and copy the key files from:

~/.local/share/yagna/

Important ones:

app_key.json (or the key printed)

yagna.db (contains wallet data)

golemsp configs

We’ll package only what’s needed.

Step 2 — Securely store your wallet in NixOS

You have a few options depending on how private you want to be:

Option A: systemd Environment File

Best if laptops are physically under your control.

Put this file on each laptop manually or via deployment automation:

/etc/yagna/env

YAGNA_APPKEY="yagna-xxxx-xxxx-xxxx"
YAGNA_DATADIR="/var/lib/golem"

Set Permissions:

sudo chmod 600 /etc/yagna/env

Then reference it in your Nix flake config (below).

Updated hosts/common.nix

Here’s how to modify your service definition:
{ config, pkgs, ... }:

{
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
      EnvironmentFile = "/etc/yagna/env";
      Environment = "RUST_LOG=info";
    };
  };

  # Optional: run the provider agent automatically
  systemd.services.golemsp = {
    description = "Golem Provider Agent";
    after = [ "golem-provider.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.yagna}/bin/golemsp run";
      Restart = "always";
      User = "golem";
      WorkingDirectory = "/var/lib/golem";
      EnvironmentFile = "/etc/yagna/env";
    };
  };

  networking.firewall.allowedTCPPorts = [ 40102 ];
  networking.firewall.allowedUDPPorts = [ 40102 ];

  services.openssh.enable = true;
}

Step 3 — Distribute with your flake

When deploying via NixOps, Colmena, or deploy-rs, you can copy the same /etc/yagna/env and (optionally) the wallet database file to /var/lib/golem/ before starting services.

Example Colmena pre-deploy hook:

colmena apply --on @all --upload-secrets ./secrets/yagna-env

Step 4 — Verify it’s working

On any laptop:

journalctl -u golem-provider -f


You should see something like:

INFO yagna::service Provider started
INFO golemsp::run Provider node registered on network

And to confirm earnings:

yagna payment status

Security Tip

Since one wallet controls all earnings:

Treat /etc/yagna/env and /var/lib/golem as secrets.

Don’t push them to Git.

If a laptop is stolen, immediately revoke the app key with:

yagna app-key revoke <key-name>

and create a new one.
