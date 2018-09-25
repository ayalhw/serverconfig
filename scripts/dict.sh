#!/usr/bin/env bash

cat ~/Documents/wordlist2 | fzf -e --preview "{ echo {} | sdcv -e | sed -n '2,\$p' | head -n -1; wn {} -over | sed -n '2,\$p'; } | fold -s -w 100" --preview-window=up:60% --bind=ctrl-o:kill-line,enter:ignore,ctrl-c:unix-line-discard,ctrl-g:unix-line-discard,ctrl-q:unix-line-discard,esc:unix-line-discard
