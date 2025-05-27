# chez-ccamel

🗄️ My personal configuration files (dotfiles...) managed by [chezmoi][chezmoi-website]

<img src="./banner.webp" alt="banner" width="100%">

[![chezmoi][chezmoi-badge]][chezmoi-website]
[![lint-ci-badge][lint-ci-badge]][lint-ci-workflow]
[![commits-badge][commits-badge]][commits-page]

## Prerequisites

Targets macOS and requires the following tools:

- [chezmoi][chezmoi-website]
- [git][git-website]
- [homebrew][homebrew-website]

## Use

### Initial setup

Run the following command:

```sh
chezmoi init ccamel/chez-ccamel
```

### Update

Apply the latest changes from your repo with:

```sh
chezmoi update -v
```

[chezmoi-website]: https://chezmoi.io
[chezmoi-badge]: https://img.shields.io/badge/Powered%20by-chezmoi-blue.svg?style=for-the-badge
[git-website]: https://git-scm.com/
[homebrew-website]: https://brew.sh/
[lint-ci-badge]: https://img.shields.io/github/actions/workflow/status/ccamel/chez-ccamel/lint.yml?branch=main&label=lint&style=for-the-badge&logo=github
[lint-ci-workflow]: https://github.com/ccamel/chez-ccamel/actions/workflows/lint.yml
[commits-badge]: https://img.shields.io/github/last-commit/ccamel/chez-ccamel/main?style=for-the-badge&logo=github&color=%237dcfff
[commits-page]: https://github.com/ccamel/chez-ccamel/commits/main
