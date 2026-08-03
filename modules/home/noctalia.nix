{
  pkgs,
  inputs,
  ...
}: {
  # The Noctalia desktop shell: bar, launcher, notifications, control center,
  # lock screen and wallpaper, all in one. Colors follow Stylix.
  programs.noctalia = {
    enable = true;

    # FIXED: Wrap the default package to inject explicit runtime dependencies.
    # This guarantees that when you click download in the GUI, the background 
    # engine can find 'git' and 'bin' paths cleanly so the downloads don't fail.
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

    # REGISTER SOURCING HUBS: Discover and index ALL available plugins automatically.
    # By omitting the rigid "plugins.enabled" list, we allow the UI to handle toggles natively.
    plugins.sources = [
      {
        enabled = true;
        name = "Official Noctalia Plugins";
        url = "https://github.com";
      }
      {
        enabled = true;
        name = "Community Noctalia Plugins";
        url = "https://github.com";
      }
    ];

    # Sane defaults for global layout settings
    settings = {
      bar = {
        position = "top";
        density = "compact";
      };
    };
  };
}
