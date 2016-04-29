{ config, lib, pkgs, ... }:

with lib;

let

  makeUpdateRelease = type: releaseName: mainJob:
    { timers."update-${releaseName}" =
      { wantedBy = [ "timers.target" ];
        timerConfig.OnUnitInactiveSec = 600;
        timerConfig.OnBootSec = 900;
        timerConfig.AccuracySec = 300;
      };

      services."update-${releaseName}" =
        { description = "Update Release ${releaseName}";
          after = [ "networking.target" ];
          script =
            ''
              source /etc/profile
              cd /home/gall/alx-hydra-tools
              exec ./release.pl ${type} http://hydra.net.switch.ch/job/${mainJob}/latest-finished
            ''; # */
            serviceConfig.User = "gall";
        };
    };

in

{
  environment.systemPackages = with pkgs.perlPackages;
      [ LWP LWPProtocolHttps FileSlurp];
      
  systemd =
    fold recursiveUpdate {}
      [ (makeUpdateRelease "ALX" "release-15.09" "ALX/release-15.09/upgradeCommand")
        (makeUpdateRelease "ALX" "release-16.03" "ALX/release-16.03/upgradeCommand")
        #(makeUpdateRelease "ALX" "release-unstable" "ALX/release-unstable/upgradeCommand")
        (makeUpdateRelease "installer" "installer" "ALX/installer/nfsRootTarball")
      ];

}
