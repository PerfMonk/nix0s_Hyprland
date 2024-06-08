#  nix.settings.experimental-features = [ "nix-command" "flakes" ];
# Config personalisé de BT 
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# 
#  nix.settings.experimental-features = [ "nix-command" "flakes" ];
{ config, pkgs, libs, ... }:
 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ###./hyprland.nix
    ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # luks
  boot.initrd.luks.devices = {
    cryptdata = {
      device = "/dev/disk/by-uuid/cd33bffd-2f26-45c1-ae93-e43e9e06fcdc";
      preLVM = true;
    };
  };

  #  networking.hostName = "nixyz"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "fr_CA.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the BUDGIE Desktop Environment.
  services.displayManager.sddm.enable = true ;
  services.displayManager.sddm.wayland.enable = true ;
  services.xserver.desktopManager.budgie.enable = true;
  programs.hyprland.enable = true;
###  programs.hyprland.envVars.enable = false;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ]; };
  xdg.portal.config.common.default = "hyprland";

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "ca";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "ca";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Install flatpak service (gtk portal is required for flatpak apps)

   services.flatpak.enable = true;

   nixpkgs.config.permittedInsecurePackages = [ "freeimage-unstable-2021-11-01" ];


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bt = {
    isNormalUser = true;
    description = "Bernard Tremblay";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      alacritty
      binutils
      brightnessctl
      budgie.budgie-desktop-with-plugins
      cava
      dunst
      fastfetch
      fira-code
      fira-code-symbols
      firefox
      floorp
      font-awesome
      fontconfig
      geany
      git
      glances
      gnome.adwaita-icon-theme
      google-chrome
      grim
      gsimplecal
      gtk-engine-murrine
      gobject-introspection
      htop
      hyprpaper
      inxi
      inter
      jetbrains-mono
      kitty
      mate.mate-icon-theme
      mate.mate-icon-theme-faenza
      meslo-lgs-nf
      mpv
      mpvScripts.mpris
      mpvpaper
      nerdfonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      nwg-drawer
      orchis-theme
      osmo
      papirus-icon-theme
      parted
      pavucontrol
      pciutils
      playerctl
      psmisc
      python3
      python311Packages.pip
      python311Packages.pygobject3
      pywal	
      ranger
      roboto
      wofi
      slurp
      source-code-pro
      swayidle
      swaylock
      swww
      twemoji-color-font
      terminus_font_ttf
      udev-gothic-nf
      vlc
      waybar
      wev
      wget
      wl-clipboard
      wlr-randr
      wlogout
      wofi
      wofi-emoji
      wtype
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      xsensors
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Configure Hyprland
  ### On prend les défauts ###

  security.pam.services.swaylock.text = ''
    # Account management.
    account required pam_unix.so

    # Authentication management.
    auth sufficient pam_unix.so   likeauth try_first_pass
    auth required pam_deny.so

    # Password management.
    password sufficient pam_unix.so nullok sha512

    # Session management.
    session required pam_env.so conffile=/etc/pam/environment readenv=0
    session required pam_unix.so
  '';


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    virt-manager
    wget
    unzip
    zip
    gvfs
    udisks
    libcamera
    pkgs.megasync
    pkgs.libsForQt5.polkit-kde-agent
    pkgs.polkit
    pkgs.polkit_gnome
    tlp
    borgbackup
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

    nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
  ];

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.tlp.enable = true ;

  #services.flatpak.enable = true;
  ### then to add flathub run in shell: 
  ###  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Automatic Garbage Collection
  nix.gc = {
                automatic = true;
                dates = "monthly";
                options = "--delete-older-than 28d";
        };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
