{
  pkgs,
  inputs,
  ...
}: {
  # The Noctalia desktop shell: bar, launcher, notifications, control center,
  # lock screen and wallpaper, all in one. Colors follow Stylix.
  programs.noctalia = {
    enable = true;

    # FIXED: Wraps the prebuilt cache package to bake native Git, Curl, and Coreutils 
    # directly into the runtime context, stopping downloads from crashing and vanishing.
    package = (inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/noctalia-shell \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.wget pkgs.curl pkgs.coreutils ]}
      '';
    }));

    # Run as a systemd user service tied to the graphical (niri) session so it
    # starts and stops with your login.
    systemd.enable = true;

    # FIXED REGISTER SOURCING HUBS: Restored precise target paths instead of flat root domains.
    # Leaving out the rigid static list lets you safely manage activations directly in the UI.
    plugins.sources = [
      {
        enabled = true;
        name = "Official Noctalia Plugins";
        url = "https://github.com/noctalia-dev/official-plugins";
      }
      {
        enabled = true;
        name = "Community Noctalia Plugins";
        url = "https://github.com/noctalia-dev/community-plugins";
      }
    ];

    # Configure the shell appearance options natively right inside the module layout
    settings = {
      bar = {
        position = "top";
        density = "compact";
      };
    };
  };
}
