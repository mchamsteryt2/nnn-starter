{
  pkgs,
  inputs,
  ...
}: {
  # The Noctalia desktop shell: bar, launcher, notifications, control center,
  # lock screen and wallpaper, all in one. Colors follow Stylix.
  programs.noctalia = {
    enable = true;

    # Prebuilt package from noctalia.cachix.org (see modules/nixos/noctalia.nix).
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Run as a systemd user service tied to the graphical (niri) session so it
    # starts and stops with your login.
    systemd.enable = true;

    # REGISTER SOURCING HUBS: Noctalia clones these and discovers ALL available plugins inside them automatically.
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

    # DECLARE ACTIVE LIST: You just list the folder names you want enabled. 
    # Noctalia automatically maps, downloads, and spins them up on boot.
    plugins.enabled = [
      "noctalia/screen_recorder"
      "noctalia/calculator"
      "noctalia/timer"
      "community/niri-workspaces"
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
{
  pkgs,
  inputs,
  ...
}: {
  # The Noctalia desktop shell: bar, launcher, notifications, control center,
  # lock screen and wallpaper, all in one. Colors follow Stylix.
  programs.noctalia = {
    enable = true;

    # Prebuilt package from noctalia.cachix.org (see modules/nixos/noctalia.nix).
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Run as a systemd user service tied to the graphical (niri) session so it
    # starts and stops with your login.
    systemd.enable = true;

    # Configure the shell interactively via its control center (Mod+Space →
    # settings) and, once you're happy, pin the values declaratively here under
    # `settings = { ... };` (schema at docs.noctalia.dev). Left at defaults so
    # the build can't break on a settings key that doesn't exist yet.
  };
}
