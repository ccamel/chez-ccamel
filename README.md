# chez-ccamel

> 🗄️ My machines. My tools. My environment.

<img src="./banner.webp" alt="banner" width="100%">

[![powered by Nix][powered-by-nix-badge]][powered-by-nix-link]
[![lint-nix-badge][lint-nix-badge]][lint-nix-workflow]
[![build-nix-badge][build-nix-badge]][build-nix-workflow]
[![commits-badge][commits-badge]][commits-page]

[powered-by-nix-badge]: https://img.shields.io/badge/Powered_by-Nix-5277C3.svg?style=for-the-badge&logo=nixos&logoColor=white
[powered-by-nix-link]: https://nixos.org/
[lint-nix-badge]: https://img.shields.io/github/actions/workflow/status/ccamel/chez-ccamel/lint-nix.yml?branch=main&label=Lint%20%2F%20Nix&style=for-the-badge&logo=github
[lint-nix-workflow]: https://github.com/ccamel/chez-ccamel/actions/workflows/lint-nix.yml
[build-nix-badge]: https://img.shields.io/github/actions/workflow/status/ccamel/chez-ccamel/build-nix.yml?branch=main&label=Build%20%2F%20Nix&style=for-the-badge&logo=github
[build-nix-workflow]: https://github.com/ccamel/chez-ccamel/actions/workflows/build-nix.yml
[commits-badge]: https://img.shields.io/github/last-commit/ccamel/chez-ccamel/main?style=for-the-badge&logo=github&color=%237dcfff
[commits-page]: https://github.com/ccamel/chez-ccamel/commits/main

If it's not here, it doesn't exist.

## Bootstrap

Clone the repository using an ephemeral Git shell:

```sh
mkdir -p ~/src/mine
cd ~/src/mine

nix shell nixpkgs#git \
  --command git clone https://github.com/ccamel/chez-ccamel.git
```

Apply the system configuration:

```sh
sudo nixos-rebuild switch \
  --flake ~/src/mine/chez-ccamel/nix-config#forge
```

That's it.
