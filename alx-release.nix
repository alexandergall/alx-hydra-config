{ config, lib, pkgs, ... }:

with lib;

let

  makeUpdateRelease = releaseName: mainJob:
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
              cd /home/gall/projects/alx-hydra-tools
              exec ./alx-release.pl http://hydra.net.switch.ch/job/${mainJob}/latest-finished
            ''; # */
            serviceConfig.User = "gall";
        };
    };

in

{
  environment.systemPackages = with pkgs.perlPackages;
      [ LWP LWPProtocolHttps ];
      
  systemd =
    fold recursiveUpdate {}
      [ (makeUpdateRelease "release-15.03" "ALX/release-15.09/release")
        (makeUpdateRelease "release-16.03" "ALX/release-16.03/release")
        (makeUpdateRelease "release-unstable" "ALX/release-unstable/release")
      ];

}
