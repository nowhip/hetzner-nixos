{ config, pkgs, ... }:

{
  nix.settings = { experimental-features = "nix-command flakes"; };

  environment.systemPackages = [ pkgs.git pkgs.nixfmt-classic ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules =
    [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];

  users.users = {
    root.hashedPassword = "!"; # Disable root login
    selim = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoPbdeg6m8b7fWa6Og/yNespDkC69mj0frS1pfk0SxP selim@computer"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID7Y2QfGe+ZIaz/HK13wP2QEeoJGpUhtlqaYMEDofqPa selim@laptop"
      ];
    };
    daniil = {
      isNormalUser = true;
      group = "users";
      homeMode = "770";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsJHmi82YhxJd4f7Cmh5O0k5WkakyOn7o8b5JXqA4xM daniil@computer"
      ];
      packages = with pkgs; [ python3 asciiquarium ];
    };
    boris = {
      isNormalUser = true;
      group = "users";
      homeMode = "770";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhMNIBDVF0CY6eoCOQatiUzqKNUHr8vFJUaOqwRVCOf boris@computer"
      ];
    };
    erkin = {
      isNormalUser = true;
      group = "users";
      homeMode = "770";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL4DEcXxqjv6irSJMhkaovNbQ+swy8UHmb2l6dakp2nw erkin@computer"
      ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  systemd.services = {
    latch-landing-page = {
      description = "latch-landing-page";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [ bash nodejs_22 ];

      serviceConfig = {
        User = "selim";
        WorkingDirectory = "/opt/latch-landing-page";
        ExecStart = "${pkgs.nodejs_22}/bin/npm run start";
        Restart = "always";
      };
    };

    ws-landing-page = {
      description = "ws-landing-page";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      path = with pkgs; [ bash nodejs_22 ];

      serviceConfig = {
        User = "selim";
        WorkingDirectory = "/opt/ws-landing-page";
        ExecStart = "${pkgs.nodejs_22}/bin/npm run start";
        Restart = "always";
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "latch-dating.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:3000";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };

      "www.latch-dating.de" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "latch-dating.de";
      };

      "ws-boardinghouse.de" = {
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:3001";
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };

      "www.ws-boardinghouse.de" = {
        enableACME = true;
        forceSSL = true;
        globalRedirect = "ws-boardinghouse.de";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "latch-dating.de" = {
        email = "selim@latch-dating.de";
        webroot = "/var/lib/acme/acme-challenge";
      };
      "www.latch-dating.de" = {
        email = "selim@latch-dating.de";
        webroot = "/var/lib/acme/acme-challenge";
      };
      "ws-boardinghouse.de" = {
        email = "info@ws-boardinghouse.de";
        webroot = "/var/lib/acme/acme-challenge";
      };
      "www.ws-boardinghouse.de" = {
        email = "info@ws-boardinghouse.de";
        webroot = "/var/lib/acme/acme-challenge";
      };
    };
  };

  networking.hostName = "selims-server";

  networking.firewall.allowedTCPPorts = [ 80 443 22 ];

  system.stateVersion = "24.11";
}
