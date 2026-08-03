{
  pkgs,
  ...
}: {
  # GUI desktop apps. Browsers and file managers live here rather than in the
  # CLI bundle.
  home.packages = [
    # Nautilus (GNOME Files): a sensible GTK file manager. Pairs with the gvfs
    # service enabled in modules/nixos/desktop.nix for trash + mounting, and
    # backs the browser's "open/save" file picker via the gtk xdg portal.
    pkgs.nautilus
  ];

  # Firefox Browser Configuration
  programs.firefox = {
  enable = true;
  configPath = ".config/mozilla/firefox";
};
    
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:newtab";
      };
    };
  };

  # Enforce desktop file handlers (mimics what Zen's setAsDefaultBrowser did)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

  # Export systemfallback variables so cli tools target Firefox
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  # Direct Stylix to theme your default Firefox profile with the Kanagawa palette
  stylix.targets.firefox.profileNames = ["default"];
}
