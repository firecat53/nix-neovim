# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{inputs}: final: prev:
with final.pkgs.lib; let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-wrapNeovim = inputs.nixpkgs.legacyPackages.${pkgs.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix { inherit pkgs-wrapNeovim; };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    # nvim-cmp (autocompletion) and extensions
     nvim-cmp # https://github.com/hrsh7th/nvim-cmp
     cmp-buffer # current buffer as completion source | https://github.com/hrsh7th/cmp-buffer/
     cmp-cmdline # cmp command line suggestions
     cmp-cmdline-history # cmp command line history suggestions
     cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
     cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
     cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/
     cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
     cmp_luasnip # snippets autocompletion extension for nvim-cmp | https://github.com/saadparwaiz1/cmp_luasnip/
     # git integration plugins
     gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
     # Telescope and extensions
     telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
     telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
     telescope-smart-history-nvim # https://github.com/nvim-telescope/telescope-smart-history.nvim
     # UI
     catppuccin-nvim
     lspkind-nvim # vscode-like LSP pictograms | https://github.com/onsails/lspkind.nvim/
     lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
     # language support
     # navigation/editing enhancement plugins
     nvim-navic # Add LSP location to lualine | https://github.com/SmiteshP/nvim-navic
     nvim-treesitter.withAllGrammars
     nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
     nvim-treesitter-context # nvim-treesitter-context
     nvim-treesitter-textobjects # https://github.com/nvim-treesitter/nvim-treesitter-textobjects/
     # Useful utilities
     eyeliner-nvim # Highlights unique characters for f/F and t/T motions | https://github.com/jinh0/eyeliner.nvim
     luasnip # snippets | https://github.com/l3mon4d3/luasnip/
     neo-tree-nvim
     nvim-unception # Prevent nested neovim sessions | nvim-unception
     outline-nvim
     which-key-nvim
     # libraries that other plugins depend on
     nvim-web-devicons
     plenary-nvim
     sqlite-lua
     # bleeding-edge plugins from flake inputs
     # (mkNvimPlugin inputs.wf-nvim "wf.nvim") # (example) keymap hints | https://github.com/Cassin01/wf.nvim
     # ^ bleeding-edge plugins from flake inputs
     # Markdown/wiki handling
     (mkNvimPlugin inputs.markdown-table-mode "markdown-table-mode")
     bullets-vim
     markdown-preview-nvim
     obsidian-nvim
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    basedpyright
    lua-language-server
    marksman
    nil # nix LSP
    ruff
    # Tools
    fd
    ripgrep
  ];
in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
