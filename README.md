# Usage

## apply to nixos
```sh
sudo nixos-rebuild switch --flake '.#' --show-trace
```

## apply home-manager
```sh 
home-manager switch --flake '.#nixos@nkri'
```

