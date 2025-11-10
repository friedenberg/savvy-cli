
default: build

build-nix-gomod:
  gomod2nix

build-nix: build-nix-gomod
  nix build

build: build-nix
