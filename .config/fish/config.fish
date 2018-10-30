stty -ixon 2> /dev/null
set fish_color_command --bold
set fish_greeting
set FISH_CLIPBOARD_CMD cat

set FZF_HOME $HOME/.fzf
set -x CORES (getconf _NPROCESSORS_ONLN)
set -x MAKEFLAGS -j$CORES

set -x RUST_SRC_PATH /home/amos/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src
set -x FZF_DEFAULT_OPTS "--ansi --multi --bind=ctrl-v:half-page-down,alt-v:half-page-up,ctrl-l:accept"
set -x GOPATH /home/amos/go
set -x SHELL /bin/bash
set -x CARGO_HOME $HOME/.cargo
set -x CABAL_HOME $HOME/.cabal
set -x ARCANIST_HOME $HOME/git/arcanist
set -x EDITOR vim
set -x VISUAL vim
set -x GTK_IM_MODULE fcitx
set -x XMODIFIERS @im=fcitx
set -x QT_IM_MODULE fcitx
set -x ASAN_OPTIONS "handle_segv=0:detect_leaks=0"
set -x USE_GOLD_LINKER true
set -x DIRENV_LOG_FORMAT ""
set -x UID (id -u)

set -e LS_COLORS
alias l=exa

status --is-interactive;
and function __jump_add --on-variable PWD
  status --is-command-substitution; and return
  jump chdir
end

status --is-interactive;
and function __direnv_export_eval --on-event fish_prompt;
  eval (direnv export fish);
end

# prepend path
set -U fish_user_paths $HOME/scripts $FZF_HOME/bin $GOPATH/bin $HOME/pyenv/bin $CARGO_HOME/bin $CABAL_HOME/bin $ARCANIST_HOST/bin $HOME/.local/bin $HOME/bin /usr/local/bin /usr/local/go/bin /usr/bin /bin /sbin /usr/sbin

if test -e ~/.local/share/icons-in-terminal/icons.fish
    source ~/.local/share/icons-in-terminal/icons.fish
end
