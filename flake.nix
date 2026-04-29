{
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     vscode-server.url = "github:nix-community/nixos-vscode-server";
   };
 
   outputs = { nixpkgs, vscode-server, ... }: {
     nixosConfigurations = {
       selims-server = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [
           ./configuration.nix
           vscode-server.nixosModules.default
           {
             services.vscode-server.enable = true;
           }
         ];
       };
     };
   };
}
