# Self-hosted GitHub Actions runners for surt666/GramrEMS (label `lambda`), replacing the AWS runners.
# Registration and credentials live in ~/.local/share/gramr-runner/r<n>: run the repo's
# scripts/local-runner/setup.sh once. A runner with no registration is skipped, not crash-looped.
{ pkgs, lib, ... }:
let
  github-runner = import ./github-runner/package.nix { inherit pkgs; };
  runner = n: {
    Unit = {
      Description = "GitHub Actions runner gramr r${toString n}";
      After = [ "network-online.target" ];
      ConditionPathExists = "%h/.local/share/gramr-runner/r${toString n}/.runner";
    };
    Service = {
      Environment = [
        "RUNNER_ROOT=%h/.local/share/gramr-runner/r${toString n}"
      ];
      WorkingDirectory = "%h/.local/share/gramr-runner/r${toString n}";
      ExecStart = "${github-runner}/bin/run.sh";
      Restart = "always";
      RestartSec = 10;
      # The runner forwards SIGINT to a running job; let it finish cleanly.
      KillSignal = "SIGINT";
      TimeoutStopSec = 60;
    };
    Install.WantedBy = [ "default.target" ];
  };
in
{
  systemd.user.services = lib.listToAttrs (map (n: {
    name = "gramr-runner-r${toString n}";
    value = runner n;
  }) [ 1 2 3 ]);
}
