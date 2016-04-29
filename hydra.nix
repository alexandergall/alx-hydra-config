{ config, lib, pkgs, ...}:

let
  hydraSrc = builtins.fetchTarball https://github.com/NixOS/hydra/tarball/dc790c5f7eacda1c819ae222bf87674781ae1124;
in
      
{
  imports = [
    "${hydraSrc}/hydra-module.nix"
    ./alx-release.nix
  ];

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.net.switch.ch";
    notificationSender = "gall@switch.ch";
    port = 8080;
    listenHost = "localhost";
  };

  # security.acme.certs = {
  #   "hydra.net.switch.ch" = {
  #     email = "gall@switch.ch";
  #     user = "nginx";
  #     group = "nginx";
  #     webroot = "/var/www/challenges";
  #     postRun = "systemctl reload nginx.service";
  #   };
  # };
					  
  services.nginx = {
    enable = true;
    httpConfig = ''
      server_names_hash_bucket_size 64;
      keepalive_timeout   70;
      gzip            on;
      gzip_min_length 1000;
      gzip_proxied    expired no-cache no-store private auth;
      gzip_types      text/plain application/xml application/javascript application/x-javascript text/javascript text/xml text/css;
      server {
        server_name hydra.net.switch.ch;
  	listen 80;
  	listen [::]:80;
        location / {
          proxy_pass http://127.0.0.1:8080;
  	  proxy_set_header Host $http_host;
  	  proxy_set_header REMOTE_ADDR $remote_addr;
  	  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  	  proxy_set_header X-Forwarded-Proto http;
        }
     }
      server {
        server_name ALX.net.switch.ch;
  	listen 80;
  	listen [::]:80;
	location /releases/ {
	  root /data;
	  autoindex on;
	}
     }
   '';
  };

  services.postgresql = {

  package = pkgs.postgresql94;
    dataDir = "/var/db/postgresql-${config.services.postgresql.package.psqlSchema}";
  };

  networking = {
    firewall.allowedTCPPorts = [ 80 ];
    hostName = "hydra";
  };
}
