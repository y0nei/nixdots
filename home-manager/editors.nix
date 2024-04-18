{ pkgs, ... }:

{
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
