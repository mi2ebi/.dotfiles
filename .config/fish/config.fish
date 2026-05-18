if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/evie/.ghcup/bin $PATH # ghcup-env

set -gx EDITOR emacs

starship init fish | source

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
/home/evie/.rakubrew/bin/rakubrew init Fish | source

pyenv init - fish | source

abbr -a g++++ "clang++ -Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic"
abbr -a dotfiles "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
