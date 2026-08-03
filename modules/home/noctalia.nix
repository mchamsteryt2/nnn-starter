{
  pkgs,
  inputs,
  ...
}: {
  # 1. Force Home Manager to automatically create the missing plugin and data directories
  # This guarantees that Noctalia's GUI download engine has a valid, writable path ready
  home.activation = {
    createNoctaliaPaths = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.local/share/noctalia/plugins
      $DRY_RUN_CMD mkdir -p $HOME/.local/state/noctalia/plugins/materialized
      $DRY_RUN_CMD mkdir -p $HOME/.config/noctalia
    '';
  };

  # 2. Configure the Noctalia shell module parameters safely
  programs.noctalia = {
    enable = true;

    # Wraps the default cache package to bake native Git, Curl, and Coreutils 
    # directly into the runtime context so dynamic downloads can run
    package = (inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      postInstall = (oldAttrs.postInstall or "") + ''
        wrapProgram $out/bin/noctalia-shell \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.git pkgs.wget pkgs.curl pkgs.coreutils ]}
      '';
    }));

    # Run as a systemd user service tied to the graphical session
    systemd.enable = true;

    # FIXED NESTING: 'plugins' has been nested directly inside 'settings' 
    # so that Home Manager recognizes the schema layout perfectly.
    settings = {
      bar = {
        position = "top";
        density = "compact";
      };

      # Index your remote catalogs automatically right here inside settings
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
    };
  };
}
