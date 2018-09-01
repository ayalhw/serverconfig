function perfflametmux
    # set -l options -x 'f,F' -x 'F,s' 'h/help' 'f/file' 'F/fifo' 's/suffix=' 'T-testing'
    # argparse -n psub --max-args=0 $options -- $argv
    argparse -n perfflametmux 'h/help' 'p=' -- $argv
    or return
    if set -q _flag_h
        echo 'Usage: perfflametmux [-h|--help] ...'
        return
    end

    if test 1 -le $_flag_p > /dev/null 2> /dev/null
        mkdir -p ~/perfdata
        pushd ~/perfdata
        set -l df (mktemp (date '+%Y-%m-%d-%H_%M_%S_')XXX.data)
        set -l ds (basename -s .data $df).svg
        set -l cols (tput cols)
        set -l rows (tput lines)
        set -l msg "Start recording process "$_flag_p" ("(ps -p $_flag_p -o comm=)"). Hit Ctrl-C to finish."
        set -l centercol (math \({$cols}-(string length $msg)\)/2)
        set -l centercol2 (math \({$cols}-8\)/2)
        set -l centerrow (math $rows/2-1)
        tput cup $centerrow $centercol
        set -l msg \e\[1m\e\[92m$msg\e\[0m
        set -l clock \e\[1m\e\[33m(string repeat -n $centercol2 " ")
        echo $msg
        echo
        sw $clock $df $ds perf record -F 99 -g -p $_flag_p -o $df ^ /dev/null
        # warning: this never runs. The script should be driven by tmux
        popd
    end
end
