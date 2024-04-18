{ pkgs, ... }:

{
  home.username = "yonei";
  home.homeDirectory = "/home/yonei";

  gtk = {
    enable = true;
    cursorTheme.name = "Breeze_dark";
    iconTheme.name = "Vimix-dark";
    theme.name = "Nordic-bluish-accent";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      git gcc gnumake  # Ensure essential tools are present
      ripgrep fd fzf  # Supercharged tools
      nil                           # Nix LSP
      lua-language-server           # Lua LSP
      vscode-langservers-extracted  # Html/Css/Json LSP
      pyright                       # Python LSP
      efm-langserver
      tree-sitter
    ];
  };
}
