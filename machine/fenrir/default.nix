{ ... }:

{
  imports = [
    <nixos-wsl/modules>
    ../../os/wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

  networking.hostName = "fenrir";
}
