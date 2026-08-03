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
    
    settings.default_session = {
      # Running this inside dbus-run-session guarantees a proper session bus is initialized,
      # which prevents the greeter compositor from panicking when it queries display targets.
      command = "${pkgs.dbus}/bin/dbus-run-session ${inputs.noctalia-greeter.packages.${pkgs.system}.default}/bin/noctalia-greeter-session";
      user = "greeter";
    };
  };

  # 2. Section #2 has been completely removed to avoid malformed account definitions.
  # greetd handles creating its own greeter user automatically behind the scenes.

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

  # 5. Handle state folder paths securely and provide a valid cache location
  # This provisions the state directories and explicitly overrides the shader cache path
  # so that Mesa doesn't try to write to the read-only /var/empty/ directory.
  systemd.tmpfiles.rules = [
    "d /var/lib/noctalia-greeter 0755 greeter greetd - -"
    "d /var/cache/noctalia-greeter 0755 greeter greetd - -"
  ];

  # Force the greeter user to use the newly created cache folder for its shaders
  environment.variables.XDG_CACHE_HOME = "/var/cache/noctalia-greeter";

  # Brightness keys are handled by brightnessctl (installed in desktop.nix),
  # which talks to logind and needs no extra privileges in a session.
}
