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

  # 1. FIXED: Leverage the official Noctalia Greeter module cleanly
  # This automatically sets up services.greetd, registers the 'greeter' user, 
  # configures dbus wrappers, and resolves the Mesa shader caching permission flags.
  programs.noctalia-greeter = {
    enable = true;
    
    # Passes required session hooks down to the launcher automation script
    greeter-args = "--session niri-session";

    # Declaratively populates /var/lib/noctalia-greeter/greeter.toml perfectly
    settings = {
      session = {
        default = "niri-session";
      };
      appearance = {
        cursor_theme = "Bibata-Modern-Ice";
        cursor_size = 24;
      };
    };
  };

  # 2. Required systemic backends for user profiles & seat authentication
  security.polkit.enable = true;
  services.accounts-daemon.enable = true; # Required by noctalia-greeter for user profiles

  # Brightness keys are handled by brightnessctl (installed in desktop.nix),
  # which talks to logind and needs no extra privileges in a session.
}
