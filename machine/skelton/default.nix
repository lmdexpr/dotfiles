{ username, ... }:
let
  hostName = "skelton";
in 
{
  imports = [
    ../../os/wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = username;

  networking = { inherit hostName; };
}
