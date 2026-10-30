#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# prompt: time [user@host:dir] (branch) took 5s exit 1 jobs 2, then $ (red on
# failure). ANSI colour names follow ghostty's theme, so darkman switches them.
source /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1      # * unstaged, + staged
GIT_PS1_SHOWUNTRACKEDFILES=1  # % untracked
GIT_PS1_SHOWSTASHSTATE=1      # $ stashed
GIT_PS1_SHOWUPSTREAM=auto     # < behind, > ahead, <> diverged, = in sync
# PS0 is expanded just before each command runs; ${ ...; } (bash 5.3) runs in
# this shell, so the start time survives ($(...) would lose it in a subshell)
PS0='${ __cmd_start=$EPOCHSECONDS; }'
__prompt() {
    local status=$? extra= dollar='$'
    if [[ -n $__cmd_start ]]; then
        local took=$((EPOCHSECONDS - __cmd_start))
        (( took >= 2 )) && extra+=" \[\e[90m\]took ${took}s"
        unset __cmd_start
    fi
    (( status )) && extra+=" \[\e[31m\]exit $status" dollar='\[\e[31m\]$'
    local jobs=$(jobs -p | wc -l)
    (( jobs )) && extra+=" \[\e[90m\]jobs $jobs"
    # __git_ps1 stays quoted so a branch name is printed, never re-expanded
    PS1='\[\e[90m\]\A\[\e[0m\] [\[\e[34m\]\u\[\e[0m\]@\[\e[35m\]\h\[\e[0m\]:\[\e[33m\]\w\[\e[0m\]]\[\e[32m\]$(__git_ps1 " (%s)")'"$extra"'\[\e[0m\]\n'"$dollar"'\[\e[0m\] '
}
PROMPT_COMMAND=__prompt

# Setup VulkanSDK environment
source $HOME/vulkansdk/1.4.357.1/setup-env.sh

export PATH=$PATH:~/.local/bin:~/zig
