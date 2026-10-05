{ pkgs }:
[
  {
    name = "direnv";
    inherit (pkgs.direnv) version;
    description = "Directory-scoped environment variables.";
    url = "https://direnv.net/";
    visibility = "public";
  }
  {
    name = "fzf";
    inherit (pkgs.fzf) version;
    description = "Fuzzy finder for the command line.";
    url = "https://github.com/junegunn/fzf";
    visibility = "public";
  }
  {
    name = "zoxide";
    inherit (pkgs.zoxide) version;
    description = "Smarter directory navigation.";
    url = "https://github.com/ajeetdsouza/zoxide";
    visibility = "public";
  }
  {
    name = "bat";
    inherit (pkgs.bat) version;
    description = "Cat clone with syntax highlighting.";
    url = "https://github.com/sharkdp/bat";
    visibility = "public";
  }
  {
    name = "Btop";
    inherit (pkgs.btop) version;
    description = "Resource monitor for the terminal.";
    url = "https://github.com/aristocratos/btop";
    visibility = "public";
  }
  {
    name = "lazydocker";
    inherit (pkgs.lazydocker) version;
    description = "Terminal UI for Docker.";
    url = "https://github.com/jesseduffield/lazydocker";
    visibility = "public";
  }
  {
    name = "Dust";
    inherit (pkgs.dust) version;
    description = "Intuitive disk usage analyzer.";
    url = "https://github.com/bootandy/dust";
    visibility = "public";
  }
  {
    name = "eza";
    inherit (pkgs.eza) version;
    description = "Modern replacement for ls.";
    url = "https://eza.rocks/";
    visibility = "public";
  }
  {
    name = "Glow";
    inherit (pkgs.glow) version;
    description = "Terminal markdown reader.";
    url = "https://github.com/charmbracelet/glow";
    visibility = "public";
  }
  {
    name = "ripgrep";
    inherit (pkgs.ripgrep) version;
    description = "Fast recursive text search.";
    url = "https://github.com/BurntSushi/ripgrep";
    visibility = "public";
  }
  {
    name = "fd";
    inherit (pkgs.fd) version;
    description = "Fast, user-friendly file finder.";
    url = "https://github.com/sharkdp/fd";
    visibility = "public";
  }
  {
    name = "jq";
    inherit (pkgs.jq) version;
    description = "Command-line JSON processor.";
    url = "https://jqlang.org/";
    visibility = "public";
  }
  {
    name = "Python";
    inherit (pkgs.python3) version;
    description = "General-purpose programming language.";
    url = "https://www.python.org/";
    visibility = "public";
  }
  {
    name = "yq";
    inherit (pkgs.yq-go) version;
    description = "Portable command-line YAML processor.";
    url = "https://github.com/mikefarah/yq";
    visibility = "public";
  }
  {
    name = "curl";
    inherit (pkgs.curl) version;
    description = "Command-line HTTP client.";
    url = "https://curl.se/";
    visibility = "public";
  }
  {
    name = "ImageMagick";
    inherit (pkgs.imagemagick) version;
    description = "Command-line toolkit for image manipulation.";
    url = "https://imagemagick.org/";
    visibility = "public";
  }
  {
    name = "ExifTool";
    inherit (pkgs.exiftool) version;
    description = "Command-line toolkit for metadata manipulation.";
    url = "https://exiftool.org/";
    visibility = "public";
  }
  {
    name = "poppler-utils";
    inherit (pkgs.poppler-utils) version;
    description = "Command-line utilities for PDF inspection and extraction.";
    url = "https://poppler.freedesktop.org/";
    visibility = "public";
  }
  {
    name = "qpdf";
    inherit (pkgs.qpdf) version;
    description = "Command-line tools for PDF transformation and inspection.";
    url = "https://qpdf.sourceforge.io/";
    visibility = "public";
  }
]
