{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    <nixpkgs/nixos/modules/profiles/headless.nix>
    ./hydra.nix
  ];

  fileSystems."/".device = "/dev/disk/by-label/nixos";

  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.timeout = 0;

  time.timeZone = "Europe/Zurich";
  services.ntp.servers = [ "ntp.net.switch.ch" ];
    
  # Allow root logins
  services.openssh = {
    enable = true;
    permitRootLogin = "without-password";
  };

  services.cloud-init.enable = true;
  users.extraUsers.gall = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3NzaC1kc3MAAACBAOuCMNqMbu5cCTXbHFI40mBDsao9wkGHYVUV/bmCs1w4vap+pj2kY8TXZUi/O45rN90ZhWTa9HL+ptNOi5n02zN6SH3UyIRO5uQ58dJN0fPC9dn9uRe/wEdVwaQZOXnmuryDOPq0198hmimMWhUhPDL0hyCv31VB2D+rnVPHUTIHAAAAFQCC6BVJTwJV6k+icBy5PPqtvD2iQQAAAIA84QAgpuDRp6RbC47qOFQqGugLISgovvraJbKQB8z/bVlzsWzuRCl2YfG2MOnh26JusRLm9shDUHSzxGkXsWSPHWMhibC0NoeKG4sWoy/rPGsZLFltBEZiLBCnLXR/NKnUHNF/gg9Wx+VPWNz+KZMik00CrZmAVYrV3gcKtUFG+wAAAIEArYXur6MRnIUZ1vk9BOHcD3PN8JS4Ks592n7xUNbG837WFKMWm3MwsIsCkO7B2m1Qkkuvse9449UNMogMM3yaJM8KoRtX+AlFiG8DkzW0QjQ2DmGS1UPminZq2GzQRkFMANsOk0ketq9nokoRLjT3AVfI/kBIIh51sY1UKU5JEe8= gall@enigma" ];
  };

  security.sudo.extraConfig = ''
    gall ALL=(ALL:ALL) NOPASSWD: ALL
  '';


  nix = {
    trustedBinaryCaches = [ "https://cache.nixos.org" "http://hydra.net.switch.ch" ];
    buildCores = 0;
    maxJobs = 8;
    nrBuildUsers = 20;
    distributedBuilds = true;
    buildMachines = [
      { hostName = "localhost";
        system = builtins.currentSystem;
        supportedFeatures = [ "kvm" ];
	maxJobs = 8;
      }
    ];
  };
}
