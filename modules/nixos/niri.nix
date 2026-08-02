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

  # 1. Keep the structural greetd service unit enabled
  services.greetd = {
    enable = true;
    
    settings.default_session = {
      # Instead of tuigreet, invoke Noctalia's custom greeter compositor from your flake input
      command = "${inputs.noctalia-greeter.packages.${pkgs.system}.default}/bin/noctalia-greeter-compositor --session niri-session";
      user = "greeter";
    };
  };

  # 2. Add the greeter user to the video group to ensure it can open the display
  users.users.greeter.extraGroups = [ "video" ];

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
  services.accountsservice.enable = true; 


  # Brightness keys are handled by brightnessctl (installed in desktop.nix),
  # which talks to logind and needs no extra privileges in a session.
}
