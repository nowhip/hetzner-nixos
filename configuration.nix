{ pkgs, ... }:
 
 {
   nix.settings = {
     experimental-features = "nix-command flakes";
   };
   
   environment.systemPackages = [
     pkgs.git
   ];
   
   fileSystems."/" = {
     device = "/dev/disk/by-label/nixos";
     fsType = "ext4";
   };
   fileSystems."/boot" = {
     device = "/dev/disk/by-label/boot";
     fsType = "ext4";
   };
   swapDevices = [
     {
       device = "/dev/disk/by-label/swap";
     }
   ];
   
   time.timeZone = "Europe/London";
   i18n.defaultLocale = "en_US.UTF-8";
   console.keyMap = "us";
   
   boot.loader.grub.enable = true;
   boot.loader.grub.device = "/dev/sda";
   boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];
   
   users.users = {
     root.hashedPassword = "!"; # Disable root login
     selim = {
       isNormalUser = true;
       extraGroups = [ "wheel" ];
       openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOoPbdeg6m8b7fWa6Og/yNespDkC69mj0frS1pfk0SxP selim"
       ];
     };
     daniil = {
       isNormalUser = true;
       openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsJHmi82YhxJd4f7Cmh5O0k5WkakyOn7o8b5JXqA4xM daniil"
       ];
     };
     boris = {
       isNormalUser = true;
       openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhMNIBDVF0CY6eoCOQatiUzqKNUHr8vFJUaOqwRVCOf boris"
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
   
   networking.hostName = "selims-server";

   networking.firewall.allowedTCPPorts = [ 22 ];

   system.stateVersion = "24.11";
 }
