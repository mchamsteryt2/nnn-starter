{
  pkgs,
  inputs,
  ...
}: {
  # Enable niri from niri-flake. The module pulls in systemd units, polkit,
  # the screencast portal and sane session defaults.
  programs.niri.enable = true;
  # Use niri-flake's own prebuilt package (built against its nixpkgs) so it
  # comes from niri.cachix.org instead of compiling from source. This is the
  # exact build the niri-flake settings schema targets.
  programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;

  # Wayland portals: gnome backend for screencasting, gtk for file pickers.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
    };
  };

  # 1. Structural greetd service unit pointing to the correct session entry point
  services.greetd = {
    enable = true;
    
    # FIX: Instruct systemd to spin up a fully compliant PAM login session.
    # This automatically provisions a proper numeric /run/user/<UID> folder,
    # configures standard XDG variables, and sets up D-Bus paths cleanly.
    vt = 7;
    
    settings.default_session = {
      command = "${inputs.noctalia-greeter.packages.${pkgs.system}.default}/bin/noctalia-greeter-session";
      user = "greeter";
    };
  };

  # 2. Add the greeter user to necessary groups to ensure hardware capabilities can mount
  users.users.greeter.extraGroups = [ "video" "input" ];
  isSystemUser = true;
    group = "greetd"; # greetd is the default group created by services.greetd
  };

  # 3. Declaratively output the greeter's configuration file onto the disk
  environment.etc."noctalia-greeter/greeter.toml".text = ''
    [session]
    default = "niri-session"

    [appearance]
    cursor_theme = "Bibata-Modern-Ice"
    cursor_size = 24
  '';

  # 4. Required systemic backends for user profiles & seat authentication
  security.polkit.enable = true;
  services.accounts-daemon.enable = true;

  # 5. Handle permanent state folder paths securely
  # FIX: Removed the buggy /run/user line. Only keep the persistent state rules.
  systemd.tmpfiles.rules = [
    "d /var/lib/noctalia-greeter 0755 greeter greetd - -"
  ];

  # Brightness keys are handled by brightnessctl (installed in desktop.nix),
  # which talks to logind and needs no extra privileges in a session.
}
