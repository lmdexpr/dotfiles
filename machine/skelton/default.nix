{ ... }:

{
  imports = [
    ../../os/wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  networking.hostName = "skelton";
}
