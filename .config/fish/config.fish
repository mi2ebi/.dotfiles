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
abbr -a dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

set -g fish_color_command f78fe7
set -g fish_color_keyword 79a8ff --bold
set -g fish_color_quote 2fafff
set -g fish_color_comment ef8386 -i
set -g fish_color_param ffffff
set -g fish_color_option 4ae2f0
set -g fish_color_operator 4ae2f0
set -g fish_color_escape f78fe7 --bold
set -g fish_color_redirection feacd0 --bold
set -g fish_color_end c6daff
set -g fish_color_error ff5f59
set -g fish_color_cancel ff5f59

set -g fish_color_autosuggestion 989898
set -e fish_color_valid_path
set -g fish_color_selection --background=555a66
set -g fish_color_search_match --background=7a6100

set -g fish_pager_color_background 1d2235
set -g fish_pager_color_completion ffffff
set -g fish_pager_color_description 9ac8e0 -i
set -g fish_pager_color_prefix 00bcff --bold
set -g fish_pager_color_progress c6daff
set -g fish_pager_color_selected_background 483d8a
set -g fish_pager_color_selected_completion ffffff
set -g fish_pager_color_selected_prefix 00bcff --bold
set -g fish_pager_color_selected_description 9ac8e0 -i
