# Disable greeting
set -g fish_greeting

# Global environment variables
set -gx MANPAGER 'nvim +Man!'
set -gx EDITOR nvim
set -gx VIRTUAL_ENV_DISABLE_PROMPT
set -g fish_history_ignore_space true

# Add paths
fish_add_path /usr/local/bin
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin
fish_add_path ~/.nix-profile/bin
fish_add_path ~/.local/share/pnpm

# Prompt
function fish_prompt
    echo # newline

    # Virtual environment
    if set -q VIRTUAL_ENV
        set_color white
        echo -n "("(basename (dirname $VIRTUAL_ENV))")"
    end

    # Directory in blue (last 2 dirs with ... like bash)
    set_color blue --bold
    set current_dir (pwd)
    set home_dir $HOME

    # Replace home with ~
    if string match -q "$home_dir*" $current_dir
        set current_dir (string replace $home_dir "~" $current_dir)
    end

    # Split path into components
    set path_parts (string split "/" $current_dir)
    set num_parts (count $path_parts)

    if test $num_parts -gt 3 # More than ~ + 2 dirs
        set trimmed_path "~/.../"{$path_parts[-2]}"/"$path_parts[-1]
        echo -n " "$trimmed_path""
    else
        echo -n " "$current_dir""
    end

    # Git branch in red
    set_color red
    echo -n (fish_vcs_prompt)

    # Arrow prompt
    set_color white --bold
    echo -n " → "
    set_color normal
end

# Check if commands exist before setting up aliases and initialization
if status is-interactive
    # initialize tools if available
    if command -v zoxide >/dev/null
        zoxide init fish | source
        alias cd z
    end

    if command -v fzf >/dev/null
        fzf --fish | source
        set -gx FZF_DEFAULT_OPTS "--height=12 --layout=reverse --padding 1"
    end

    if command -v fnm >/dev/null
        fnm env --use-on-cd --shell fish | source
    end

    if command -v direnv >/dev/null
        direnv hook fish | source
        set -gx DIRENV_LOG_FORMAT ""
    end

    # Set up aliases only if commands exist
    if command -v eza >/dev/null
        alias ls "eza --icons"
    else
        alias ls "ls --color=auto"
    end

    if command -v bat >/dev/null
        alias cat bat
        set -gx PAGER 'bat --paging=auto'
    end

    if command -v nvim >/dev/null
        alias vim nvim
    end

    # Abbreviations
    abbr -a clip xclip -selection clipboard
    abbr -a k kubectl

    function make_session
        tmux has-session -t $argv[1] 2>/dev/null; or tmux new -s $argv[1] -d -c $argv[2]
    end

    # Tmux session management
    if not set -q TMUX; and command -v tmux >/dev/null
        make_session notes $HOME/Documents/notes
        make_session default $HOME
        exec tmux attach -t default
    end
end
